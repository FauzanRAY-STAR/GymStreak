import 'package:get/get.dart';

import '../../utils/app_date_utils.dart';
import '../../utils/clock_service.dart';
import '../models/weekly_progress.dart';
import '../repositories/weekly_progress_repository.dart';
import '../repositories/workout_session_repository.dart';

/// Batas pengaman tambahan saat menyinkronkan minggu lampau.
const int _maxBackfillWeeks = 104;

/// Menghitung dan menyimpan progress target mingguan.
///
/// Aturan:
/// - Minggu dihitung Senin sampai Minggu.
/// - Satu hari maksimal dihitung satu kali.
/// - Rest day netral.
/// - Minggu baru final setelah benar-benar berakhir.
class StreakService {
  StreakService({
    WeeklyProgressRepository? weeklyProgressRepository,
    WorkoutSessionRepository? workoutSessionRepository,
    ClockService? clock,
  }) : _weeklyProgressRepository =
           weeklyProgressRepository ?? WeeklyProgressRepository(),
       _workoutSessionRepository =
           workoutSessionRepository ?? WorkoutSessionRepository(),
       _clock = clock ?? Get.find<ClockService>();

  final WeeklyProgressRepository _weeklyProgressRepository;
  final WorkoutSessionRepository _workoutSessionRepository;
  final ClockService _clock;

  Future<WeeklyProgress> recalculateWeek(DateTime date, int target) async {
    final weekStart = AppDateUtils.startOfWeek(date);
    final weekEnd = AppDateUtils.endOfWeek(date);

    final existing = await _weeklyProgressRepository.getByWeekStart(weekStart);
    if (existing != null && existing.finalized) {
      return existing;
    }

    final sessions = await _workoutSessionRepository.getByDateRange(
      weekStart,
      weekEnd,
    );
    final completedDays = sessions
        .map((session) => AppDateUtils.formatDateKey(session.workoutDate))
        .toSet()
        .length;

    final today = AppDateUtils.dateOnly(_clock.now());
    final isWeekOver = today.isAfter(weekEnd);
    final targetForWeek = existing?.targetAtThatTime ?? target;

    final progress = WeeklyProgress(
      id: existing?.id,
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      targetAtThatTime: targetForWeek,
      completedWorkoutDays: completedDays,
      achieved: completedDays >= targetForWeek,
      finalized: isWeekOver,
    );
    await _weeklyProgressRepository.upsert(progress);
    return progress;
  }

  /// Menyinkronkan minggu berjalan dan minggu lampau sejak workout pertama.
  ///
  /// Pembatasan ini mencegah pengguna baru mendapatkan ratusan minggu gagal
  /// sebelum mereka mulai memakai aplikasi.
  Future<void> syncWeeklyProgress(int currentTarget) async {
    final today = AppDateUtils.dateOnly(_clock.now());
    await recalculateWeek(today, currentTarget);

    final oldestWorkoutDate = await _workoutSessionRepository
        .getOldestWorkoutDate();
    if (oldestWorkoutDate == null) return;

    final earliestWeek = AppDateUtils.startOfWeek(oldestWorkoutDate);
    var cursor = AppDateUtils.startOfWeek(
      today,
    ).subtract(const Duration(days: 7));

    for (
      var i = 0;
      i < _maxBackfillWeeks && !cursor.isBefore(earliestWeek);
      i++
    ) {
      final existing = await _weeklyProgressRepository.getByWeekStart(cursor);
      if (existing != null && existing.finalized) break;

      await recalculateWeek(cursor, currentTarget);
      cursor = cursor.subtract(const Duration(days: 7));
    }
  }

  Future<int> getCurrentStreak() async {
    final finalizedWeeks = await _weeklyProgressRepository.getFinalized();
    var streak = 0;
    for (final week in finalizedWeeks) {
      if (!week.achieved) break;
      streak++;
    }
    return streak;
  }

  Future<int> getLongestStreak() async {
    final finalizedWeeks = await _weeklyProgressRepository.getFinalized();
    final chronological = finalizedWeeks.reversed.toList();
    var longest = 0;
    var current = 0;

    for (final week in chronological) {
      if (week.achieved) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 0;
      }
    }

    return longest;
  }

  Future<StreakStats> getStats() async {
    return StreakStats(
      currentStreak: await getCurrentStreak(),
      longestStreak: await getLongestStreak(),
    );
  }
}

class StreakStats {
  const StreakStats({required this.currentStreak, required this.longestStreak});

  final int currentStreak;
  final int longestStreak;
}
