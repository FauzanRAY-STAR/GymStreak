import 'package:flutter_test/flutter_test.dart';
import 'package:gymstreak/app/data/database/database_helper.dart';
import 'package:gymstreak/app/data/models/recipe_recommendation_history.dart';
import 'package:gymstreak/app/data/models/user_settings.dart';
import 'package:gymstreak/app/data/models/weekly_progress.dart';
import 'package:gymstreak/app/data/models/workout_schedule.dart';
import 'package:gymstreak/app/data/models/workout_session.dart';
import 'package:gymstreak/app/data/repositories/recipe_recommendation_repository.dart';
import 'package:gymstreak/app/data/repositories/recipe_repository.dart';
import 'package:gymstreak/app/data/repositories/user_settings_repository.dart';
import 'package:gymstreak/app/data/repositories/weekly_progress_repository.dart';
import 'package:gymstreak/app/data/repositories/workout_schedule_repository.dart';
import 'package:gymstreak/app/data/repositories/workout_session_repository.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Smoke test end-to-end untuk lapisan database: memastikan skema tabel,
// seeding 30 resep, dan CRUD dasar tiap repository benar-benar berfungsi
// di atas SQLite sungguhan (bukan hanya lolos flutter analyze).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() async {
    // Nama file unik per file test agar tidak saling bentrok dengan file
    // test lain yang mengakses database secara bersamaan.
    DatabaseHelper.databaseFileName = 'test_database_helper.db';
    // Pastikan tidak ada sisa database dari test run sebelumnya.
    final databasesPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      p.join(databasesPath, DatabaseHelper.databaseFileName),
    );
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  test(
    'seed menghasilkan 30 resep dengan pembagian bahan utama yang benar',
    () async {
      final repo = RecipeRepository();
      final all = await repo.getAll();
      expect(all.length, 30);

      final counts = <String, int>{};
      for (final recipe in all) {
        counts[recipe.mainIngredient] =
            (counts[recipe.mainIngredient] ?? 0) + 1;
      }
      expect(counts['Dada Ayam'], 8);
      expect(counts['Telur'], 8);
      expect(counts['Tempe'], 7);
      expect(counts['Tahu'], 7);
    },
  );

  test(
    'seed tidak berjalan ulang ketika database sudah pernah dibuka',
    () async {
      final repo = RecipeRepository();
      // Membuka koneksi database untuk kedua kalinya seharusnya memakai
      // singleton yang sama, bukan memicu onCreate/seed lagi.
      final countBefore = await repo.count();
      final db = await DatabaseHelper.instance.database;
      expect(db.isOpen, isTrue);
      final countAfter = await repo.count();
      expect(countAfter, countBefore);
    },
  );

  test('favorit resep bisa diaktifkan dan dibaca kembali', () async {
    final repo = RecipeRepository();
    final all = await repo.getAll();
    final target = all.first;

    await repo.setFavorite(target.id, true);
    final favorites = await repo.getFavorites();
    expect(favorites.any((r) => r.id == target.id), isTrue);

    await repo.setFavorite(target.id, false);
    final favoritesAfter = await repo.getFavorites();
    expect(favoritesAfter.any((r) => r.id == target.id), isFalse);
  });

  test('pencarian dan filter resep bekerja', () async {
    final repo = RecipeRepository();
    final searchResult = await repo.search('Tempe');
    expect(searchResult, isNotEmpty);
    expect(searchResult.every((r) => r.name.contains('Tempe')), isTrue);

    final filtered = await repo.filter(
      mainIngredient: 'Telur',
      difficulty: 'Mudah',
    );
    expect(filtered, isNotEmpty);
    expect(
      filtered.every(
        (r) => r.mainIngredient == 'Telur' && r.difficulty == 'Mudah',
      ),
      isTrue,
    );
  });

  test('CRUD UserSettings menyimpan sebagai satu baris tunggal', () async {
    final repo = UserSettingsRepository();
    expect(await repo.getSettings(), isNull);

    const settings = UserSettings(
      name: 'Victor',
      weeklyTarget: 4,
      workoutDays: [1, 3, 5, 6],
      reminderTime: '18:30',
      reminderEnabled: true,
      secondReminderEnabled: false,
      fitnessGoal: 'Bulking',
      onboardingCompleted: true,
    );
    await repo.saveSettings(settings);

    final saved = await repo.getSettings();
    expect(saved, isNotNull);
    expect(saved!.name, 'Victor');
    expect(saved.workoutDays, [1, 3, 5, 6]);

    final updated = saved.copyWith(weeklyTarget: 5);
    await repo.saveSettings(updated);
    final resaved = await repo.getSettings();
    expect(resaved!.weeklyTarget, 5);
  });

  test('CRUD WorkoutSchedule', () async {
    final repo = WorkoutScheduleRepository();
    final id = await repo.insert(
      const WorkoutSchedule(
        dayOfWeek: 1,
        workoutType: 'Push Day',
        reminderTime: '18:00',
        active: true,
      ),
    );

    final all = await repo.getAll();
    expect(all.any((s) => s.id == id), isTrue);

    final fetched = await repo.getById(id);
    await repo.update(fetched!.copyWith(active: false));
    final active = await repo.getActive();
    expect(active.any((s) => s.id == id), isFalse);

    await repo.delete(id);
    expect(await repo.getById(id), isNull);
  });

  test('CRUD WorkoutSession per tanggal', () async {
    final repo = WorkoutSessionRepository();
    final date = DateTime(2026, 8, 3);
    final id = await repo.insert(
      WorkoutSession(
        workoutDate: date,
        workoutType: 'Leg Day',
        durationMinutes: 45,
        intensity: WorkoutIntensity.berat,
        createdAt: date,
        updatedAt: date,
      ),
    );

    final byDate = await repo.getByDate(date);
    expect(byDate.length, 1);
    expect(byDate.first.id, id);

    await repo.update(byDate.first.copyWith(durationMinutes: 60));
    final updated = await repo.getByDate(date);
    expect(updated.first.durationMinutes, 60);

    await repo.delete(id);
    expect(await repo.getByDate(date), isEmpty);
  });

  test('upsert WeeklyProgress berdasarkan week_start_date', () async {
    final repo = WeeklyProgressRepository();
    final weekStart = DateTime(2026, 8, 3);
    final weekEnd = DateTime(2026, 8, 9);

    await repo.upsert(
      WeeklyProgress(
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        targetAtThatTime: 4,
        completedWorkoutDays: 2,
        achieved: false,
        finalized: false,
      ),
    );

    final first = await repo.getByWeekStart(weekStart);
    expect(first!.completedWorkoutDays, 2);

    await repo.upsert(first.copyWith(completedWorkoutDays: 4, achieved: true));
    final second = await repo.getByWeekStart(weekStart);
    expect(second!.completedWorkoutDays, 4);
    expect(second.achieved, isTrue);

    final all = await repo.getAll();
    expect(all.where((w) => w.weekStartDate == weekStart).length, 1);
  });

  test(
    'riwayat rekomendasi resep tercatat dan bisa dibaca 7 hari terakhir',
    () async {
      final repo = RecipeRecommendationRepository();
      final recipeRepo = RecipeRepository();
      final recipes = await recipeRepo.getAll();
      final recipeId = recipes.first.id;

      final today = DateTime(2026, 8, 6);
      await repo.insert(
        RecipeRecommendationHistory(
          recipeId: recipeId,
          recommendationDate: today,
          changedManually: false,
        ),
      );

      final latest = await repo.getLatestForDate(today);
      expect(latest!.recipeId, recipeId);

      final recentIds = await repo.getRecentRecipeIds(
        today.subtract(const Duration(days: 6)),
      );
      expect(recentIds, contains(recipeId));
    },
  );
}
