import '../models/exercise_progression_state.dart';

/// Storage contract for the stagnation-counter cache (D-7, 06_DATA_MODEL.md
/// section 6.11). Implemented in the Data layer; `ProgressionService` is
/// the only writer (the single point of truth for the D-7 formula) — this
/// contract just persists whatever it computes.
abstract class ProgressionRepository {
  /// The current cached state for [exerciseId], or `null` if it has no
  /// completed occurrences yet.
  Stream<ExerciseProgressionState?> watchState(String exerciseId);

  Future<void> saveState(ExerciseProgressionState state);
}
