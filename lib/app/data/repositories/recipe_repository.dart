import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/recipe.dart';

class RecipeRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<List<Recipe>> getAll() async {
    final db = await _db;
    final rows = await db.query('recipes', orderBy: 'name ASC');
    return rows.map(Recipe.fromMap).toList();
  }

  Future<Recipe?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('recipes', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Recipe.fromMap(rows.first);
  }

  Future<List<Recipe>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await _db;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.query(
      'recipes',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return rows.map(Recipe.fromMap).toList();
  }

  Future<List<Recipe>> search(String query) async {
    final db = await _db;
    final rows = await db.query(
      'recipes',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map(Recipe.fromMap).toList();
  }

  /// Filter resep berdasarkan kombinasi kriteria opsional. Semua kriteria
  /// yang diisi akan digabung dengan AND.
  Future<List<Recipe>> filter({
    String? mainIngredient,
    String? category,
    int? maxCookingTimeMinutes,
    String? difficulty,
  }) async {
    final all = await getAll();
    return all.where((recipe) {
      if (mainIngredient != null && recipe.mainIngredient != mainIngredient) {
        return false;
      }
      if (category != null && !recipe.categories.contains(category)) {
        return false;
      }
      if (maxCookingTimeMinutes != null &&
          recipe.cookingTimeMinutes > maxCookingTimeMinutes) {
        return false;
      }
      if (difficulty != null && recipe.difficulty != difficulty) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<List<Recipe>> getFavorites() async {
    final db = await _db;
    final rows = await db.query(
      'recipes',
      where: 'is_favorite = 1',
      orderBy: 'name ASC',
    );
    return rows.map(Recipe.fromMap).toList();
  }

  Future<void> setFavorite(String id, bool isFavorite) async {
    final db = await _db;
    await db.update(
      'recipes',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count() async {
    final db = await _db;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM recipes');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
