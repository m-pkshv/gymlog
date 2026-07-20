import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/models/workout_tag.dart';
import '../domain/repositories/workout_tag_repository.dart';

/// Creation rules for `WorkoutTag` (06_DATA_MODEL.md, section 6.3) — the
/// single point of truth for whether a tag name is valid, mirroring
/// `exercise_service`'s role for the exercise catalog. Assignment itself
/// (`WorkoutRepository.setWorkoutTags`) has no business rule beyond "the
/// tag exists", so it doesn't need a service method here.
class WorkoutTagService {
  WorkoutTagService(this._repository);

  final WorkoutTagRepository _repository;

  /// DM 6.3: 1-30 chars, unique among non-deleted tags case-insensitively.
  Future<Result<WorkoutTag, AppError>> create({
    required String name,
    required String colorHex,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > WorkoutTagRules.maxNameLength) {
      return const Err(
        ValidationError('Tag name must be 1-30 characters'),
      );
    }
    final existing = await _repository.getAll();
    final isDuplicate = existing.any(
      (tag) => tag.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (isDuplicate) {
      return const Err(
        ValidationError('A tag with this name already exists'),
      );
    }
    final created = await _repository.create(
      name: trimmed,
      colorHex: colorHex,
    );
    return Ok(created);
  }
}
