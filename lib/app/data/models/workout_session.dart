import '../../utils/app_date_utils.dart';

enum WorkoutIntensity { ringan, sedang, berat }

extension WorkoutIntensityX on WorkoutIntensity {
  String get dbValue => name;

  String get label {
    switch (this) {
      case WorkoutIntensity.ringan:
        return 'Ringan';
      case WorkoutIntensity.sedang:
        return 'Sedang';
      case WorkoutIntensity.berat:
        return 'Berat';
    }
  }

  static WorkoutIntensity fromDb(String value) {
    return WorkoutIntensity.values.firstWhere(
      (e) => e.dbValue == value,
      orElse: () => WorkoutIntensity.sedang,
    );
  }
}

/// Satu catatan workout yang sudah diselesaikan pengguna.
class WorkoutSession {
  const WorkoutSession({
    this.id,
    required this.workoutDate,
    required this.workoutType,
    required this.durationMinutes,
    required this.intensity,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final DateTime workoutDate;
  final String workoutType;
  final int durationMinutes;
  final WorkoutIntensity intensity;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'] as int,
      workoutDate: AppDateUtils.parseDateKey(map['workout_date'] as String),
      workoutType: map['workout_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      intensity: WorkoutIntensityX.fromDb(map['intensity'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'workout_date': AppDateUtils.formatDateKey(workoutDate),
      'workout_type': workoutType,
      'duration_minutes': durationMinutes,
      'intensity': intensity.dbValue,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkoutSession copyWith({
    DateTime? workoutDate,
    String? workoutType,
    int? durationMinutes,
    WorkoutIntensity? intensity,
    String? notes,
    DateTime? updatedAt,
  }) {
    return WorkoutSession(
      id: id,
      workoutDate: workoutDate ?? this.workoutDate,
      workoutType: workoutType ?? this.workoutType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
