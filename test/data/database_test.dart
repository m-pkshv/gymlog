import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('schema creation', () {
    test('creates every table from 06_DATA_MODEL.md sections 5-6', () async {
      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      final tableNames = rows.map((row) => row.read<String>('name')).toSet();

      const expectedTables = {
        'MuscleGroups',
        'Equipments',
        'MeasurementTypes',
        'Exercises',
        'ExerciseSecondaryMuscles',
        'WorkoutTags',
        'Workouts',
        'WorkoutTagLinks',
        'WorkoutExercises',
        'ExerciseSets',
        'WorkoutTemplates',
        'TemplateExercises',
        'TemplateSets',
        'BodyMeasurements',
        'PersonalRecords',
        'ExerciseProgressionStates',
        'AppSettingsTable',
        'ImportExportOperations',
        'SeedInfoTable',
        'ActiveWorkoutStates',
      };

      expect(tableNames.containsAll(expectedTables), isTrue);
    });

    test('creates the indexes listed in 06_DATA_MODEL.md section 8', () async {
      final rows = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      final indexNames = rows.map((row) => row.read<String>('name')).toSet();

      const expectedIndexes = {
        'workoutsDateIdx',
        'workoutsStatusIdx',
        'workoutsIsDeletedIdx',
        'workoutExercisesWorkoutIdIdx',
        'workoutExercisesExerciseIdIdx',
        'exerciseSetsWorkoutExerciseIdIdx',
        'bodyMeasurementsTypeDateIdx',
        'exercisesIsArchivedIdx',
        'exercisesNameIdx',
        'workoutTagLinksTagIdIdx',
      };

      expect(indexNames.containsAll(expectedIndexes), isTrue);
    });
  });

  group('enum CHECK constraints', () {
    test('rejects an invalid workout status', () async {
      await db.customStatement('''
        INSERT INTO MuscleGroups (id, sortOrder) VALUES ('chest', 0);
      ''');

      expect(
        () => db.customStatement('''
          INSERT INTO Workouts (id, date, status, createdAt, updatedAt)
          VALUES ('w1', '2026-07-19', 'not_a_status', '2026-07-19T00:00:00Z', '2026-07-19T00:00:00Z');
        '''),
        throwsA(anything),
      );
    });

    test('accepts a valid workout status', () async {
      await db.customStatement('''
        INSERT INTO Workouts (id, date, status, createdAt, updatedAt)
        VALUES ('w1', '2026-07-19', 'draft', '2026-07-19T00:00:00Z', '2026-07-19T00:00:00Z');
      ''');

      final workout = await db.select(db.workouts).getSingle();
      expect(workout.status, 'draft');
    });
  });

  group('insert/read round trip', () {
    test('exercise references muscle group and equipment', () async {
      await db
          .into(db.muscleGroups)
          .insert(
            const MuscleGroupsCompanion(
              id: Value('chest'),
              sortOrder: Value(0),
            ),
          );
      await db
          .into(db.equipments)
          .insert(
            const EquipmentsCompanion(
              id: Value('barbell'),
              sortOrder: Value(0),
            ),
          );

      final now = '2026-07-19T00:00:00Z';
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'bench_press',
              name: 'Barbell Bench Press',
              exerciseType: 'strength',
              effortMetric: const Value('rpe'),
              primaryMuscleGroupId: const Value('chest'),
              equipmentId: const Value('barbell'),
              isBuiltIn: const Value(true),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final exercise = await db.select(db.exercises).getSingle();
      expect(exercise.name, 'Barbell Bench Press');
      expect(exercise.primaryMuscleGroupId, 'chest');
      expect(exercise.isDeleted, isFalse);
    });

    test(
      'exercise secondary muscle junction uses a composite primary key',
      () async {
        await db
            .into(db.muscleGroups)
            .insert(
              const MuscleGroupsCompanion(
                id: Value('chest'),
                sortOrder: Value(0),
              ),
            );
        await db
            .into(db.muscleGroups)
            .insert(
              const MuscleGroupsCompanion(
                id: Value('triceps'),
                sortOrder: Value(1),
              ),
            );
        final now = '2026-07-19T00:00:00Z';
        await db
            .into(db.exercises)
            .insert(
              ExercisesCompanion.insert(
                id: 'bench_press',
                name: 'Barbell Bench Press',
                exerciseType: 'strength',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await db
            .into(db.exerciseSecondaryMuscles)
            .insert(
              const ExerciseSecondaryMusclesCompanion(
                exerciseId: Value('bench_press'),
                muscleGroupId: Value('triceps'),
              ),
            );

        final links = await db.select(db.exerciseSecondaryMuscles).get();
        expect(links, hasLength(1));
        expect(links.single.muscleGroupId, 'triceps');
      },
    );

    test('AppSettingsTable stores the singleton row', () async {
      final now = '2026-07-19T00:00:00Z';
      await db
          .into(db.appSettingsTable)
          .insert(
            AppSettingsTableCompanion.insert(id: 'singleton', updatedAt: now),
          );

      final settings = await db.select(db.appSettingsTable).getSingle();
      expect(settings.unitSystem, 'metric');
      expect(settings.theme, 'system');
      expect(settings.defaultRestTimerSec, 120);
      expect(settings.restTimerAutoStart, isTrue);
    });
  });
}
