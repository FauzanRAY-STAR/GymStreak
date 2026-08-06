import 'package:flutter_test/flutter_test.dart';
import 'package:gymstreak/app/data/database/database_helper.dart';
import 'package:gymstreak/app/data/repositories/recipe_recommendation_repository.dart';
import 'package:gymstreak/app/data/services/recipe_recommendation_service.dart';
import 'package:gymstreak/app/utils/clock_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FixedClock extends ClockService {
  FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUpAll(() async {
    DatabaseHelper.databaseFileName = 'test_recipe_recommendation_service.db';
    final databasesPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      p.join(databasesPath, DatabaseHelper.databaseFileName),
    );
  });

  setUp(() async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('recipe_recommendation_history');
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
  });

  test('rekomendasi tetap sama pada hari yang sama', () async {
    final date = DateTime(2026, 8, 6, 10);
    final service = RecipeRecommendationService(clock: FixedClock(date));

    final first = await service.getTodayRecommendation();
    final second = await service.getTodayRecommendation();

    expect(first, isNotNull);
    expect(second?.id, first?.id);

    final history = RecipeRecommendationRepository();
    expect(await history.countForDate(date), 1);
  });

  test('ganti menu menghasilkan resep yang berbeda', () async {
    final date = DateTime(2026, 8, 6, 10);
    final service = RecipeRecommendationService(clock: FixedClock(date));

    final first = await service.getTodayRecommendation();
    final changed = await service.changeTodayRecommendation();

    expect(first, isNotNull);
    expect(changed, isNotNull);
    expect(changed?.id, isNot(first?.id));

    final latest = await RecipeRecommendationRepository().getLatestForDate(
      date,
    );
    expect(latest?.changedManually, isTrue);
  });

  test('tujuh hari awal tidak mengulang resep', () async {
    final service = RecipeRecommendationService(
      clock: FixedClock(DateTime(2026, 8, 1)),
    );

    final ids = <String>{};
    for (var offset = 0; offset < 7; offset++) {
      final recipe = await service.getRecommendationFor(
        DateTime(2026, 8, 1 + offset),
      );
      expect(recipe, isNotNull);
      ids.add(recipe!.id);
    }

    expect(ids.length, 7);
  });
}
