import 'exercise.dart';
import 'exercise_set.dart';
import 'workout.dart';
import 'workout_exercise.dart';
import 'workout_tag.dart';

/// One exercise entry of a workout together with its catalog [Exercise]
/// and its [sets], ordered by `setNumber` — the read shape the workout
/// editor (S-03) needs. Not a persisted entity by itself.
class WorkoutExerciseDetails {
  const WorkoutExerciseDetails({
    required this.workoutExercise,
    required this.exercise,
    required this.sets,
  });

  final WorkoutExercise workoutExercise;
  final Exercise exercise;
  final List<ExerciseSet> sets;
}

/// A [Workout] with its exercises and their sets loaded, ordered by
/// `orderIndex` — the read shape the workout editor (S-03) and the
/// "reopen and see saved data" scenario (Stage 1) need.
class WorkoutDetails {
  const WorkoutDetails({
    required this.workout,
    required this.exercises,
    this.tags = const [],
  });

  final Workout workout;
  final List<WorkoutExerciseDetails> exercises;

  /// Tags assigned to this workout (S-03, DM 6.3/6.5), most recently
  /// created first — same order as `WorkoutTagRepository.watchAll`.
  final List<WorkoutTag> tags;
}
