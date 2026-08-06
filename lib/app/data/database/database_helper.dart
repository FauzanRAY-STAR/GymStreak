import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Mengelola koneksi database SQLite tunggal, pembuatan skema tabel, dan
/// seeding data resep awal. Seeding dijalankan setelah [openDatabase] benar-
/// benar selesai (bukan di dalam callback [_onCreate]) karena memanggil
/// platform channel lain (pemuatan asset lewat `rootBundle`) dari dalam
/// callback `onCreate`/`onUpgrade` milik sqflite berisiko konflik dengan
/// mekanisme callback native Android. [_seedRecipesIfNeeded] memeriksa
/// jumlah baris terlebih dahulu sehingga seed tidak pernah berjalan ulang.
class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Non-const (bukan sekadar final) agar test dapat mengisolasi setiap file
  // test ke database fisik miliknya sendiri dan menghindari interferensi
  // saat beberapa file test berjalan bersamaan. Kode aplikasi tidak pernah
  // mengubah nilai ini.
  static String databaseFileName = 'gymstreak.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseFileName);
    final db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    // Beri jeda tunggu jika ada operasi lain yang sedang mengunci database
    // (mis. transaksi lain berjalan bersamaan) alih-alih langsung gagal
    // dengan error "database is locked". PRAGMA ini mengembalikan baris
    // hasil, jadi harus lewat rawQuery, bukan execute.
    await db.rawQuery('PRAGMA busy_timeout = 5000');
    await _seedRecipesIfNeeded(db);
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        weekly_target INTEGER NOT NULL,
        workout_days TEXT NOT NULL,
        reminder_time TEXT NOT NULL,
        reminder_enabled INTEGER NOT NULL DEFAULT 1,
        second_reminder_enabled INTEGER NOT NULL DEFAULT 0,
        fitness_goal TEXT NOT NULL,
        onboarding_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week INTEGER NOT NULL,
        workout_type TEXT NOT NULL,
        reminder_time TEXT NOT NULL,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_date TEXT NOT NULL,
        workout_type TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        intensity TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_workout_sessions_date ON workout_sessions(workout_date)',
    );

    await db.execute('''
      CREATE TABLE weekly_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        week_start_date TEXT NOT NULL UNIQUE,
        week_end_date TEXT NOT NULL,
        target_at_that_time INTEGER NOT NULL,
        completed_workout_days INTEGER NOT NULL DEFAULT 0,
        achieved INTEGER NOT NULL DEFAULT 0,
        finalized INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        main_ingredient TEXT NOT NULL,
        ingredients TEXT NOT NULL,
        steps TEXT NOT NULL,
        servings INTEGER NOT NULL,
        estimated_protein REAL NOT NULL,
        estimated_calories REAL NOT NULL,
        cooking_time_minutes INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        categories TEXT NOT NULL,
        image_asset TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_recommendation_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id TEXT NOT NULL,
        recommendation_date TEXT NOT NULL,
        changed_manually INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // TODO(migration): tambahkan blok `if (oldVersion < N) { ... }` di sini
    // ketika skema tabel berubah pada versi database berikutnya.
  }

  Future<void> _seedRecipesIfNeeded(Database db) async {
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM recipes',
    );
    final existing = Sqflite.firstIntValue(countResult) ?? 0;
    if (existing > 0) return;

    final jsonString = await rootBundle.loadString('assets/data/recipes.json');
    final List<dynamic> recipes = jsonDecode(jsonString) as List<dynamic>;

    final batch = db.batch();
    for (final item in recipes) {
      final map = item as Map<String, dynamic>;
      batch.insert('recipes', {
        'id': map['id'],
        'name': map['name'],
        'description': map['description'],
        'main_ingredient': map['mainIngredient'],
        'ingredients': jsonEncode(map['ingredients']),
        'steps': jsonEncode(map['steps']),
        'servings': map['servings'],
        'estimated_protein': map['estimatedProtein'],
        'estimated_calories': map['estimatedCalories'],
        'cooking_time_minutes': map['cookingTimeMinutes'],
        'difficulty': map['difficulty'],
        'categories': jsonEncode(map['categories']),
        'image_asset': map['imageAsset'],
        'is_favorite': 0,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Menghapus seluruh data milik pengguna (pengaturan, jadwal, riwayat
  /// workout, weekly progress, riwayat rekomendasi, dan status favorit).
  /// Katalog resep itu sendiri tidak dihapus karena merupakan konten
  /// bawaan aplikasi, bukan data pengguna.
  Future<void> resetUserData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('user_settings');
      await txn.delete('workout_schedules');
      await txn.delete('workout_sessions');
      await txn.delete('weekly_progress');
      await txn.delete('recipe_recommendation_history');
      await txn.update('recipes', {'is_favorite': 0});
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
