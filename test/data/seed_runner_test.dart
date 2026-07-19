import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
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

      // D-4: 5 placeholder exercises, one per ExerciseType, until real content
      // (Q-1) arrives.
      expect(exercises, hasLength(5));
      expect(exercises.map((exercise) => exercise.exerciseType).toSet(), {
        'strength',
        'cardio',
        'reps',
        'time',
        'stretch',
      });
      expect(exercises.every((exercise) => exercise.isBuiltIn), isTrue);
      expect(secondaryMuscles, isNotEmpty);
      expect(l10n, hasLength(10)); // 5 exercises x 2 locales (ru, en)
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
    expect(exercises, hasLength(5));
    expect(l10n, hasLength(10));
  });
}
