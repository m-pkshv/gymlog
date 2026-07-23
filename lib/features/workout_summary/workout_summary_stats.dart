import '../../domain/enums.dart';
import '../../domain/models/workout_details.dart';

/// S-05 aggregate figures for a just-finished workout.
class WorkoutSummaryStats {
  const WorkoutSummaryStats({
    required this.exerciseCount,
    required this.setCount,
    required this.tonnageKg,
  });

  final int exerciseCount;
  final int setCount;
  final double tonnageKg;
}

/// Computes the S-05 summary figures from an already-loaded [details].
/// Exercise/set counts are a plain structural tally (every set, any
/// completion state) -- the same "just count what's there" approach the
/// History list card already uses for its exercise count (06_DATA_MODEL.md
/// has nothing more specific for this screen). Tonnage follows TS 9's
/// formula exactly, since it's the same "тоннаж" concept that formula
/// defines: `Σ actualWeightKg × actualReps` over completed strength/reps
/// sets (an exercise without a weight field, like `reps`, contributes 0 per
/// set since `actualWeightKg` is never populated for it).
WorkoutSummaryStats computeWorkoutSummaryStats(WorkoutDetails details) {
  var setCount = 0;
  var tonnageKg = 0.0;
  for (final exerciseDetails in details.exercises) {
    setCount += exerciseDetails.sets.length;
    final type = exerciseDetails.exercise.exerciseType;
    if (type != ExerciseType.strength && type != ExerciseType.reps) continue;
    for (final set in exerciseDetails.sets) {
      if (!set.isCompleted) continue;
      tonnageKg += (set.actualWeightKg ?? 0) * (set.actualReps ?? 0);
    }
  }
  return WorkoutSummaryStats(
    exerciseCount: details.exercises.length,
    setCount: setCount,
    tonnageKg: tonnageKg,
  );
}
