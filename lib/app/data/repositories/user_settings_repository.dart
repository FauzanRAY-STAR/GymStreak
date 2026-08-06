import 'package:sqflite/sqflite.dart';

import '../database/database_helper.dart';
import '../models/user_settings.dart';

/// Pengaturan pengguna disimpan sebagai satu baris tunggal (id = 1).
class UserSettingsRepository {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<UserSettings?> getSettings() async {
    final db = await _db;
    final rows = await db.query('user_settings', where: 'id = 1');
    if (rows.isEmpty) return null;
    return UserSettings.fromMap(rows.first);
  }

  Future<void> saveSettings(UserSettings settings) async {
    final db = await _db;
    await db.insert(
      'user_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearSettings() async {
    final db = await _db;
    await db.delete('user_settings');
  }
}
