import 'workout.dart';

/// A [Workout] plus its exercise count — the read shape the history list
/// (S-02) needs for its card (04_UI_UX_SPEC.md, section 5: "дата, имя,
/// статус-чип, ..., число упражнений, длительность"). Not a persisted
/// entity; `exerciseCount` is computed by the repository query.
class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.workout,
    required this.exerciseCount,
  });

  final Workout workout;
  final int exerciseCount;
}
