import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/data/database.dart' hide Exercise;
import 'package:gymlog/data/mappers/exercise_mapper.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/services/exercise_service.dart';

Exercise _builtIn(String id, {required String name}) {
  final now = DateTime.utc(2026, 7, 19);
  return Exercise(
    id: id,
    name: name,
    exerciseType: ExerciseType.strength,
    effortMetric: EffortMetric.none,
    isBuiltIn: true,
    isArchived: false,
    secondaryMuscleGroupIds: const [],
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
  );
}

void main() {
  late AppDatabase db;
  late ExerciseRepositoryImpl repository;
  late ExerciseService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExerciseRepositoryImpl(db);
    service = ExerciseService(repository);
  });

  tearDown(() async {
    await db.close();
  });

  group('canChangeType (DM 6.1)', () {
    test('true for a freshly-created exercise', () async {
      final exercise = await repository.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      expect(await service.canChangeType(exercise.id), isTrue);
    });

    test('false once a set has been logged against it', () async {
      final exercise = await repository.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: exercise.id,
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.exerciseSets)
          .insert(
            ExerciseSetsCompanion.insert(
              id: 's1',
              workoutExerciseId: 'we1',
              setNumber: 1,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      expect(await service.canChangeType(exercise.id), isFalse);
    });
  });

  group('update (DM 6.1)', () {
    test('saves field changes when the type is unchanged', () async {
      final exercise = await repository.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );

      final result = await service.update(
        current: exercise,
        name: 'Front Squat',
        exerciseType: ExerciseType.strength,
        description: 'A quad-focused squat variant.',
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull()!.name, 'Front Squat');
      expect(
        (await repository.getById(exercise.id))!.name,
        'Front Squat',
      );
    });

    test('allows changing the type while unlocked', () async {
      final exercise = await repository.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );

      final result = await service.update(
        current: exercise,
        name: 'Squat',
        exerciseType: ExerciseType.reps,
      );

      expect(result.isOk, isTrue);
      expect(result.getOrNull()!.exerciseType, ExerciseType.reps);
    });

    test('rejects changing the type once a set has been logged', () async {
      final exercise = await repository.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: exercise.id,
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.exerciseSets)
          .insert(
            ExerciseSetsCompanion.insert(
              id: 's1',
              workoutExerciseId: 'we1',
              setNumber: 1,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      final result = await service.update(
        current: exercise,
        name: 'Squat',
        exerciseType: ExerciseType.reps,
      );

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      expect(
        (await repository.getById(exercise.id))!.exerciseType,
        ExerciseType.strength,
        reason: 'the rejected update must not have been written',
      );
    });

    test(
      'still allows non-type edits once the type is locked',
      () async {
        final exercise = await repository.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                id: 'w1',
                date: '2026-07-20',
                createdAt: '2026-07-19T00:00:00Z',
                updatedAt: '2026-07-19T00:00:00Z',
              ),
            );
        await db
            .into(db.workoutExercises)
            .insert(
              WorkoutExercisesCompanion.insert(
                id: 'we1',
                workoutId: 'w1',
                exerciseId: exercise.id,
                orderIndex: 0,
                createdAt: '2026-07-19T00:00:00Z',
                updatedAt: '2026-07-19T00:00:00Z',
              ),
            );
        await db
            .into(db.exerciseSets)
            .insert(
              ExerciseSetsCompanion.insert(
                id: 's1',
                workoutExerciseId: 'we1',
                setNumber: 1,
                createdAt: '2026-07-19T00:00:00Z',
                updatedAt: '2026-07-19T00:00:00Z',
              ),
            );

        final result = await service.update(
          current: exercise,
          name: 'Back Squat',
          exerciseType: ExerciseType.strength,
        );

        expect(result.isOk, isTrue);
        expect(result.getOrNull()!.name, 'Back Squat');
      },
    );
  });

  group('archive/unarchive', () {
    test('archive sets isArchived and persists it', () async {
      final exercise = await repository.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );

      final result = await service.archive(exercise);

      expect(result.isOk, isTrue);
      expect(result.getOrNull()!.isArchived, isTrue);
      expect((await repository.getById(exercise.id))!.isArchived, isTrue);
    });

    test('unarchive clears isArchived and persists it', () async {
      final exercise = await repository.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );
      await service.archive(exercise);
      final archived = (await repository.getById(exercise.id))!;

      final result = await service.unarchive(archived);

      expect(result.getOrNull()!.isArchived, isFalse);
      expect((await repository.getById(exercise.id))!.isArchived, isFalse);
    });

    test('archiving works for built-in exercises too', () async {
      final builtIn = _builtIn('squat', name: 'Barbell Squat');
      await db.into(db.exercises).insert(builtIn.toInsertCompanion());

      final result = await service.archive(builtIn);

      expect(result.isOk, isTrue);
      expect((await repository.getById('squat'))!.isArchived, isTrue);
    });
  });

  group('canDelete (DM 10)', () {
    test('false for a built-in exercise', () async {
      final builtIn = _builtIn('squat', name: 'Barbell Squat');
      await db.into(db.exercises).insert(builtIn.toInsertCompanion());

      expect(await service.canDelete(builtIn), isFalse);
    });

    test('true for an unused user-created exercise', () async {
      final exercise = await repository.create(
        name: 'Lunges',
        exerciseType: ExerciseType.strength,
      );

      expect(await service.canDelete(exercise), isTrue);
    });

    test('false for a user-created exercise used in a workout', () async {
      final exercise = await repository.create(
        name: 'Lunges',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: exercise.id,
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      expect(await service.canDelete(exercise), isFalse);
    });
  });

  group('delete (DM 10)', () {
    test('rejects deleting a built-in exercise', () async {
      final builtIn = _builtIn('squat', name: 'Barbell Squat');
      await db.into(db.exercises).insert(builtIn.toInsertCompanion());

      final result = await service.delete(builtIn);

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.getById('squat'), isNotNull);
    });

    test('rejects deleting a user exercise that is used in a workout', () async {
      final exercise = await repository.create(
        name: 'Lunges',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: exercise.id,
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      final result = await service.delete(exercise);

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      expect(await repository.getById(exercise.id), isNotNull);
    });

    test('deletes an unused user exercise', () async {
      final exercise = await repository.create(
        name: 'Unused Move',
        exerciseType: ExerciseType.reps,
      );

      final result = await service.delete(exercise);

      expect(result.isOk, isTrue);
      expect(await repository.getById(exercise.id), isNull);
    });
  });
}
