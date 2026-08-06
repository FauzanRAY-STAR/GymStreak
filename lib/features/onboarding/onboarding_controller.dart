import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/user_settings.dart';
import '../../app/data/models/workout_schedule.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/data/repositories/workout_schedule_repository.dart';
import '../../app/data/services/notification_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/utils/app_constants.dart';
import '../../app/utils/app_date_utils.dart';

/// Mengelola state form onboarding (data awal pengguna) dan menyimpannya
/// sebagai [UserSettings].
class OnboardingController extends GetxController {
  final UserSettingsRepository _repository = UserSettingsRepository();
  final WorkoutScheduleRepository _scheduleRepository =
      WorkoutScheduleRepository();

  final TextEditingController nameController = TextEditingController();
  final RxInt weeklyTarget = 4.obs;
  final RxSet<int> workoutDays = <int>{1, 3, 5}.obs;
  final Rx<TimeOfDay> reminderTime = const TimeOfDay(hour: 18, minute: 30).obs;
  final RxString fitnessGoal = AppConstants.fitnessGoals.first.obs;
  final RxBool isSaving = false.obs;

  String get reminderTimeLabel =>
      AppDateUtils.formatTimeOfDay(reminderTime.value);

  void toggleDay(int day) {
    if (workoutDays.contains(day)) {
      workoutDays.remove(day);
      return;
    }
    if (workoutDays.length >= weeklyTarget.value) {
      Get.snackbar(
        'Batas hari tercapai',
        'Jumlah hari workout mengikuti target mingguan '
            '(${weeklyTarget.value}x). Kurangi target atau hari lain dulu.',
      );
      return;
    }
    workoutDays.add(day);
  }

  void setWeeklyTarget(int value) {
    final clamped = value.clamp(3, 6);
    weeklyTarget.value = clamped;
    if (workoutDays.length > clamped) {
      final trimmed = (workoutDays.toList()..sort()).take(clamped).toSet();
      workoutDays
        ..clear()
        ..addAll(trimmed);
    }
  }

  void selectFitnessGoal(String goal) {
    fitnessGoal.value = goal;
  }

  Future<void> pickReminderTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: reminderTime.value,
    );
    if (picked != null) {
      reminderTime.value = picked;
    }
  }

  Future<void> completeOnboarding() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Nama belum diisi', 'Mohon isi nama kamu terlebih dahulu.');
      return;
    }
    if (workoutDays.isEmpty) {
      Get.snackbar(
        'Hari workout belum dipilih',
        'Pilih minimal satu hari workout.',
      );
      return;
    }

    isSaving.value = true;
    final sortedDays = workoutDays.toList()..sort();
    var settings = UserSettings(
      name: name,
      weeklyTarget: weeklyTarget.value,
      workoutDays: sortedDays,
      reminderTime: reminderTimeLabel,
      reminderEnabled: true,
      secondReminderEnabled: false,
      fitnessGoal: fitnessGoal.value,
      onboardingCompleted: true,
    );

    await _repository.saveSettings(settings);
    await _seedInitialSchedules(sortedDays);

    final permissionGranted = await NotificationService.instance
        .requestPermission();
    if (permissionGranted) {
      await NotificationService.instance.syncFromStoredSettings();
    } else {
      settings = settings.copyWith(reminderEnabled: false);
      await _repository.saveSettings(settings);
      Get.snackbar(
        'Notifikasi belum diizinkan',
        'Pengingat dapat diaktifkan nanti melalui halaman Profil.',
      );
    }

    isSaving.value = false;
    Get.offAllNamed(AppRoutes.main);
  }

  /// Membuat jadwal awal Full Body untuk setiap hari yang dipilih.
  Future<void> _seedInitialSchedules(List<int> days) async {
    final existing = await _scheduleRepository.getAll();
    if (existing.isNotEmpty) return;

    for (final day in days) {
      await _scheduleRepository.insert(
        WorkoutSchedule(
          dayOfWeek: day,
          workoutType: 'Full Body',
          reminderTime: reminderTimeLabel,
          active: true,
        ),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
