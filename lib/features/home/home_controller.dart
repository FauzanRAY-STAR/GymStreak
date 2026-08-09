import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/data/models/user_settings.dart';
import '../../app/data/models/workout_schedule.dart';
import '../../app/data/models/workout_session.dart';
import '../../app/data/repositories/user_settings_repository.dart';
import '../../app/data/repositories/workout_schedule_repository.dart';
import '../../app/data/repositories/workout_session_repository.dart';
import '../../app/data/services/recipe_recommendation_service.dart';
import '../../app/data/services/streak_service.dart';
import '../../app/routes/app_routes.dart';
import '../../app/utils/app_date_utils.dart';
import '../../app/utils/clock_service.dart';
import '../../app/data/services/profile_image_service.dart';

class HomeController extends GetxController {
  HomeController({
    UserSettingsRepository? settingsRepository,
    WorkoutSessionRepository? sessionRepository,
    WorkoutScheduleRepository? scheduleRepository,
    StreakService? streakService,
    RecipeRecommendationService? recommendationService,
    ClockService? clock,
  }) : _settingsRepository = settingsRepository ?? UserSettingsRepository(),
       _sessionRepository = sessionRepository ?? WorkoutSessionRepository(),
       _scheduleRepository = scheduleRepository ?? WorkoutScheduleRepository(),
       _streakService = streakService ?? StreakService(),
       _recommendationService =
           recommendationService ?? RecipeRecommendationService(),
       _clock = clock ?? Get.find<ClockService>();

  final UserSettingsRepository _settingsRepository;
  final WorkoutSessionRepository _sessionRepository;
  final WorkoutScheduleRepository _scheduleRepository;
  final StreakService _streakService;
  final RecipeRecommendationService _recommendationService;
  final ClockService _clock;

  final Rxn<UserSettings> settings = Rxn<UserSettings>();
  final RxnString profileImagePath = RxnString();
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt weeklyCompletedDays = 0.obs;
  final Rxn<WorkoutSchedule> todaySchedule = Rxn<WorkoutSchedule>();
  final RxBool isTodayLogged = false.obs;
  final Rxn<WorkoutSession> todaySession = Rxn<WorkoutSession>();
  final RxList<WorkoutSession> recentSessions = <WorkoutSession>[].obs;
  final Rxn<Recipe> recipeRecommendation = Rxn<Recipe>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  String get greeting {
    final hour = _clock.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    final loadedSettings = await _settingsRepository.getSettings();
    settings.value = loadedSettings;

    profileImagePath.value = await ProfileImageService.instance
        .getProfileImagePath();
    if (loadedSettings != null) {
      await _streakService.syncWeeklyProgress(loadedSettings.weeklyTarget);
      final stats = await _streakService.getStats();
      currentStreak.value = stats.currentStreak;
      longestStreak.value = stats.longestStreak;

      final today = AppDateUtils.dateOnly(_clock.now());
      final weekStart = AppDateUtils.startOfWeek(today);
      final weekEnd = AppDateUtils.endOfWeek(today);
      final weekSessions = await _sessionRepository.getByDateRange(
        weekStart,
        weekEnd,
      );
      weeklyCompletedDays.value = weekSessions
          .map((session) => AppDateUtils.formatDateKey(session.workoutDate))
          .toSet()
          .length;

      final todaySessions = await _sessionRepository.getByDate(today);

      todaySession.value = todaySessions.isEmpty ? null : todaySessions.first;

      isTodayLogged.value = todaySession.value != null;

      final activeSchedules = await _scheduleRepository.getActive();
      WorkoutSchedule? match;
      for (final schedule in activeSchedules) {
        if (schedule.dayOfWeek == today.weekday) {
          match = schedule;
          break;
        }
      }
      todaySchedule.value = match;
    }

    recentSessions.value = await _sessionRepository.getRecent(5);
    recipeRecommendation.value = await _recommendationService
        .getTodayRecommendation();
    isLoading.value = false;
  }

  void setRecipeRecommendation(Recipe recipe) {
    recipeRecommendation.value = recipe;
  }

  Future<void> openRecipe(Recipe recipe) async {
    await Get.toNamed(AppRoutes.recipeDetail, arguments: recipe.id);
    recipeRecommendation.value = await _recommendationService
        .getTodayRecommendation();
  }

  Future<void> completeWorkout() async {
    final schedule = todaySchedule.value;
    final result = await Get.toNamed(
      AppRoutes.workoutForm,
      arguments: schedule != null
          ? {'workoutType': schedule.workoutType}
          : null,
    );
    if (result == true) {
      await loadHome();
    }
  }

  Future<void> viewAllWorkouts() async {
    await Get.toNamed(AppRoutes.workoutList);
    await loadHome();
  }
}
