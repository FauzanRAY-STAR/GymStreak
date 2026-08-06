import 'package:get/get.dart';

import '../../app/data/database/database_helper.dart';
import '../../app/data/models/user_settings.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/data/repositories/workout_session_repository.dart';
import '../../app/data/services/notification_service.dart';
import '../../app/data/services/streak_service.dart';
import '../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  ProfileController({
    UserSettingsRepository? settingsRepository,
    WorkoutSessionRepository? sessionRepository,
    StreakService? streakService,
  }) : _settingsRepository = settingsRepository ?? UserSettingsRepository(),
       _sessionRepository = sessionRepository ?? WorkoutSessionRepository(),
       _streakService = streakService ?? StreakService();

  final UserSettingsRepository _settingsRepository;
  final WorkoutSessionRepository _sessionRepository;
  final StreakService _streakService;

  final Rxn<UserSettings> settings = Rxn<UserSettings>();
  final RxInt totalWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    final loadedSettings = await _settingsRepository.getSettings();
    settings.value = loadedSettings;
    totalWorkouts.value = await _sessionRepository.count();

    if (loadedSettings != null) {
      await _streakService.syncWeeklyProgress(loadedSettings.weeklyTarget);
      final stats = await _streakService.getStats();
      currentStreak.value = stats.currentStreak;
      longestStreak.value = stats.longestStreak;
    }

    isLoading.value = false;
  }

  Future<void> toggleReminder(bool value) async {
    final current = settings.value;
    if (current == null) return;

    if (value) {
      final permissionGranted = await NotificationService.instance
          .requestPermission();
      if (!permissionGranted) {
        Get.snackbar(
          'Izin notifikasi diperlukan',
          'Izinkan notifikasi agar GymStreak dapat mengingatkan jadwalmu.',
        );
        return;
      }
    }

    final updated = current.copyWith(
      reminderEnabled: value,
      secondReminderEnabled: value ? current.secondReminderEnabled : false,
    );
    await _settingsRepository.saveSettings(updated);
    settings.value = updated;

    if (value) {
      await NotificationService.instance.syncFromStoredSettings();
    } else {
      await NotificationService.instance.cancelWorkoutReminders();
    }
  }

  Future<void> toggleSecondReminder(bool value) async {
    final current = settings.value;
    if (current == null || !current.reminderEnabled) return;

    final updated = current.copyWith(secondReminderEnabled: value);
    await _settingsRepository.saveSettings(updated);
    settings.value = updated;
    await NotificationService.instance.syncFromStoredSettings();
  }

  Future<void> openSettings() async {
    final result = await Get.toNamed(AppRoutes.settings);
    if (result == true) {
      await loadProfile();
    }
  }

  Future<void> openScheduleList() async {
    await Get.toNamed(AppRoutes.scheduleList);
    await loadProfile();
  }

  Future<void> openWorkoutList() async {
    await Get.toNamed(AppRoutes.workoutList);
    await loadProfile();
  }

  Future<void> resetAllData() async {
    await NotificationService.instance.cancelWorkoutReminders();
    await DatabaseHelper.instance.resetUserData();
    Get.offAllNamed(AppRoutes.splash);
  }
}
