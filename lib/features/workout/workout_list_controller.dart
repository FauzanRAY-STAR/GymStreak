import 'package:get/get.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/data/repositories/workout_session_repository.dart';
import '../../app/data/services/notification_service.dart';
import '../../app/data/services/streak_service.dart';
import '../../app/routes/app_routes.dart';

class WorkoutListController extends GetxController {
  WorkoutListController({
    WorkoutSessionRepository? repository,
    UserSettingsRepository? settingsRepository,
    StreakService? streakService,
  }) : _repository = repository ?? WorkoutSessionRepository(),
       _settingsRepository = settingsRepository ?? UserSettingsRepository(),
       _streakService = streakService ?? StreakService();

  final WorkoutSessionRepository _repository;
  final UserSettingsRepository _settingsRepository;
  final StreakService _streakService;

  final RxList<WorkoutSession> sessions = <WorkoutSession>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  Future<void> loadSessions() async {
    isLoading.value = true;
    sessions.value = await _repository.getAll();
    isLoading.value = false;
  }

  Future<void> addWorkout() async {
    final result = await Get.toNamed(AppRoutes.workoutForm);
    if (result == true) {
      await loadSessions();
    }
  }

  Future<void> editWorkout(WorkoutSession session) async {
    final result = await Get.toNamed(AppRoutes.workoutForm, arguments: session);
    if (result == true) {
      await loadSessions();
    }
  }

  Future<void> deleteWorkout(WorkoutSession session) async {
    await _repository.delete(session.id!);

    final settings = await _settingsRepository.getSettings();
    if (settings != null) {
      await _streakService.recalculateWeek(
        session.workoutDate,
        settings.weeklyTarget,
        recalculateFinalized: true,
      );
    }

    await NotificationService.instance.syncFromStoredSettings();
    await loadSessions();
  }
}
