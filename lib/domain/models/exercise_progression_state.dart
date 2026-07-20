/// Stagnation-counter cache for the progression algorithm (D-7,
/// 06_DATA_MODEL.md, section 6.11). Not a source of truth — fully rebuilt
/// from history by `ProgressionService.recompute` whenever a DM 6.10/6.11
/// trigger fires. Absence of a row for an exercise means it has no
/// completed occurrences yet (nothing to compute).
class ExerciseProgressionState {
  const ExerciseProgressionState({
    required this.exerciseId,
    required this.stagnationCount,
    required this.lastCountedWorkoutId,
    required this.computedAt,
  });

  final String exerciseId;

  /// Consecutive completed occurrences of this exercise without growth
  /// (D-7). Reset to 0 on growth.
  final int stagnationCount;
  final String lastCountedWorkoutId;
  final DateTime computedAt;
}
