import '../models/user_settings.dart';
import '../models/workout_schedule.dart';
import '../repositories/user_settings_repository.dart';
import '../repositories/workout_schedule_repository.dart';
import 'notification_service.dart';

/// Menjaga agar pilihan hari di Settings dan tabel workout_schedules tetap
/// konsisten. Satu hari hanya boleh memiliki satu jadwal.
class WorkoutScheduleSyncService {
  WorkoutScheduleSyncService({
    WorkoutScheduleRepository? scheduleRepository,
    UserSettingsRepository? settingsRepository,
    NotificationService? notificationService,
  }) : _scheduleRepository = scheduleRepository ?? WorkoutScheduleRepository(),
       _settingsRepository = settingsRepository ?? UserSettingsRepository(),
       _notificationService =
           notificationService ?? NotificationService.instance;

  final WorkoutScheduleRepository _scheduleRepository;
  final UserSettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  /// Menerapkan pilihan hari dan jam dari Settings ke jadwal workout.
  Future<void> applySettings(UserSettings settings) async {
    final selectedDays = settings.workoutDays.toSet();
    final schedules = await _scheduleRepository.getAll();
    final schedulesByDay = <int, List<WorkoutSchedule>>{};

    for (final schedule in schedules) {
      schedulesByDay.putIfAbsent(schedule.dayOfWeek, () => []).add(schedule);
    }

    for (final schedule in schedules) {
      if (!selectedDays.contains(schedule.dayOfWeek) && schedule.id != null) {
        await _scheduleRepository.delete(schedule.id!);
      }
    }

    for (final day in selectedDays) {
      final sameDay = schedulesByDay[day] ?? const <WorkoutSchedule>[];

      if (sameDay.isEmpty) {
        await _scheduleRepository.insert(
          WorkoutSchedule(
            dayOfWeek: day,
            workoutType: 'Full Body',
            reminderTime: settings.reminderTime,
            active: true,
          ),
        );
        continue;
      }

      final primary = sameDay.first;
      await _scheduleRepository.update(
        primary.copyWith(reminderTime: settings.reminderTime, active: true),
      );

      for (final duplicate in sameDay.skip(1)) {
        if (duplicate.id != null) {
          await _scheduleRepository.delete(duplicate.id!);
        }
      }
    }

    await _notificationService.syncFromStoredSettings();
  }

  /// Memperbarui workoutDays di UserSettings berdasarkan jadwal aktif.
  Future<void> refreshSettingsFromSchedules() async {
    final settings = await _settingsRepository.getSettings();
    if (settings == null) {
      await _notificationService.cancelWorkoutReminders();
      return;
    }

    final activeSchedules = await _scheduleRepository.getActive();
    final activeDays = activeSchedules.map((item) => item.dayOfWeek).toSet()
      ..removeWhere((day) => day < 1 || day > 7);
    final sortedDays = activeDays.toList()..sort();

    var target = settings.weeklyTarget;
    if (sortedDays.length > target) {
      target = sortedDays.length > 6 ? 6 : sortedDays.length;
    }

    await _settingsRepository.saveSettings(
      settings.copyWith(workoutDays: sortedDays, weeklyTarget: target),
    );

    await _notificationService.syncFromStoredSettings();
  }

  /// Mengembalikan pesan error jika jadwal tidak valid.
  Future<String?> validateSchedule({
    required int dayOfWeek,
    required bool active,
    int? editingId,
  }) async {
    final all = await _scheduleRepository.getAll();

    final duplicate = all.any(
      (schedule) => schedule.dayOfWeek == dayOfWeek && schedule.id != editingId,
    );
    if (duplicate) {
      return 'Hari tersebut sudah memiliki jadwal workout.';
    }

    if (!active) return null;

    final settings = await _settingsRepository.getSettings();
    if (settings == null) return null;

    final activeOthers = all.where(
      (schedule) => schedule.active && schedule.id != editingId,
    );
    if (activeOthers.length >= settings.weeklyTarget) {
      return 'Jumlah jadwal aktif sudah mencapai target mingguan '
          '(${settings.weeklyTarget}x).';
    }

    return null;
  }
}
