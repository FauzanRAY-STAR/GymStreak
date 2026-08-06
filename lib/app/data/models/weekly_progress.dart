import '../../utils/app_date_utils.dart';

/// Rekap pencapaian target workout untuk satu minggu (Senin-Minggu).
/// `finalized` bernilai true setelah minggu tersebut benar-benar berakhir,
/// sehingga hasilnya tidak berubah lagi meski target minggu berikutnya diubah.
class WeeklyProgress {
  const WeeklyProgress({
    this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.targetAtThatTime,
    required this.completedWorkoutDays,
    required this.achieved,
    required this.finalized,
  });

  final int? id;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int targetAtThatTime;
  final int completedWorkoutDays;
  final bool achieved;
  final bool finalized;

  factory WeeklyProgress.fromMap(Map<String, dynamic> map) {
    return WeeklyProgress(
      id: map['id'] as int,
      weekStartDate: AppDateUtils.parseDateKey(
        map['week_start_date'] as String,
      ),
      weekEndDate: AppDateUtils.parseDateKey(map['week_end_date'] as String),
      targetAtThatTime: map['target_at_that_time'] as int,
      completedWorkoutDays: map['completed_workout_days'] as int,
      achieved: (map['achieved'] as int) == 1,
      finalized: (map['finalized'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'week_start_date': AppDateUtils.formatDateKey(weekStartDate),
      'week_end_date': AppDateUtils.formatDateKey(weekEndDate),
      'target_at_that_time': targetAtThatTime,
      'completed_workout_days': completedWorkoutDays,
      'achieved': achieved ? 1 : 0,
      'finalized': finalized ? 1 : 0,
    };
  }

  WeeklyProgress copyWith({
    int? completedWorkoutDays,
    bool? achieved,
    bool? finalized,
  }) {
    return WeeklyProgress(
      id: id,
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      targetAtThatTime: targetAtThatTime,
      completedWorkoutDays: completedWorkoutDays ?? this.completedWorkoutDays,
      achieved: achieved ?? this.achieved,
      finalized: finalized ?? this.finalized,
    );
  }
}
