import 'package:sqflite/sqflite.dart';

import '../../utils/app_date_utils.dart';
import '../database/database_helper.dart';
import '../models/workout_session.dart';

class WorkoutSessionRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<WorkoutSession>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'workout_sessions',
      orderBy: 'workout_date DESC, id DESC',
    );
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<List<WorkoutSession>> getByDate(DateTime date) async {
    final db = await _db;

    final rows = await db.query(
      'workout_sessions',
      where: 'workout_date = ?',
      whereArgs: [AppDateUtils.formatDateKey(date)],
      orderBy: 'id DESC',
    );

    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<WorkoutSession?> getOneByDate(DateTime date) async {
    final sessions = await getByDate(date);

    if (sessions.isEmpty) {
      return null;
    }

    return sessions.first;
  }

  Future<bool> existsOnDate(
      DateTime date, {
        int? excludeId,
      }) async {
    final db = await _db;

    final rows = await db.query(
      'workout_sessions',
      columns: ['id'],
      where: excludeId == null
          ? 'workout_date = ?'
          : 'workout_date = ? AND id != ?',
      whereArgs: excludeId == null
          ? [AppDateUtils.formatDateKey(date)]
          : [
        AppDateUtils.formatDateKey(date),
        excludeId,
      ],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<List<WorkoutSession>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'workout_sessions',
      where: 'workout_date BETWEEN ? AND ?',
      whereArgs: [
        AppDateUtils.formatDateKey(start),
        AppDateUtils.formatDateKey(end),
      ],
      orderBy: 'workout_date ASC, id ASC',
    );
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<List<WorkoutSession>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    return getByDateRange(start, end);
  }

  Future<List<WorkoutSession>> getRecent(int limit) async {
    final db = await _db;
    final rows = await db.query(
      'workout_sessions',
      orderBy: 'workout_date DESC, id DESC',
      limit: limit,
    );
    return rows.map(WorkoutSession.fromMap).toList();
  }

  Future<DateTime?> getOldestWorkoutDate() async {
    final db = await _db;
    final rows = await db.query(
      'workout_sessions',
      columns: ['workout_date'],
      orderBy: 'workout_date ASC, id ASC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppDateUtils.parseDateKey(rows.first['workout_date'] as String);
  }

  Future<int> insert(WorkoutSession session) async {
    final db = await _db;
    return db.insert('workout_sessions', session.toMap());
  }

  Future<void> update(WorkoutSession session) async {
    final db = await _db;
    await db.update(
      'workout_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete('workout_sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM workout_sessions',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
