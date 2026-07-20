import 'workout.dart';
import 'workout_tag.dart';

/// A [Workout] plus its exercise count and tags — the read shape the
/// history list (S-02) needs for its card (04_UI_UX_SPEC.md, section 5:
/// "дата, имя, статус-чип, теги, число упражнений, длительность"). Not a
/// persisted entity; `exerciseCount`/`tags` are computed by the repository
/// query.
class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.workout,
    required this.exerciseCount,
    this.tags = const [],
  });

  final Workout workout;
  final int exerciseCount;
  final List<WorkoutTag> tags;
}
