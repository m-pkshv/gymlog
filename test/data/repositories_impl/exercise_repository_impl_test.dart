import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late ExerciseRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ExerciseRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'create stores a user-created exercise with just a name and type (S-08)',
    () async {
      final exercise = await repository.create(
        name: 'Barbell Row',
        exerciseType: ExerciseType.strength,
      );

      expect(exercise.name, 'Barbell Row');
      expect(exercise.exerciseType, ExerciseType.strength);
      expect(exercise.isBuiltIn, isFalse);
      expect(exercise.isArchived, isFalse);
      expect(exercise.secondaryMuscleGroupIds, isEmpty);

      final reloaded = await repository.getById(exercise.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.name, 'Barbell Row');
      expect(reloaded.exerciseType, ExerciseType.strength);
    },
  );

  test('getById returns null for an unknown id', () async {
    expect(await repository.getById('does-not-exist'), isNull);
  });

  test('create stores the full DM 6.1 field set and secondary muscles', () async {
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 1));
    await db
        .into(db.equipments)
        .insert(EquipmentsCompanion.insert(id: 'barbell', sortOrder: 0));

    final exercise = await repository.create(
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
      description: 'Lie on a bench and press.',
      youtubeUrl: 'https://youtu.be/abc123',
      primaryMuscleGroupId: 'chest',
      equipmentId: 'barbell',
      effortMetric: EffortMetric.rpe,
      secondaryMuscleGroupIds: ['triceps'],
    );

    expect(exercise.description, 'Lie on a bench and press.');
    expect(exercise.youtubeUrl, 'https://youtu.be/abc123');
    expect(exercise.primaryMuscleGroupId, 'chest');
    expect(exercise.equipmentId, 'barbell');
    expect(exercise.effortMetric, EffortMetric.rpe);
    expect(exercise.secondaryMuscleGroupIds, ['triceps']);

    final reloaded = await repository.getById(exercise.id);
    expect(reloaded!.description, 'Lie on a bench and press.');
    expect(reloaded.secondaryMuscleGroupIds, ['triceps']);
  });

  test('update overwrites the full field set and returns the new state', () async {
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 1));
    await db
        .into(db.equipments)
        .insert(EquipmentsCompanion.insert(id: 'barbell', sortOrder: 0));
    final exercise = await repository.create(
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
      description: 'old description',
      primaryMuscleGroupId: 'chest',
      secondaryMuscleGroupIds: ['triceps'],
    );

    final updated = await repository.update(
      id: exercise.id,
      name: 'Incline Bench Press',
      exerciseType: ExerciseType.strength,
      description: 'new description',
      youtubeUrl: 'https://youtu.be/xyz',
      primaryMuscleGroupId: 'chest',
      equipmentId: 'barbell',
      effortMetric: EffortMetric.rir,
      secondaryMuscleGroupIds: ['triceps'],
    );

    expect(updated.name, 'Incline Bench Press');
    expect(updated.description, 'new description');
    expect(updated.youtubeUrl, 'https://youtu.be/xyz');
    expect(updated.equipmentId, 'barbell');
    expect(updated.effortMetric, EffortMetric.rir);
    expect(updated.secondaryMuscleGroupIds, ['triceps']);

    final reloaded = await repository.getById(exercise.id);
    expect(reloaded!.name, 'Incline Bench Press');
    expect(reloaded.equipmentId, 'barbell');
  });

  test('update clears optional fields when the caller omits them', () async {
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
    final exercise = await repository.create(
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
      description: 'old description',
      youtubeUrl: 'https://youtu.be/old',
      primaryMuscleGroupId: 'chest',
    );

    final updated = await repository.update(
      id: exercise.id,
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
    );

    expect(updated.description, isNull);
    expect(updated.youtubeUrl, isNull);
    expect(updated.primaryMuscleGroupId, isNull);
    final reloaded = await repository.getById(exercise.id);
    expect(reloaded!.description, isNull);
    expect(reloaded.primaryMuscleGroupId, isNull);
  });

  test('update replaces the secondary muscle links wholesale', () async {
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 1));
    final exercise = await repository.create(
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
      secondaryMuscleGroupIds: ['triceps'],
    );

    await repository.update(
      id: exercise.id,
      name: 'Bench Press',
      exerciseType: ExerciseType.strength,
      secondaryMuscleGroupIds: ['chest'],
    );

    final reloaded = await repository.getById(exercise.id);
    expect(reloaded!.secondaryMuscleGroupIds, ['chest']);
  });

  test(
    'watchAll emits created exercises and includes secondary muscle groups',
    () async {
      await db
          .into(db.muscleGroups)
          .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
      await db
          .into(db.muscleGroups)
          .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 1));

      final exercise = await repository.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.exerciseSecondaryMuscles)
          .insert(
            ExerciseSecondaryMusclesCompanion.insert(
              exerciseId: exercise.id,
              muscleGroupId: 'triceps',
            ),
          );

      final all = await repository.watchAll().first;
      expect(all, hasLength(1));
      expect(all.single.name, 'Bench Press');
      expect(all.single.secondaryMuscleGroupIds, ['triceps']);
    },
  );

  test('watchAll excludes archived exercises', () async {
    final exercise = await repository.create(
      name: 'Old Move',
      exerciseType: ExerciseType.reps,
    );
    await (db.update(db.exercises)..where((e) => e.id.equals(exercise.id)))
        .write(ExercisesCompanion(isArchived: Value(true)));

    final all = await repository.watchAll().first;
    expect(all, isEmpty);
  });

  test('setArchived flips isArchived and getById reflects it', () async {
    final exercise = await repository.create(
      name: 'Lunges',
      exerciseType: ExerciseType.strength,
    );

    await repository.setArchived(exercise.id, archived: true);
    expect((await repository.getById(exercise.id))!.isArchived, isTrue);

    await repository.setArchived(exercise.id, archived: false);
    expect((await repository.getById(exercise.id))!.isArchived, isFalse);
  });

  test('delete physically removes the exercise row', () async {
    final exercise = await repository.create(
      name: 'Unused Move',
      exerciseType: ExerciseType.reps,
    );

    await repository.delete(exercise.id);

    expect(await repository.getById(exercise.id), isNull);
  });

  test('delete cascades to ExerciseSecondaryMuscles (DM 10)', () async {
    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0));
    final exercise = await repository.create(
      name: 'Fly',
      exerciseType: ExerciseType.strength,
    );
    await db
        .into(db.exerciseSecondaryMuscles)
        .insert(
          ExerciseSecondaryMusclesCompanion.insert(
            exerciseId: exercise.id,
            muscleGroupId: 'chest',
          ),
        );

    await repository.delete(exercise.id);

    final links = await db.select(db.exerciseSecondaryMuscles).get();
    expect(links, isEmpty);
  });

  Future<String> addToWorkout(
    ExerciseRepositoryImpl repository,
    String exerciseId, {
    bool withLoggedSet = false,
  }) async {
    final workoutId = 'w-${exerciseId}_$withLoggedSet';
    await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: workoutId,
            date: '2026-07-20',
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    final workoutExerciseId = '${workoutId}_we';
    await db
        .into(db.workoutExercises)
        .insert(
          WorkoutExercisesCompanion.insert(
            id: workoutExerciseId,
            workoutId: workoutId,
            exerciseId: exerciseId,
            orderIndex: 0,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    if (withLoggedSet) {
      await db
          .into(db.exerciseSets)
          .insert(
            ExerciseSetsCompanion.insert(
              id: '${workoutExerciseId}_s1',
              workoutExerciseId: workoutExerciseId,
              setNumber: 1,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
    }
    return workoutId;
  }

  test('isUsedInWorkouts is false until the exercise is added to a workout', () async {
    final exercise = await repository.create(
      name: 'Deadlift',
      exerciseType: ExerciseType.strength,
    );
    expect(await repository.isUsedInWorkouts(exercise.id), isFalse);

    await addToWorkout(repository, exercise.id);
    expect(await repository.isUsedInWorkouts(exercise.id), isTrue);
  });

  test(
    'hasLoggedSets stays false when added to a workout with no sets, true '
    'once a set is logged (DM 6.1 exerciseType lock)',
    () async {
      final exercise = await repository.create(
        name: 'Pull-Up',
        exerciseType: ExerciseType.reps,
      );
      await addToWorkout(repository, exercise.id);
      expect(
        await repository.hasLoggedSets(exercise.id),
        isFalse,
        reason: 'added to a workout, but no set logged yet',
      );

      final exercise2 = await repository.create(
        name: 'Chin-Up',
        exerciseType: ExerciseType.reps,
      );
      await addToWorkout(repository, exercise2.id, withLoggedSet: true);
      expect(await repository.hasLoggedSets(exercise2.id), isTrue);
    },
  );
}
