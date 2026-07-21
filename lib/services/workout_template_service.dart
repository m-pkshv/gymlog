import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/models/workout_template.dart';
import '../domain/repositories/workout_template_repository.dart';

/// Creation rules for `WorkoutTemplate` (06_DATA_MODEL.md, section 6.8) —
/// the single point of truth for whether a template name is valid,
/// mirroring `workout_tag_service`'s role for tag names. DM 6.8 doesn't
/// require uniqueness (unlike tags), only the 1-80 length bound.
class WorkoutTemplateService {
  WorkoutTemplateService(this._repository);

  final WorkoutTemplateRepository _repository;

  /// DM 6.8: name is 1-80 chars.
  Future<Result<WorkoutTemplate, AppError>> create({
    required String name,
    String? comment,
  }) async {
    final trimmed = _validatedName(name);
    if (trimmed == null) {
      return const Err(
        ValidationError('Template name must be 1-80 characters'),
      );
    }
    final created = await _repository.create(name: trimmed, comment: comment);
    return Ok(created);
  }

  /// "Создать шаблон" (S-02/S-03, TS 8 section 8) — same name validation as
  /// [create], delegating the actual copy to
  /// `WorkoutTemplateRepository.createFromWorkout`.
  Future<Result<WorkoutTemplate, AppError>> createFromWorkout({
    required String workoutId,
    required String name,
  }) async {
    final trimmed = _validatedName(name);
    if (trimmed == null) {
      return const Err(
        ValidationError('Template name must be 1-80 characters'),
      );
    }
    final created = await _repository.createFromWorkout(
      workoutId: workoutId,
      name: trimmed,
    );
    return Ok(created);
  }

  /// "Дублировать" (S-12, 04_UI_UX_SPEC.md section 5) — same name
  /// validation as [create], delegating the actual clone to
  /// `WorkoutTemplateRepository.duplicate`.
  Future<Result<WorkoutTemplate, AppError>> duplicate({
    required String templateId,
    required String name,
  }) async {
    final trimmed = _validatedName(name);
    if (trimmed == null) {
      return const Err(
        ValidationError('Template name must be 1-80 characters'),
      );
    }
    final created = await _repository.duplicate(
      templateId: templateId,
      name: trimmed,
    );
    return Ok(created);
  }

  /// Trims [name] and returns it if it satisfies DM 6.8's 1-80 char bound,
  /// `null` otherwise.
  String? _validatedName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > WorkoutTemplateRules.maxNameLength) {
      return null;
    }
    return trimmed;
  }
}
