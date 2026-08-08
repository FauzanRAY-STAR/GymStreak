import 'package:get/get.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/data/repositories/weekly_progress_repository.dart';
import '../../app/data/repositories/workout_session_repository.dart';
import '../../app/data/services/streak_service.dart';
import '../../app/utils/app_date_utils.dart';
import '../../app/utils/clock_service.dart';

class CalendarController extends GetxController {
  CalendarController({
    WorkoutSessionRepository? sessionRepository,
    WeeklyProgressRepository? weeklyProgressRepository,
    StreakService? streakService,
    ClockService? clock,
  }) : _sessionRepository = sessionRepository ?? WorkoutSessionRepository(),
       _weeklyProgressRepository =
           weeklyProgressRepository ?? WeeklyProgressRepository(),
       _streakService = streakService ?? StreakService(),
       _clock = clock ?? Get.find<ClockService>();

  final WorkoutSessionRepository _sessionRepository;
  final WeeklyProgressRepository _weeklyProgressRepository;
  final StreakService _streakService;
  final ClockService _clock;

  final Rx<DateTime> focusedMonth = DateTime.now().obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxMap<String, List<WorkoutSession>> sessionsByDate =
      <String, List<WorkoutSession>>{}.obs;
  final RxBool isLoading = true.obs;

  final RxInt currentStreak = 0.obs;
  final RxInt weeksAchievedInMonth = 0.obs;
  final RxInt weeksTotalInMonth = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final today = AppDateUtils.dateOnly(_clock.now());
    focusedMonth.value = today;
    selectedDate.value = today;
    _loadCurrentStreak();
    loadMonth(today);
  }

  Future<void> _loadCurrentStreak() async {
    currentStreak.value = await _streakService.getCurrentStreak();
  }

  Future<void> loadMonth(DateTime month) async {
    isLoading.value = true;
    final sessions = await _sessionRepository.getByMonth(
      month.year,
      month.month,
    );
    final map = <String, List<WorkoutSession>>{};
    for (final session in sessions) {
      final key = AppDateUtils.formatDateKey(session.workoutDate);
      map.putIfAbsent(key, () => []).add(session);
    }
    sessionsByDate.value = map;

    final allProgress = await _weeklyProgressRepository.getAll();
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 0);
    final weeksInMonth = allProgress
        .where(
          (w) =>
              !w.weekStartDate.isBefore(monthStart) &&
              !w.weekStartDate.isAfter(monthEnd),
        )
        .toList();
    weeksTotalInMonth.value = weeksInMonth.length;
    weeksAchievedInMonth.value = weeksInMonth.where((w) => w.achieved).length;

    isLoading.value = false;
  }

  List<WorkoutSession> sessionsFor(DateTime date) {
    return sessionsByDate[AppDateUtils.formatDateKey(date)] ?? const [];
  }

  /// Intensitas tertinggi pada [date], atau null jika tidak ada workout.
  WorkoutIntensity? heaviestIntensity(DateTime date) {
    final sessions = sessionsFor(date);
    if (sessions.isEmpty) return null;
    var heaviest = WorkoutIntensity.ringan;
    for (final session in sessions) {
      if (session.intensity.index > heaviest.index) {
        heaviest = session.intensity;
      }
    }
    return heaviest;
  }

  void selectDate(DateTime date) {
    selectedDate.value = AppDateUtils.dateOnly(date);
  }

  void onPageChanged(DateTime month) {
    focusedMonth.value = month;
    loadMonth(month);
  }

  int get monthlyTotalWorkouts =>
      sessionsByDate.values.fold(0, (sum, list) => sum + list.length);

  int get monthlyTotalMinutes => sessionsByDate.values
      .expand((list) => list)
      .fold(0, (sum, s) => sum + s.durationMinutes);

  double get monthlyTargetPercentage {
    if (weeksTotalInMonth.value == 0) return 0;
    return weeksAchievedInMonth.value / weeksTotalInMonth.value * 100;
  }
}
