import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/progression_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/services/progression_service.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late ProgressionRepositoryImpl progressionRepository;
  late ProgressionService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    progressionRepository = ProgressionRepositoryImpl(db);
    service = ProgressionService(workouts, exercises, progressionRepository);
  });

  tearDown(() async {
    await db.close();
  });

  /// Completes a workout for [exerciseId] dated [date] with one working,
  /// completed set carrying [weight]/[reps] (strength) -- the shared
  /// fixture builder for most tests below.
  Future<void> completedStrengthOccurrence(
    String exerciseId, {
    required DateTime date,
    double? weight,
    int? reps,
  }) async {
    final workout = await workouts.createDraft(date: date);
    final we = await workouts.addExercise(
      workoutId: workout.id,
      exerciseId: exerciseId,
    );
    final set = await workouts.addSet(workoutExerciseId: we.id);
    await workouts.updateSet(
      set.copyWith(
        isCompleted: true,
        actualWeightKg: weight,
        actualReps: reps,
      ),
    );
    await workouts.updateWorkout(
      workout.copyWith(status: WorkoutStatus.completed),
    );
  }

  test('does nothing when the exercise has no completed occurrences', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );

    await service.recompute(exercise.id);

    expect(await progressionRepository.watchState(exercise.id).first, isNull);
  });

  test('a single occurrence never increments (no prior to compare)', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );
    await completedStrengthOccurrence(
      exercise.id,
      date: DateTime(2026, 7, 1),
      weight: 60,
      reps: 8,
    );

    await service.recompute(exercise.id);

    final state = await progressionRepository.watchState(exercise.id).first;
    expect(state!.stagnationCount, 0);
  });

  test(
    'strength: heavier weight at the same reps is growth -> resets to 0',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 8),
        weight: 60,
        reps: 8,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 15),
        weight: 65,
        reps: 8,
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      // 1st->2nd: no growth (count 1); 2nd->3rd: growth (reset to 0).
      expect(state!.stagnationCount, 0);
    },
  );

  test(
    'strength: identical weight and reps twice in a row is not growth',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 8),
        weight: 60,
        reps: 8,
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      expect(state!.stagnationCount, 1);
    },
  );

  test(
    'strength: more weight but fewer reps is NOT growth (one metric '
    'decreased -- D-7 requires none to decrease)',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 8),
        weight: 65,
        reps: 6,
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      expect(state!.stagnationCount, 1);
    },
  );

  test(
    'strength: a occurrence with no completed working sets counts as no '
    'measurable result (null vector), consecutively increasing stagnation',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      // Logged the exercise but didn't complete a working set that time.
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 8));
      await workouts.addExercise(workoutId: workout.id, exerciseId: exercise.id);
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      expect(state!.stagnationCount, 1);
    },
  );

  test(
    'strength: sets with reps > 12 are outside the D-6 1RM domain and '
    'excluded from the "best set" search',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      // Every set this time has reps > 12 -- no candidate for "best set".
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 8),
        weight: 100,
        reps: 20,
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      // Treated as a null-vector occurrence -- not growth (value -> null).
      expect(state!.stagnationCount, 1);
    },
  );

  test('reps type: more reps is growth', () async {
    final exercise = await exercises.create(
      name: 'Pull-ups',
      exerciseType: ExerciseType.reps,
    );
    for (final (date, reps) in [
      (DateTime(2026, 7, 1), 8),
      (DateTime(2026, 7, 8), 10),
    ]) {
      final workout = await workouts.createDraft(date: date);
      final we = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(workoutExerciseId: we.id);
      await workouts.updateSet(
        set.copyWith(isCompleted: true, actualReps: reps),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
    }

    await service.recompute(exercise.id);

    final state = await progressionRepository.watchState(exercise.id).first;
    expect(state!.stagnationCount, 0);
  });

  test(
    'cardio: more distance in not-more time is growth (time is inverted)',
    () async {
      final exercise = await exercises.create(
        name: 'Run',
        exerciseType: ExerciseType.cardio,
      );
      for (final (date, distance, duration) in [
        (DateTime(2026, 7, 1), 5000.0, 1800),
        (DateTime(2026, 7, 8), 5500.0, 1800),
      ]) {
        final workout = await workouts.createDraft(date: date);
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,

        );
        await workouts.updateSet(
          set.copyWith(
            isCompleted: true,
            actualDistanceM: distance,
            actualDurationSec: duration,
          ),
        );
        await workouts.updateWorkout(
          workout.copyWith(status: WorkoutStatus.completed),
        );
      }

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      expect(state!.stagnationCount, 0);
    },
  );

  test(
    'cardio: same distance but slower time is NOT growth',
    () async {
      final exercise = await exercises.create(
        name: 'Run',
        exerciseType: ExerciseType.cardio,
      );
      for (final (date, distance, duration) in [
        (DateTime(2026, 7, 1), 5000.0, 1800),
        (DateTime(2026, 7, 8), 5000.0, 2000),
      ]) {
        final workout = await workouts.createDraft(date: date);
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,

        );
        await workouts.updateSet(
          set.copyWith(
            isCompleted: true,
            actualDistanceM: distance,
            actualDurationSec: duration,
          ),
        );
        await workouts.updateWorkout(
          workout.copyWith(status: WorkoutStatus.completed),
        );
      }

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      expect(state!.stagnationCount, 1);
    },
  );

  test('time/stretch: a longer duration is growth', () async {
    final exercise = await exercises.create(
      name: 'Plank',
      exerciseType: ExerciseType.time,
    );
    for (final (date, duration) in [
      (DateTime(2026, 7, 1), 60),
      (DateTime(2026, 7, 8), 90),
    ]) {
      final workout = await workouts.createDraft(date: date);
      final we = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(workoutExerciseId: we.id);
      await workouts.updateSet(
        set.copyWith(isCompleted: true, actualDurationSec: duration),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
    }

    await service.recompute(exercise.id);

    final state = await progressionRepository.watchState(exercise.id).first;
    expect(state!.stagnationCount, 0);
  });

  test(
    'not-completed sets are ignored (TS 9 general rule)',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completedStrengthOccurrence(
        exercise.id,
        date: DateTime(2026, 7, 1),
        weight: 60,
        reps: 8,
      );
      // A heavier set, but never marked done -- must not count as "best".
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 8));
      final we = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(workoutExerciseId: we.id);
      await workouts.updateSet(
        set.copyWith(actualWeightKg: 100, actualReps: 8),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );

      await service.recompute(exercise.id);

      final state = await progressionRepository.watchState(exercise.id).first;
      // No completed set that occurrence -- a null vector, not growth.
      expect(state!.stagnationCount, 1);
    },
  );

  test('cancelled/skipped/draft workouts do not count toward history', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );
    await completedStrengthOccurrence(
      exercise.id,
      date: DateTime(2026, 7, 1),
      weight: 60,
      reps: 8,
    );
    final cancelled = await workouts.createDraft(date: DateTime(2026, 7, 5));
    final we = await workouts.addExercise(
      workoutId: cancelled.id,
      exerciseId: exercise.id,
    );
    final set = await workouts.addSet(workoutExerciseId: we.id);
    await workouts.updateSet(
      set.copyWith(isCompleted: true, actualWeightKg: 999, actualReps: 1),
    );
    await workouts.updateWorkout(
      cancelled.copyWith(status: WorkoutStatus.cancelled),
    );
    await completedStrengthOccurrence(
      exercise.id,
      date: DateTime(2026, 7, 8),
      weight: 65,
      reps: 8,
    );

    await service.recompute(exercise.id);

    final state = await progressionRepository.watchState(exercise.id).first;
    // Only the two completed occurrences matter: 60kg -> 65kg is growth.
    expect(state!.stagnationCount, 0);
  });
}
