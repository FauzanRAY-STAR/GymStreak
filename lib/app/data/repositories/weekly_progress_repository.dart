import 'package:sqflite/sqflite.dart';

import '../../utils/app_date_utils.dart';
import '../database/database_helper.dart';
import '../models/weekly_progress.dart';

class WeeklyProgressRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<WeeklyProgress?> getByWeekStart(DateTime weekStart) async {
    final db = await _db;
    final rows = await db.query(
      'weekly_progress',
      where: 'week_start_date = ?',
      whereArgs: [AppDateUtils.formatDateKey(weekStart)],
    );
    if (rows.isEmpty) return null;
    return WeeklyProgress.fromMap(rows.first);
  }

  Future<List<WeeklyProgress>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'weekly_progress',
      orderBy: 'week_start_date DESC',
    );
    return rows.map(WeeklyProgress.fromMap).toList();
  }

  Future<List<WeeklyProgress>> getFinalized() async {
    final db = await _db;
    final rows = await db.query(
      'weekly_progress',
      where: 'finalized = 1',
      orderBy: 'week_start_date DESC',
    );
    return rows.map(WeeklyProgress.fromMap).toList();
  }

  /// Insert baru jika `week_start_date` belum ada, atau update baris yang
  /// sudah ada (upsert berdasarkan unique constraint week_start_date).
  Future<void> upsert(WeeklyProgress progress) async {
    final db = await _db;
    await db.insert(
      'weekly_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
