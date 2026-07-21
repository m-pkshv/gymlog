import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/enums.dart';
import '../domain/models/measurement_type.dart';
import '../domain/repositories/measurement_type_repository.dart';

/// Creation, archiving and deletion rules for `MeasurementType`
/// (06_DATA_MODEL.md, sections 5.3 and 10) — the single point of truth,
/// mirroring `WorkoutTagService`'s role for tags and `ExerciseService`'s
/// role for the exercise catalog.
class MeasurementTypeService {
  MeasurementTypeService(this._repository);

  final MeasurementTypeRepository _repository;

  /// DM 5.3: 1-60 chars, unique among non-archived custom types
  /// case-insensitively (built-in types have no `nameCustom` at all, so
  /// they never collide with a custom name).
  Future<Result<MeasurementType, AppError>> create({
    required String nameCustom,
    required MeasurementUnitKind unitKind,
  }) async {
    final trimmed = nameCustom.trim();
    if (trimmed.isEmpty ||
        trimmed.length > MeasurementTypeRules.maxNameLength) {
      return const Err(
        ValidationError('Measurement type name must be 1-60 characters'),
      );
    }
    final existing = await _repository.getAll();
    final isDuplicate = existing.any(
      (type) =>
          !type.isArchived &&
          type.nameCustom?.toLowerCase() == trimmed.toLowerCase(),
    );
    if (isDuplicate) {
      return const Err(
        ValidationError('A measurement type with this name already exists'),
      );
    }
    final created = await _repository.create(
      nameCustom: trimmed,
      unitKind: unitKind,
    );
    return Ok(created);
  }

  /// DM 5.3 describes `isArchived` as hiding a *custom* type
  /// ("Скрытие пользовательского типа"); 04_UI_UX_SPEC.md's S-14 only offers
  /// "Управление пользовательскими типами" (no archive action for the 15
  /// built-in types at all, unlike `ExerciseService.archive` which allows
  /// archiving built-in exercises). `ASSUMPTION(builtin-types-not-archivable)`:
  /// built-in types are always available and can't be archived.
  Future<Result<MeasurementType, AppError>> archive(
    MeasurementType type,
  ) async {
    if (type.isBuiltIn) {
      return const Err(
        ValidationError('Built-in measurement types cannot be archived'),
      );
    }
    await _repository.setArchived(type.id, archived: true);
    return Ok(type.copyWith(isArchived: true));
  }

  Future<Result<MeasurementType, AppError>> unarchive(
    MeasurementType type,
  ) async {
    await _repository.setArchived(type.id, archived: false);
    return Ok(type.copyWith(isArchived: false));
  }

  /// Whether the UI should offer "Delete" at all (S-14) — DM 10: built-in
  /// types never can, user-created ones only once they have no measurements
  /// logged against them. [delete] re-checks this itself; this is for the
  /// UI to decide which action to show in the first place (mirrors
  /// `ExerciseService.canDelete`).
  Future<bool> canDelete(MeasurementType type) async {
    if (type.isBuiltIn) return false;
    return !(await _repository.hasMeasurements(type.id));
  }

  /// DM 10: "MeasurementType пользовательский | Если есть измерения —
  /// только архивация; иначе физическое удаление." Built-in types can never
  /// be deleted.
  Future<Result<MeasurementType, AppError>> delete(
    MeasurementType type,
  ) async {
    if (type.isBuiltIn) {
      return const Err(
        ValidationError('Built-in measurement types cannot be deleted'),
      );
    }
    if (await _repository.hasMeasurements(type.id)) {
      return const Err(
        ValidationError(
          'Measurement type has entries and cannot be deleted; archive it '
          'instead',
        ),
      );
    }
    await _repository.delete(type.id);
    return Ok(type);
  }
}
