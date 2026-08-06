import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/data/repositories/workout_session_repository.dart';
import '../../app/data/services/notification_service.dart';
import '../../app/data/services/streak_service.dart';
import '../../app/utils/app_constants.dart';
import '../../app/utils/app_date_utils.dart';
import '../../app/utils/clock_service.dart';

/// Mengelola form tambah/edit satu [WorkoutSession].
class WorkoutFormController extends GetxController {
  WorkoutFormController({
    WorkoutSessionRepository? repository,
    UserSettingsRepository? settingsRepository,
    StreakService? streakService,
    ClockService? clock,
  }) : _repository = repository ?? WorkoutSessionRepository(),
       _settingsRepository = settingsRepository ?? UserSettingsRepository(),
       _streakService = streakService ?? StreakService(),
       _clock = clock ?? Get.find<ClockService>();

  final WorkoutSessionRepository _repository;
  final UserSettingsRepository _settingsRepository;
  final StreakService _streakService;
  final ClockService _clock;

  WorkoutSession? _editing;

  final RxString workoutType = AppConstants.defaultWorkoutTypes.first.obs;
  final TextEditingController customTypeController = TextEditingController();
  final Rx<DateTime> workoutDate = DateTime.now().obs;
  final TextEditingController durationController = TextEditingController();
  final Rx<WorkoutIntensity> intensity = WorkoutIntensity.sedang.obs;
  final TextEditingController notesController = TextEditingController();
  final RxBool isSaving = false.obs;

  bool get isEditing => _editing != null;

  @override
  void onInit() {
    super.onInit();
    workoutDate.value = AppDateUtils.dateOnly(_clock.now());

    final args = Get.arguments;
    if (args is WorkoutSession) {
      _editing = args;
      _prefillFromSession(args);
    } else if (args is Map && args['workoutType'] is String) {
      _selectType(args['workoutType'] as String);
    }
  }

  void _prefillFromSession(WorkoutSession session) {
    _selectType(session.workoutType);
    workoutDate.value = session.workoutDate;
    durationController.text = session.durationMinutes.toString();
    intensity.value = session.intensity;
    notesController.text = session.notes ?? '';
  }

  void _selectType(String type) {
    if (AppConstants.defaultWorkoutTypes.contains(type)) {
      workoutType.value = type;
    } else {
      workoutType.value = 'Custom Workout';
      customTypeController.text = type;
    }
  }

  void selectWorkoutType(String type) => workoutType.value = type;

  void selectIntensity(WorkoutIntensity value) => intensity.value = value;

  Future<void> pickDate(BuildContext context) async {
    final today = AppDateUtils.dateOnly(_clock.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: workoutDate.value,
      firstDate: DateTime(today.year - 2),
      lastDate: today,
    );
    if (picked != null) {
      workoutDate.value = picked;
    }
  }

  Future<void> save() async {
    final effectiveType = workoutType.value == 'Custom Workout'
        ? customTypeController.text.trim()
        : workoutType.value;
    if (effectiveType.isEmpty) {
      Get.snackbar(
        'Jenis workout belum diisi',
        'Isi nama workout custom kamu terlebih dahulu.',
      );
      return;
    }

    final duration = int.tryParse(durationController.text.trim());
    if (duration == null || duration <= 0) {
      Get.snackbar(
        'Durasi tidak valid',
        'Masukkan durasi workout dalam menit, contoh: 45.',
      );
      return;
    }

    isSaving.value = true;
    final now = _clock.now();
    final notes = notesController.text.trim();

    if (_editing != null) {
      await _repository.update(
        _editing!.copyWith(
          workoutDate: workoutDate.value,
          workoutType: effectiveType,
          durationMinutes: duration,
          intensity: intensity.value,
          notes: notes.isEmpty ? null : notes,
          updatedAt: now,
        ),
      );
    } else {
      await _repository.insert(
        WorkoutSession(
          workoutDate: workoutDate.value,
          workoutType: effectiveType,
          durationMinutes: duration,
          intensity: intensity.value,
          notes: notes.isEmpty ? null : notes,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final settings = await _settingsRepository.getSettings();
    if (settings != null) {
      await _streakService.recalculateWeek(
        workoutDate.value,
        settings.weeklyTarget,
      );
    }

    // Jika workout hari ini sudah selesai, pengingat kedua hari ini
    // dibatalkan dan jadwal minggu berikutnya dipasang kembali.
    await NotificationService.instance.syncFromStoredSettings();

    isSaving.value = false;
    Get.back(result: true);
  }

  @override
  void onClose() {
    customTypeController.dispose();
    durationController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
