import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_tag_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late WorkoutTagRepositoryImpl tags;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    tags = WorkoutTagRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('createDraft starts a workout in draft status', () async {
    final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));

    expect(workout.status, WorkoutStatus.draft);
    expect(workout.date, DateTime(2026, 7, 19));
  });

  test(
    'getInProgressWorkout finds the single in-progress workout (DM 6.4.1)',
    () async {
      expect(await workouts.getInProgressWorkout(), isNull);

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.updateWorkout(
        draft.copyWith(status: WorkoutStatus.inProgress),
      );

      final inProgress = await workouts.getInProgressWorkout();
      expect(inProgress, isNotNull);
      expect(inProgress!.id, draft.id);
    },
  );

  test(
    'the full vertical slice: create, add exercise, add sets, autosave, reopen',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));

      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      expect(workoutExercise.orderIndex, 0);

      final firstSet = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
        isWarmup: true,
      );
      final secondSet = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
        isWarmup: false,
      );
      expect(firstSet.setNumber, 1);
      expect(secondSet.setNumber, 2);

      // Autosave: plan then fact, then mark completed (DM 6.7 copy-plan rule).
      final planned = secondSet.copyWith(plannedWeightKg: 100, plannedReps: 5);
      await workouts.updateSet(planned);
      final completed = planned.markCompleted();
      await workouts.updateSet(completed);

      // "Close and reopen": read everything back from the database.
      final details = await workouts.getDetails(workout.id);
      expect(details, isNotNull);
      expect(details!.workout.id, workout.id);
      expect(details.exercises, hasLength(1));

      final exerciseDetails = details.exercises.single;
      expect(exerciseDetails.exercise.name, 'Squat');
      expect(exerciseDetails.sets, hasLength(2));
      expect(exerciseDetails.sets[0].isWarmup, isTrue);
      expect(exerciseDetails.sets[1].isCompleted, isTrue);
      expect(exerciseDetails.sets[1].actualWeightKg, 100);
      expect(exerciseDetails.sets[1].actualReps, 5);
    },
  );

  test(
    'watchHistory only lists completed workouts, most recent first, with '
    'their exercise count',
    () async {
      final older = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.updateWorkout(
        older.copyWith(status: WorkoutStatus.completed),
      );

      final newer = await workouts.createDraft(date: DateTime(2026, 7, 19));
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await workouts.addExercise(workoutId: newer.id, exerciseId: exercise.id);
      await workouts.updateWorkout(
        newer.copyWith(status: WorkoutStatus.completed),
      );

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 20));
      // draft stays in draft status - should not show up in history

      final history = await workouts.watchHistory().first;
      expect(history.map((e) => e.workout.id), [newer.id, older.id]);
      expect(history.any((e) => e.workout.id == draft.id), isFalse);

      final newerEntry = history.firstWhere((e) => e.workout.id == newer.id);
      expect(newerEntry.exerciseCount, 1);
      final olderEntry = history.firstWhere((e) => e.workout.id == older.id);
      expect(olderEntry.exerciseCount, 0);
    },
  );

  test('getDetails returns null for an unknown workout', () async {
    expect(await workouts.getDetails('does-not-exist'), isNull);
  });

  test(
    'an old workout still displays an exercise that was archived after '
    '(Stage 2 acceptance criteria and manual check ★: "архивное упражнение '
    'скрыто из выбора, но открывается из старой тренировки")',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );

      await exercises.setArchived(exercise.id, archived: true);

      // Archived: hidden from the catalog picker (S-06/add-exercise).
      expect(await exercises.watchAll().first, isEmpty);

      // But the old workout that already references it still shows it
      // correctly -- getDetails fetches by id, unfiltered by isArchived.
      final details = await workouts.getDetails(workout.id);
      expect(details!.exercises.single.exercise.name, 'Squat');
      expect(details.exercises.single.exercise.isArchived, isTrue);
    },
  );

  group('getExerciseHistory (S-07)', () {
    test(
      'only completed occurrences are returned, most recent date first',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );

        final older = await workouts.createDraft(date: DateTime(2026, 7, 1));
        final olderWe = await workouts.addExercise(
          workoutId: older.id,
          exerciseId: exercise.id,
        );
        final olderSet = await workouts.addSet(
          workoutExerciseId: olderWe.id,
          isWarmup: false,
        );
        await workouts.updateSet(
          olderSet.copyWith(actualWeightKg: 80, actualReps: 5),
        );
        await workouts.updateWorkout(
          older.copyWith(status: WorkoutStatus.completed),
        );

        final newer = await workouts.createDraft(date: DateTime(2026, 7, 19));
        final newerWe = await workouts.addExercise(
          workoutId: newer.id,
          exerciseId: exercise.id,
        );
        await workouts.addSet(workoutExerciseId: newerWe.id, isWarmup: false);
        await workouts.updateWorkout(
          newer.copyWith(status: WorkoutStatus.completed),
        );

        // Draft workout with the exercise: not completed, must not show up.
        final draft = await workouts.createDraft(date: DateTime(2026, 7, 20));
        await workouts.addExercise(
          workoutId: draft.id,
          exerciseId: exercise.id,
        );

        final history = await workouts.getExerciseHistory(exercise.id);

        expect(history.map((e) => e.workout.id), [newer.id, older.id]);
        expect(history[1].sets.single.actualWeightKg, 80);
        expect(history[1].sets.single.actualReps, 5);
      },
    );

    test('returns nothing for an exercise never used', () async {
      final exercise = await exercises.create(
        name: 'Unused',
        exerciseType: ExerciseType.reps,
      );

      expect(await workouts.getExerciseHistory(exercise.id), isEmpty);
    });
  });

  group('workout tags (Stage 3, DM 6.3/6.5)', () {
    test('a fresh workout has no tags', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final details = await workouts.getDetails(workout.id);
      expect(details!.tags, isEmpty);
    });

    test('setWorkoutTags assigns tags, reflected in getDetails', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final legs = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      final push = await tags.create(name: 'Push', colorHex: '#2E9E6B');

      await workouts.setWorkoutTags(
        workoutId: workout.id,
        tagIds: [legs.id, push.id],
      );

      final details = await workouts.getDetails(workout.id);
      expect(details!.tags.map((t) => t.id), containsAll([legs.id, push.id]));
      expect(details.tags, hasLength(2));
    });

    test(
      'setWorkoutTags replaces the previous set, not adds to it',
      () async {
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final legs = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
        final push = await tags.create(name: 'Push', colorHex: '#2E9E6B');

        await workouts.setWorkoutTags(
          workoutId: workout.id,
          tagIds: [legs.id],
        );
        await workouts.setWorkoutTags(
          workoutId: workout.id,
          tagIds: [push.id],
        );

        final details = await workouts.getDetails(workout.id);
        expect(details!.tags.map((t) => t.id), [push.id]);
      },
    );
  });
}
