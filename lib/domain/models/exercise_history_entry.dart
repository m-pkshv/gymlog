import 'exercise_set.dart';
import 'workout.dart';

/// One past occurrence of an exercise: the (completed) [workout] it was
/// part of, and the sets logged that time — the read shape the exercise
/// card's "История" tab needs (S-07, Stage 2). Not a persisted entity.
class ExerciseHistoryEntry {
  const ExerciseHistoryEntry({required this.workout, required this.sets});

  final Workout workout;
  final List<ExerciseSet> sets;
}
