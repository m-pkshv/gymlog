import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/seed/exercise_seed.dart';
import 'package:gymlog/data/seed/reference_data_seed.dart';
import 'package:gymlog/data/seed/seed_runner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'first run inserts reference data and the placeholder exercises',
    () async {
      await SeedRunner(db).run();

      final muscleGroups = await db.select(db.muscleGroups).get();
      final equipments = await db.select(db.equipments).get();
      final measurementTypes = await db.select(db.measurementTypes).get();
      final exercises = await db.select(db.exercises).get();
      final secondaryMuscles = await db
          .select(db.exerciseSecondaryMuscles)
          .get();
      final l10n = await db.select(db.exerciseL10n).get();
      final seedInfo = await db.select(db.seedInfoTable).getSingle();

      expect(muscleGroups, hasLength(13));
      expect(equipments, hasLength(9));
      expect(measurementTypes, hasLength(15));

      // Q-1: first real batch from the owner (9 exercises, 2026-07-20),
      // replacing the old 5-placeholder set.
      expect(exercises, hasLength(9));
      expect(exercises.every((exercise) => exercise.exerciseType == 'strength'), isTrue);
      expect(exercises.every((exercise) => exercise.isBuiltIn), isTrue);
      expect(exercises.map((exercise) => exercise.id), contains('barbell_back_squat'));
      expect(secondaryMuscles, isNotEmpty);
      expect(l10n, hasLength(18)); // 9 exercises x 2 locales (ru, en)
      expect(l10n.map((row) => row.locale).toSet(), {'ru', 'en'});
      expect(seedInfo.seedVersion, currentSeedVersion);
    },
  );

  test('running the seed twice does not duplicate rows', () async {
    await SeedRunner(db).run();
    await SeedRunner(db).run();

    final muscleGroups = await db.select(db.muscleGroups).get();
    final exercises = await db.select(db.exercises).get();
    final l10n = await db.select(db.exerciseL10n).get();

    expect(muscleGroups, hasLength(13));
    expect(exercises, hasLength(9));
    expect(l10n, hasLength(18));
  });

  test(
    'insertExerciseSeed can re-run against an already-seeded DB without '
    'erroring, preserving isArchived and not duplicating child rows',
    () async {
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);

      // Simulate the owner having archived one of the built-in exercises.
      await (db.update(
        db.exercises,
      )..where((e) => e.id.equals('barbell_back_squat'))).write(
        const ExercisesCompanion(isArchived: Value(true)),
      );

      // Re-running the seed (e.g. a content update bumping the version on
      // an install that already has this exercise) must not un-archive it,
      // must not error on the primary-key conflict, and must not duplicate
      // the secondary-muscle/localized-name child rows.
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);

      final squat = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('barbell_back_squat'))).getSingle();
      expect(squat.isArchived, isTrue);

      final exercises = await db.select(db.exercises).get();
      final secondaryMuscles = await db
          .select(db.exerciseSecondaryMuscles)
          .get();
      final l10n = await db.select(db.exerciseL10n).get();
      expect(exercises, hasLength(9));
      expect(l10n, hasLength(18));
      expect(
        secondaryMuscles
            .where((row) => row.exerciseId == 'barbell_back_squat')
            .length,
        3, // glutes, hamstrings, abs — not duplicated by the re-run
      );
    },
  );
}
