import 'package:sqflite/sqflite.dart';

import '../../utils/app_date_utils.dart';
import '../database/database_helper.dart';
import '../models/recipe_recommendation_history.dart';

class RecipeRecommendationRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<int> insert(RecipeRecommendationHistory history) async {
    final db = await _db;
    return db.insert('recipe_recommendation_history', history.toMap());
  }

  /// Rekomendasi terakhir yang tercatat pada [date] (jika ada). Karena
  /// tombol "Ganti Menu" bisa menghasilkan beberapa baris pada hari yang
  /// sama, ambil baris dengan id terbesar (paling baru).
  Future<RecipeRecommendationHistory?> getLatestForDate(DateTime date) async {
    final db = await _db;
    final rows = await db.query(
      'recipe_recommendation_history',
      where: 'recommendation_date = ?',
      whereArgs: [AppDateUtils.formatDateKey(date)],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RecipeRecommendationHistory.fromMap(rows.first);
  }

  Future<int> countForDate(DateTime date) async {
    final db = await _db;
    final rows = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM recipe_recommendation_history
      WHERE recommendation_date = ?
      ''',
      [AppDateUtils.formatDateKey(date)],
    );
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  /// ID resep yang pernah direkomendasikan sejak [since] (inklusif) sampai
  /// hari ini, dipakai untuk menghindari pengulangan dalam 7 hari terakhir.
  Future<List<String>> getRecentRecipeIds(DateTime since) async {
    final db = await _db;
    final rows = await db.query(
      'recipe_recommendation_history',
      columns: ['DISTINCT recipe_id'],
      where: 'recommendation_date >= ?',
      whereArgs: [AppDateUtils.formatDateKey(since)],
    );
    return rows.map((row) => row['recipe_id'] as String).toList();
  }

  Future<List<RecipeRecommendationHistory>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'recipe_recommendation_history',
      orderBy: 'recommendation_date DESC, id DESC',
    );
    return rows.map(RecipeRecommendationHistory.fromMap).toList();
  }
}
