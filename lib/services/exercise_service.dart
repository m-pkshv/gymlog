import '../core/app_error.dart';
import '../core/result.dart';
import '../domain/enums.dart';
import '../domain/models/exercise.dart';
import '../domain/repositories/exercise_repository.dart';

/// Deletion/archiving rules (06_DATA_MODEL.md, section 10) and the
/// exerciseType lock (section 6.1) for the exercise catalog. The single
/// point of truth for whether an exercise may be edited/archived/deleted —
/// no other layer decides this (03_TECHNICAL_SPEC.md, section 4, mirroring
/// `workout_service`'s role for `Workout.status`).
class ExerciseService {
  ExerciseService(this._exerciseRepository);

  final ExerciseRepository _exerciseRepository;

  /// DM 6.1: exerciseType is locked once at least one set has been logged
  /// against the exercise, regardless of whether it was ever added to a
  /// workout without logging anything (see [ExerciseRepository.hasLoggedSets]
  /// vs. [ExerciseRepository.isUsedInWorkouts]).
  Future<bool> canChangeType(String exerciseId) async {
    return !(await _exerciseRepository.hasLoggedSets(exerciseId));
  }

  /// Creates a new exercise (S-08, Stage 10, owner-reported: name must be
  /// unique across the whole catalog, not just among user-created entries —
  /// see [isNameTaken]). The single point of truth for this rule, mirroring
  /// [update]'s re-check below; `CreateExerciseScreen` also pre-checks via
  /// [isNameTaken] for an inline error, but this is the authoritative check.
  Future<Result<Exercise, AppError>> create({
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationError('Exercise name is required'));
    }
    if (await _isDuplicateName(trimmed)) {
      return const Err(
        ValidationError('An exercise with this name already exists'),
      );
    }
    final created = await _exerciseRepository.create(
      name: trimmed,
      exerciseType: exerciseType,
      description: description,
      youtubeUrl: youtubeUrl,
      primaryMuscleGroupId: primaryMuscleGroupId,
      equipmentId: equipmentId,
      effortMetric: effortMetric,
      secondaryMuscleGroupIds: secondaryMuscleGroupIds,
    );
    return Ok(created);
  }

  /// Saves edits to an existing exercise (S-07 "Edit" → S-08 form in edit
  /// mode, DM 6.1). Re-checks the exerciseType lock server-side even though
  /// the UI already disables the field once locked — the single point of
  /// truth for this rule shouldn't trust the caller (mirrors
  /// [canChangeType]'s role for the UI-side check).
  Future<Result<Exercise, AppError>> update({
    required Exercise current,
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  }) async {
    if (exerciseType != current.exerciseType &&
        !(await canChangeType(current.id))) {
      return const Err(
        ValidationError(
          'exerciseType is locked once a set has been logged against this '
          'exercise',
        ),
      );
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Err(ValidationError('Exercise name is required'));
    }
    if (await _isDuplicateName(trimmed, excludeId: current.id)) {
      return const Err(
        ValidationError('An exercise with this name already exists'),
      );
    }
    final updated = await _exerciseRepository.update(
      id: current.id,
      name: trimmed,
      exerciseType: exerciseType,
      description: description,
      youtubeUrl: youtubeUrl,
      primaryMuscleGroupId: primaryMuscleGroupId,
      equipmentId: equipmentId,
      effortMetric: effortMetric,
      secondaryMuscleGroupIds: secondaryMuscleGroupIds,
    );
    return Ok(updated);
  }

  /// Whether [name] collides with an existing exercise (Stage 10,
  /// owner-reported: "проверять среди всех" — built-in and user-created
  /// alike, case-insensitively, archived exercises excluded so a retired
  /// name can be reused). [excludeId], when editing, leaves that exercise's
  /// own row out of the comparison so saving without renaming never trips
  /// on itself. `CreateExerciseScreen` calls this directly for a proactive
  /// inline field error; [create]/[update] re-check the same rule
  /// server-side regardless.
  Future<bool> isNameTaken(String name, {String? excludeId}) {
    return _isDuplicateName(name.trim(), excludeId: excludeId);
  }

  Future<bool> _isDuplicateName(
    String trimmedName, {
    String? excludeId,
  }) async {
    final all = await _exerciseRepository.getAllForExport();
    final lower = trimmedName.toLowerCase();
    return all.any(
      (exercise) =>
          !exercise.isArchived &&
          exercise.id != excludeId &&
          exercise.name.toLowerCase() == lower,
    );
  }

  /// Archiving is always available — built-in or user-created, used or not
  /// (DM 10: it only hides the exercise from the catalog/picker; history is
  /// unaffected).
  Future<Result<Exercise, AppError>> archive(Exercise exercise) async {
    await _exerciseRepository.setArchived(exercise.id, archived: true);
    return Ok(
      exercise.copyWith(isArchived: true, updatedAt: DateTime.now().toUtc()),
    );
  }

  Future<Result<Exercise, AppError>> unarchive(Exercise exercise) async {
    await _exerciseRepository.setArchived(exercise.id, archived: false);
    return Ok(
      exercise.copyWith(isArchived: false, updatedAt: DateTime.now().toUtc()),
    );
  }

  /// Whether the UI should offer "Delete" at all (S-07) — DM 10: built-in
  /// exercises never can, user-created ones only once unused. [delete]
  /// re-checks this itself; this is for the UI to decide which action
  /// ("Delete" vs. "Archive") to show in the first place.
  Future<bool> canDelete(Exercise exercise) async {
    if (exercise.isBuiltIn) return false;
    return !(await _exerciseRepository.isUsedInWorkouts(exercise.id));
  }

  /// DM 10: built-in exercises can never be physically deleted; a
  /// user-created exercise can only be deleted once it isn't used anywhere
  /// — otherwise the caller should archive instead (the UI substitutes
  /// "Archive" for "Delete" in that case, per S-07).
  Future<Result<Exercise, AppError>> delete(Exercise exercise) async {
    if (exercise.isBuiltIn) {
      return const Err(
        ValidationError(
          'Built-in exercises cannot be deleted, only archived',
        ),
      );
    }
    if (await _exerciseRepository.isUsedInWorkouts(exercise.id)) {
      return const Err(
        ValidationError(
          'Exercise is used in a workout and cannot be deleted; archive it instead',
        ),
      );
    }
    await _exerciseRepository.delete(exercise.id);
    return Ok(exercise);
  }
}
