import '../enums.dart';
import '../models/exercise.dart';

/// Storage contract for the exercise catalog (06_DATA_MODEL.md, section
/// 6.1). Implemented in the Data layer (D-13); services/UI depend only on
/// this interface, never on `AppDatabase` directly.
abstract class ExerciseRepository {
  /// Non-archived, non-deleted exercises. Stage 1's catalog list (S-06)
  /// has no search/filters yet — those arrive in Stage 2.
  Stream<List<Exercise>> watchAll();

  Future<Exercise?> getById(String id);

  /// Creates a user-created exercise (S-08, full form — DM 6.1). Only
  /// [name] and [exerciseType] are required; the rest default to "not set"
  /// the same way a fresh `Exercise` row does.
  Future<Exercise> create({
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  });

  /// Overwrites the full DM 6.1 field set of an existing exercise (S-07
  /// "Edit" → S-08 form in edit mode) — every field is replaced with the
  /// value passed in, including nulling out an optional field the caller
  /// omits; there is no partial-update semantics here, the caller always
  /// submits the complete new state. Secondary muscle links are replaced
  /// wholesale in the same transaction. `exerciseType` re-validation
  /// (DM 6.1 lock) is the caller's (`exercise_service`) responsibility.
  Future<Exercise> update({
    required String id,
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  });

  /// Whether [exerciseId] appears in any non-deleted `WorkoutExercise`
  /// (06_DATA_MODEL.md, section 10: "есть в истории" — the deletion rule).
  /// Used regardless of whether any set has actually been logged yet.
  Future<bool> isUsedInWorkouts(String exerciseId);

  /// Whether [exerciseId] has at least one non-deleted `ExerciseSet`
  /// logged against it (06_DATA_MODEL.md, section 6.1: "хоть один подход
  /// в истории" — the exerciseType lock, stricter than [isUsedInWorkouts]).
  Future<bool> hasLoggedSets(String exerciseId);

  Future<void> setArchived(String exerciseId, {required bool archived});

  /// Physically removes the exercise (and cascades its secondary-muscle
  /// links). Callers must have already established it's safe to do so
  /// (`exercise_service`, DM 10) — this just performs the write.
  Future<void> delete(String exerciseId);
}
