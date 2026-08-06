import 'package:get/get.dart';

import '../../utils/app_date_utils.dart';
import '../../utils/clock_service.dart';
import '../models/weekly_progress.dart';
import '../repositories/weekly_progress_repository.dart';
import '../repositories/workout_session_repository.dart';

/// Batas aman berapa minggu ke belakang yang akan diperiksa/diisi ulang
/// (backfill) saat menyinkronkan weekly progress, agar tidak melakukan query
/// tak terbatas jika aplikasi lama tidak dibuka.
const int _maxBackfillWeeks = 104;

/// Menghitung dan menyimpan progress target mingguan (weekly streak),
/// terpisah dari sekadar "konsistensi workout" harian. Aturan utamanya:
/// - Minggu dihitung Senin s.d. Minggu.
/// - Satu hari maksimal dihitung satu kali walau ada beberapa workout.
/// - Rest day (tidak ada sesi) bersifat netral: tidak menambah, tidak
///   mematikan streak.
/// - Sebuah minggu baru "final" setelah minggu tersebut benar-benar
///   berakhir; hasil minggu yang sudah final tidak berubah lagi meskipun
///   target minggu berikutnya diganti.
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

  /// Menghitung ulang dan menyimpan progress minggu yang memuat [date].
  /// Tidak melakukan apa pun jika minggu tersebut sudah final (dikunci).
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
        .map((s) => AppDateUtils.formatDateKey(s.workoutDate))
        .toSet()
        .length;

    final today = AppDateUtils.dateOnly(_clock.now());
    final isWeekOver = today.isAfter(weekEnd);
    // Target minggu ini dikunci ke nilai pertama kali baris ini dibuat, agar
    // perubahan target di kemudian hari tidak mengubah evaluasi minggu ini.
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

  /// Menyinkronkan minggu berjalan dan mengisi ulang (backfill) minggu-minggu
  /// lampau yang belum pernah final agar weekly streak tetap akurat walau
  /// aplikasi sempat tidak dibuka selama beberapa minggu.
  Future<void> syncWeeklyProgress(int currentTarget) async {
    final today = AppDateUtils.dateOnly(_clock.now());
    await recalculateWeek(today, currentTarget);

    var cursor = AppDateUtils.startOfWeek(
      today,
    ).subtract(const Duration(days: 7));
    for (var i = 0; i < _maxBackfillWeeks; i++) {
      final existing = await _weeklyProgressRepository.getByWeekStart(cursor);
      if (existing != null && existing.finalized) break;
      await recalculateWeek(cursor, currentTarget);
      cursor = cursor.subtract(const Duration(days: 7));
    }
  }

  /// Weekly streak saat ini: jumlah minggu final berturut-turut (dari yang
  /// paling baru) yang mencapai target, berhenti pada minggu final pertama
  /// yang gagal.
  Future<int> getCurrentStreak() async {
    final finalizedWeeks = await _weeklyProgressRepository.getFinalized();
    var streak = 0;
    for (final week in finalizedWeeks) {
      if (!week.achieved) break;
      streak++;
    }
    return streak;
  }

  /// Weekly streak terpanjang sepanjang riwayat minggu final.
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

  /// Statistik ringkas untuk halaman Profil/Beranda.
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
