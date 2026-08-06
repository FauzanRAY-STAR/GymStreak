import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/workout_schedule.dart';
import '../../app/data/repositories/workout_schedule_repository.dart';
import '../../app/data/services/workout_schedule_sync_service.dart';
import '../../app/utils/app_constants.dart';
import '../../app/utils/app_date_utils.dart';

/// Mengelola form tambah/edit satu [WorkoutSchedule].
class ScheduleFormController extends GetxController {
  ScheduleFormController({
    WorkoutScheduleRepository? repository,
    WorkoutScheduleSyncService? syncService,
  }) : _repository = repository ?? WorkoutScheduleRepository(),
       _syncService = syncService ?? WorkoutScheduleSyncService();

  final WorkoutScheduleRepository _repository;
  final WorkoutScheduleSyncService _syncService;

  WorkoutSchedule? _editing;

  final RxInt dayOfWeek = 1.obs;
  final RxString workoutType = AppConstants.defaultWorkoutTypes.first.obs;
  final TextEditingController customTypeController = TextEditingController();
  final Rx<TimeOfDay> reminderTime = const TimeOfDay(hour: 18, minute: 30).obs;
  final RxBool active = true.obs;
  final RxBool isSaving = false.obs;

  bool get isEditing => _editing != null;

  String get reminderTimeLabel =>
      AppDateUtils.formatTimeOfDay(reminderTime.value);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is WorkoutSchedule) {
      _editing = args;
      dayOfWeek.value = args.dayOfWeek;
      if (AppConstants.defaultWorkoutTypes.contains(args.workoutType)) {
        workoutType.value = args.workoutType;
      } else {
        workoutType.value = 'Custom Workout';
        customTypeController.text = args.workoutType;
      }
      reminderTime.value = AppDateUtils.parseTimeOfDay(args.reminderTime);
      active.value = args.active;
    }
  }

  void selectDay(int day) => dayOfWeek.value = day;

  void selectType(String type) => workoutType.value = type;

  void setActive(bool value) => active.value = value;

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

    final validationMessage = await _syncService.validateSchedule(
      dayOfWeek: dayOfWeek.value,
      active: active.value,
      editingId: _editing?.id,
    );
    if (validationMessage != null) {
      Get.snackbar('Jadwal tidak dapat disimpan', validationMessage);
      return;
    }

    isSaving.value = true;
    if (_editing != null) {
      await _repository.update(
        _editing!.copyWith(
          dayOfWeek: dayOfWeek.value,
          workoutType: effectiveType,
          reminderTime: reminderTimeLabel,
          active: active.value,
        ),
      );
    } else {
      await _repository.insert(
        WorkoutSchedule(
          dayOfWeek: dayOfWeek.value,
          workoutType: effectiveType,
          reminderTime: reminderTimeLabel,
          active: active.value,
        ),
      );
    }

    await _syncService.refreshSettingsFromSchedules();
    isSaving.value = false;
    Get.back(result: true);
  }

  @override
  void onClose() {
    customTypeController.dispose();
    super.onClose();
  }
}
