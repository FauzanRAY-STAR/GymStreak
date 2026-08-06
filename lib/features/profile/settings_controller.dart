import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/user_settings.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/utils/app_date_utils.dart';

/// Mengelola form edit pengaturan pengguna yang sudah pernah onboarding.
class SettingsController extends GetxController {
  final UserSettingsRepository _repository = UserSettingsRepository();

  final TextEditingController nameController = TextEditingController();
  final RxInt weeklyTarget = 4.obs;
  final RxSet<int> workoutDays = <int>{}.obs;
  final Rx<TimeOfDay> reminderTime = const TimeOfDay(hour: 18, minute: 30).obs;
  final RxString fitnessGoal = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  UserSettings? _original;

  String get reminderTimeLabel =>
      AppDateUtils.formatTimeOfDay(reminderTime.value);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final settings = await _repository.getSettings();
    if (settings != null) {
      _original = settings;
      nameController.text = settings.name;
      weeklyTarget.value = settings.weeklyTarget;
      workoutDays.assignAll(settings.workoutDays);
      reminderTime.value = AppDateUtils.parseTimeOfDay(settings.reminderTime);
      fitnessGoal.value = settings.fitnessGoal;
    }
    isLoading.value = false;
  }

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
    // Hari workout tidak boleh melebihi target mingguan yang baru.
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

  Future<void> save() async {
    final original = _original;
    if (original == null) return;

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
    final updated = original.copyWith(
      name: name,
      weeklyTarget: weeklyTarget.value,
      workoutDays: sortedDays,
      reminderTime: reminderTimeLabel,
      fitnessGoal: fitnessGoal.value,
    );
    await _repository.saveSettings(updated);
    isSaving.value = false;
    Get.back(result: true);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
