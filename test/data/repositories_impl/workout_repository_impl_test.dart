import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
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
    'watchHistory only lists completed workouts, most recent first',
    () async {
      final older = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.updateWorkout(
        older.copyWith(status: WorkoutStatus.completed),
      );

      final newer = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.updateWorkout(
        newer.copyWith(status: WorkoutStatus.completed),
      );

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 20));
      // draft stays in draft status - should not show up in history

      final history = await workouts.watchHistory().first;
      expect(history.map((w) => w.id), [newer.id, older.id]);
      expect(history.any((w) => w.id == draft.id), isFalse);
    },
  );

  test('getDetails returns null for an unknown workout', () async {
    expect(await workouts.getDetails('does-not-exist'), isNull);
  });
}
