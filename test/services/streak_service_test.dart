import 'package:flutter_test/flutter_test.dart';
import 'package:gymstreak/app/data/database/database_helper.dart';
import 'package:gymstreak/app/data/models/workout_session.dart';
import 'package:gymstreak/app/data/repositories/weekly_progress_repository.dart';
import 'package:gymstreak/app/data/repositories/workout_session_repository.dart';
import 'package:gymstreak/app/data/services/streak_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../fakes/fake_clock_service.dart';

Future<void> _addSession(WorkoutSessionRepository repo, DateTime date) {
  return repo.insert(
    WorkoutSession(
      workoutDate: date,
      workoutType: 'Full Body',
      durationMinutes: 30,
      intensity: WorkoutIntensity.sedang,
      createdAt: date,
      updatedAt: date,
    ),
  );
}

void main() {
  late FakeClockService clock;
  late StreakService service;
  late WorkoutSessionRepository sessionRepo;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // Nama file unik per file test agar tidak saling bentrok dengan file
    // test lain yang mengakses database secara bersamaan.
    DatabaseHelper.databaseFileName = 'test_streak_service.db';
    final databasesPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      p.join(databasesPath, DatabaseHelper.databaseFileName),
    );
  });

  setUp(() async {
    // Setiap test mulai dari tabel bersih agar tidak saling memengaruhi.
    final db = await DatabaseHelper.instance.database;
    await db.delete('workout_sessions');
    await db.delete('weekly_progress');

    clock = FakeClockService(DateTime(2026, 8, 3)); // Senin
    sessionRepo = WorkoutSessionRepository();
    service = StreakService(
      clock: clock,
      workoutSessionRepository: sessionRepo,
      weeklyProgressRepository: WeeklyProgressRepository(),
    );
  });

  test('1. Rest day tidak mematikan streak', () async {
    // Senin & Rabu workout, Selasa rest day (tidak ada sesi).
    await _addSession(sessionRepo, DateTime(2026, 8, 3));
    await _addSession(sessionRepo, DateTime(2026, 8, 5));

    final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 2);

    expect(progress.completedWorkoutDays, 2);
    expect(progress.achieved, isTrue);
  });

  test('2. Minggu yang masih berjalan tidak mereset streak', () async {
    // Minggu 27 Jul - 2 Agu tercapai dan sudah final.
    for (final day in [27, 28, 29, 30]) {
      await _addSession(sessionRepo, DateTime(2026, 7, day));
    }
    clock.setNow(DateTime(2026, 8, 3));
    await service.recalculateWeek(DateTime(2026, 7, 27), 4);

    // Minggu berjalan (3-9 Agu) baru 1 hari dan belum berakhir.
    await _addSession(sessionRepo, DateTime(2026, 8, 3));
    final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 4);
    expect(progress.finalized, isFalse);

    final streak = await service.getCurrentStreak();
    expect(
      streak,
      1,
      reason: 'minggu berjalan belum final, streak lama tidak boleh hilang',
    );
  });

  test('3. Target 4 dari 4 membuat weekly streak bertambah', () async {
    for (final day in [3, 4, 5, 7]) {
      await _addSession(sessionRepo, DateTime(2026, 8, day));
    }
    clock.setNow(
      DateTime(2026, 8, 10),
    ); // minggu berikutnya, 3-9 Agu sudah lewat

    final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 4);
    expect(progress.finalized, isTrue);
    expect(progress.achieved, isTrue);

    final streak = await service.getCurrentStreak();
    expect(streak, 1);
  });

  test(
    '4. Target 3 dari 4 membuat streak reset setelah minggu selesai',
    () async {
      for (final day in [3, 4, 5]) {
        await _addSession(sessionRepo, DateTime(2026, 8, day));
      }
      clock.setNow(DateTime(2026, 8, 10));

      final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 4);
      expect(progress.achieved, isFalse);

      final streak = await service.getCurrentStreak();
      expect(streak, 0);
    },
  );

  test(
    '5. Workout yang dilakukan pada hari pengganti tetap dihitung',
    () async {
      // Sempat bolong di Selasa/Kamis, tapi diganti Sabtu & Minggu di minggu
      // yang sama tetap dihitung memenuhi target.
      await _addSession(sessionRepo, DateTime(2026, 8, 3)); // Senin
      await _addSession(sessionRepo, DateTime(2026, 8, 5)); // Rabu
      await _addSession(sessionRepo, DateTime(2026, 8, 8)); // Sabtu (pengganti)
      await _addSession(
        sessionRepo,
        DateTime(2026, 8, 9),
      ); // Minggu (pengganti)
      clock.setNow(DateTime(2026, 8, 10));

      final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 4);
      expect(progress.completedWorkoutDays, 4);
      expect(progress.achieved, isTrue);
    },
  );

  test(
    '6. Beberapa workout pada tanggal yang sama hanya dihitung satu kali',
    () async {
      await _addSession(sessionRepo, DateTime(2026, 8, 3));
      await _addSession(sessionRepo, DateTime(2026, 8, 3));
      await _addSession(sessionRepo, DateTime(2026, 8, 3));

      final progress = await service.recalculateWeek(DateTime(2026, 8, 3), 4);
      expect(progress.completedWorkoutDays, 1);
    },
  );

  test(
    '7. Perubahan target tidak mengubah hasil minggu yang telah difinalisasi',
    () async {
      for (final day in [3, 4, 5]) {
        await _addSession(sessionRepo, DateTime(2026, 8, day));
      }
      clock.setNow(DateTime(2026, 8, 10));

      final finalized = await service.recalculateWeek(DateTime(2026, 8, 3), 3);
      expect(finalized.finalized, isTrue);
      expect(finalized.achieved, isTrue);
      expect(finalized.targetAtThatTime, 3);

      // Target minggu berikutnya berubah jadi 6; minggu yang sudah final
      // tidak boleh terpengaruh.
      final recalculated = await service.recalculateWeek(
        DateTime(2026, 8, 3),
        6,
      );
      expect(recalculated.targetAtThatTime, 3);
      expect(recalculated.achieved, isTrue);
    },
  );

  test(
    'longest streak mengikuti rangkaian minggu tercapai terpanjang',
    () async {
      // Minggu 1 (20-26 Jul): tercapai.
      for (final day in [20, 21, 22, 23]) {
        await _addSession(sessionRepo, DateTime(2026, 7, day));
      }
      // Minggu 2 (27 Jul - 2 Agu): gagal (hanya 1 hari).
      await _addSession(sessionRepo, DateTime(2026, 7, 27));
      // Minggu 3 (3-9 Agu): tercapai.
      for (final day in [3, 4, 5, 6]) {
        await _addSession(sessionRepo, DateTime(2026, 8, day));
      }
      // Minggu 4 (10-16 Agu): tercapai.
      for (final day in [10, 11, 12, 13]) {
        await _addSession(sessionRepo, DateTime(2026, 8, day));
      }

      clock.setNow(DateTime(2026, 8, 17));
      await service.recalculateWeek(DateTime(2026, 7, 20), 4);
      await service.recalculateWeek(DateTime(2026, 7, 27), 4);
      await service.recalculateWeek(DateTime(2026, 8, 3), 4);
      await service.recalculateWeek(DateTime(2026, 8, 10), 4);

      final longest = await service.getLongestStreak();
      expect(longest, 2); // minggu 3 & 4 berturut-turut

      final current = await service.getCurrentStreak();
      expect(current, 2); // minggu 3 & 4 juga yang terbaru
    },
  );
}
