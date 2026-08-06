import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/workout_schedule.dart';

class WorkoutScheduleRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<WorkoutSchedule>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'workout_schedules',
      orderBy: 'day_of_week ASC',
    );
    return rows.map(WorkoutSchedule.fromMap).toList();
  }

  Future<List<WorkoutSchedule>> getActive() async {
    final db = await _db;
    final rows = await db.query(
      'workout_schedules',
      where: 'active = 1',
      orderBy: 'day_of_week ASC',
    );
    return rows.map(WorkoutSchedule.fromMap).toList();
  }

  Future<WorkoutSchedule?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'workout_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return WorkoutSchedule.fromMap(rows.first);
  }

  Future<int> insert(WorkoutSchedule schedule) async {
    final db = await _db;
    return db.insert('workout_schedules', schedule.toMap());
  }

  Future<void> update(WorkoutSchedule schedule) async {
    final db = await _db;
    await db.update(
      'workout_schedules',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('workout_schedules', where: 'id = ?', whereArgs: [id]);
  }
}
