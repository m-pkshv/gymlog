import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/models/workout_exercise.dart';
import '../../domain/models/workout_tag.dart';
import 'csv_format.dart';

const workoutsCsvHeader = [
  'exercise_name',
  'exercise_id',
  'exercise_type',
  'workout_id',
  'workout_date',
  'workout_name',
  'workout_status',
  'workout_tags',
  'workout_comment',
  'workout_duration_sec',
  'exercise_order',
  'exercise_comment',
  'progression_decision',
  'set_number',
  'is_warmup',
  'is_completed',
  'planned_weight_kg',
  'planned_reps',
  'actual_weight_kg',
  'actual_reps',
  'rpe',
  'rir',
  'planned_duration_sec',
  'actual_duration_sec',
  'planned_distance_m',
  'actual_distance_m',
  'resistance',
  'incline_percent',
  'avg_heart_rate',
  'side',
  'set_comment',
];

/// `workouts.csv` (03_TECHNICAL_SPEC.md, section 10.3): one row per set.
/// A workout with no exercises gets one row with every exercise/set column
/// empty ("Тренировка без упражнений — одна строка с пустыми полями
/// подхода"); by the same reading, an exercise with no sets gets one row
/// with every set column empty. [workouts] must already be the full,
/// already-filtered set to export (non-deleted, every status) -- this
/// function only formats and sorts, it never queries the database.
String buildWorkoutsCsv(List<WorkoutDetails> workouts) {
  final sortedWorkouts = [...workouts]..sort((a, b) {
    final byDate = a.workout.date.compareTo(b.workout.date);
    if (byDate != 0) return byDate;
    return a.workout.id.compareTo(b.workout.id);
  });

  final buffer = StringBuffer()..write(csvRow(workoutsCsvHeader));
  for (final details in sortedWorkouts) {
    if (details.exercises.isEmpty) {
      buffer.write(csvRow(_row(workout: details.workout, tags: details.tags)));
      continue;
    }

    final sortedExercises = [...details.exercises]..sort(
      (a, b) =>
          a.workoutExercise.orderIndex.compareTo(b.workoutExercise.orderIndex),
    );
    for (final exerciseDetails in sortedExercises) {
      if (exerciseDetails.sets.isEmpty) {
        buffer.write(
          csvRow(
            _row(
              workout: details.workout,
              tags: details.tags,
              exercise: exerciseDetails.exercise,
              workoutExercise: exerciseDetails.workoutExercise,
            ),
          ),
        );
        continue;
      }

      final sortedSets = [...exerciseDetails.sets]
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      for (final set in sortedSets) {
        buffer.write(
          csvRow(
            _row(
              workout: details.workout,
              tags: details.tags,
              exercise: exerciseDetails.exercise,
              workoutExercise: exerciseDetails.workoutExercise,
              set: set,
            ),
          ),
        );
      }
    }
  }
  return buffer.toString();
}

List<String> _row({
  required Workout workout,
  required List<WorkoutTag> tags,
  Exercise? exercise,
  WorkoutExercise? workoutExercise,
  ExerciseSet? set,
}) {
  return [
    exercise?.name ?? '',
    exercise?.id ?? '',
    exercise?.exerciseType.name ?? '',
    workout.id,
    formatCsvDate(workout.date),
    workout.name ?? '',
    workout.status.name,
    tags.map((t) => t.name).join(';'),
    workout.comment ?? '',
    formatCsvInt(workout.actualDurationSec),
    formatCsvInt(workoutExercise?.orderIndex),
    workoutExercise?.comment ?? '',
    workoutExercise?.progressionDecision.name ?? '',
    formatCsvInt(set?.setNumber),
    formatCsvBool(set?.isWarmup),
    formatCsvBool(set?.isCompleted),
    formatCsvDecimal(set?.plannedWeightKg),
    formatCsvInt(set?.plannedReps),
    formatCsvDecimal(set?.actualWeightKg),
    formatCsvInt(set?.actualReps),
    formatCsvDecimal(set?.rpe),
    formatCsvInt(set?.rir),
    formatCsvInt(set?.plannedDurationSec),
    formatCsvInt(set?.actualDurationSec),
    formatCsvDecimal(set?.plannedDistanceM),
    formatCsvDecimal(set?.actualDistanceM),
    formatCsvDecimal(set?.resistance),
    formatCsvDecimal(set?.inclinePercent),
    formatCsvInt(set?.avgHeartRate),
    set?.side.name ?? '',
    set?.comment ?? '',
  ];
}
