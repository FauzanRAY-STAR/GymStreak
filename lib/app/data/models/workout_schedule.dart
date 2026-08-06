/// Jadwal workout mingguan yang direncanakan pengguna.
class WorkoutSchedule {
  const WorkoutSchedule({
    this.id,
    required this.dayOfWeek,
    required this.workoutType,
    required this.reminderTime,
    required this.active,
  });

  final int? id;

  /// 1 = Senin ... 7 = Minggu.
  final int dayOfWeek;
  final String workoutType;

  /// Format 'HH:mm'.
  final String reminderTime;
  final bool active;

  factory WorkoutSchedule.fromMap(Map<String, dynamic> map) {
    return WorkoutSchedule(
      id: map['id'] as int,
      dayOfWeek: map['day_of_week'] as int,
      workoutType: map['workout_type'] as String,
      reminderTime: map['reminder_time'] as String,
      active: (map['active'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'day_of_week': dayOfWeek,
      'workout_type': workoutType,
      'reminder_time': reminderTime,
      'active': active ? 1 : 0,
    };
  }

  WorkoutSchedule copyWith({
    int? dayOfWeek,
    String? workoutType,
    String? reminderTime,
    bool? active,
  }) {
    return WorkoutSchedule(
      id: id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      workoutType: workoutType ?? this.workoutType,
      reminderTime: reminderTime ?? this.reminderTime,
      active: active ?? this.active,
    );
  }
}
