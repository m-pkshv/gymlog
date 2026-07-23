import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/domain/models/exercise_set.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/domain/models/workout_details.dart';
import 'package:gymlog/domain/models/workout_exercise.dart';
import 'package:gymlog/features/workout_summary/workout_summary_stats.dart';

final _now = DateTime.utc(2026, 7, 21);

Exercise _exercise(String id, ExerciseType type) {
  return Exercise(
    id: id,
    name: id,
    exerciseType: type,
    effortMetric: EffortMetric.none,
    isBuiltIn: false,
    isArchived: false,
    secondaryMuscleGroupIds: const [],
    createdAt: _now,
    updatedAt: _now,
    isDeleted: false,
  );
}

WorkoutExercise _workoutExercise(String id, String exerciseId) {
  return WorkoutExercise(
    id: id,
    workoutId: 'w1',
    exerciseId: exerciseId,
    orderIndex: 0,
    progressionDecision: ProgressionDecision.none,
    createdAt: _now,
    updatedAt: _now,
    isDeleted: false,
  );
}

ExerciseSet _set({
  bool isCompleted = true,
  double? actualWeightKg,
  int? actualReps,
  int? actualDurationSec,
}) {
  return ExerciseSet(
    id: 's1',
    workoutExerciseId: 'we1',
    setNumber: 1,
    isCompleted: isCompleted,
    side: BodySide.none,
    createdAt: _now,
    updatedAt: _now,
    isDeleted: false,
    actualWeightKg: actualWeightKg,
    actualReps: actualReps,
    actualDurationSec: actualDurationSec,
  );
}

Workout _workout() {
  return Workout(
    id: 'w1',
    date: _now,
    status: WorkoutStatus.completed,
    createdAt: _now,
    updatedAt: _now,
    isDeleted: false,
  );
}

void main() {
  group('computeWorkoutSummaryStats', () {
    test('an empty workout has zero counts and zero tonnage', () {
      final details = WorkoutDetails(workout: _workout(), exercises: const []);

      final stats = computeWorkoutSummaryStats(details);

      expect(stats.exerciseCount, 0);
      expect(stats.setCount, 0);
      expect(stats.tonnageKg, 0);
    });

    test('counts every set of every exercise, regardless of completion', () {
      final details = WorkoutDetails(
        workout: _workout(),
        exercises: [
          WorkoutExerciseDetails(
            workoutExercise: _workoutExercise('we1', 'squat'),
            exercise: _exercise('squat', ExerciseType.strength),
            sets: [
              _set(isCompleted: false),
              _set(isCompleted: true, actualWeightKg: 100, actualReps: 5),
              _set(isCompleted: false),
            ],
          ),
          WorkoutExerciseDetails(
            workoutExercise: _workoutExercise('we2', 'plank'),
            exercise: _exercise('plank', ExerciseType.time),
            sets: [_set(isCompleted: true, actualDurationSec: 60)],
          ),
        ],
      );

      final stats = computeWorkoutSummaryStats(details);

      expect(stats.exerciseCount, 2);
      expect(stats.setCount, 4);
    });

    test(
      'tonnage sums actualWeightKg x actualReps over completed strength/reps '
      'sets only (TS 9)',
      () {
        final details = WorkoutDetails(
          workout: _workout(),
          exercises: [
            WorkoutExerciseDetails(
              workoutExercise: _workoutExercise('we1', 'squat'),
              exercise: _exercise('squat', ExerciseType.strength),
              sets: [
                // Counts: 100 x 5 = 500.
                _set(isCompleted: true, actualWeightKg: 100, actualReps: 5),
                // Counts: 40 x 10 = 400.
                _set(isCompleted: true, actualWeightKg: 40, actualReps: 10),
                // Not completed -- excluded.
                _set(isCompleted: false, actualWeightKg: 100, actualReps: 5),
              ],
            ),
            WorkoutExerciseDetails(
              workoutExercise: _workoutExercise('we2', 'pullup'),
              exercise: _exercise('pullup', ExerciseType.reps),
              // No weight field for `reps` -- contributes 0, not skipped.
              sets: [_set(isCompleted: true, actualReps: 12)],
            ),
            WorkoutExerciseDetails(
              workoutExercise: _workoutExercise('we3', 'plank'),
              exercise: _exercise('plank', ExerciseType.time),
              // Not strength/reps -- excluded entirely.
              sets: [_set(isCompleted: true, actualDurationSec: 60)],
            ),
          ],
        );

        final stats = computeWorkoutSummaryStats(details);

        expect(stats.tonnageKg, 900);
      },
    );
  });
}
