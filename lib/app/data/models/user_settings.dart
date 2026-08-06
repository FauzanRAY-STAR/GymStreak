/// Pengaturan utama pengguna, disimpan sebagai satu baris (id selalu 1).
class UserSettings {
  const UserSettings({
    this.id = 1,
    required this.name,
    required this.weeklyTarget,
    required this.workoutDays,
    required this.reminderTime,
    required this.reminderEnabled,
    required this.secondReminderEnabled,
    required this.fitnessGoal,
    required this.onboardingCompleted,
  });

  final int id;
  final String name;
  final int weeklyTarget;

  /// Hari workout yang direncanakan, 1 = Senin ... 7 = Minggu.
  final List<int> workoutDays;

  /// Jam pengingat dalam format 'HH:mm'.
  final String reminderTime;
  final bool reminderEnabled;
  final bool secondReminderEnabled;
  final String fitnessGoal;
  final bool onboardingCompleted;

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as int,
      name: map['name'] as String,
      weeklyTarget: map['weekly_target'] as int,
      workoutDays: (map['workout_days'] as String)
          .split(',')
          .where((e) => e.isNotEmpty)
          .map(int.parse)
          .toList(),
      reminderTime: map['reminder_time'] as String,
      reminderEnabled: (map['reminder_enabled'] as int) == 1,
      secondReminderEnabled: (map['second_reminder_enabled'] as int) == 1,
      fitnessGoal: map['fitness_goal'] as String,
      onboardingCompleted: (map['onboarding_completed'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weekly_target': weeklyTarget,
      'workout_days': workoutDays.join(','),
      'reminder_time': reminderTime,
      'reminder_enabled': reminderEnabled ? 1 : 0,
      'second_reminder_enabled': secondReminderEnabled ? 1 : 0,
      'fitness_goal': fitnessGoal,
      'onboarding_completed': onboardingCompleted ? 1 : 0,
    };
  }

  UserSettings copyWith({
    String? name,
    int? weeklyTarget,
    List<int>? workoutDays,
    String? reminderTime,
    bool? reminderEnabled,
    bool? secondReminderEnabled,
    String? fitnessGoal,
    bool? onboardingCompleted,
  }) {
    return UserSettings(
      id: id,
      name: name ?? this.name,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      workoutDays: workoutDays ?? this.workoutDays,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      secondReminderEnabled:
          secondReminderEnabled ?? this.secondReminderEnabled,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
