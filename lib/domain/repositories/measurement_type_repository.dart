import '../enums.dart';
import '../models/measurement_type.dart';

/// Storage contract for `MeasurementType` (06_DATA_MODEL.md, section 5.3).
/// Implemented in the Data layer (D-13); services/UI depend only on this
/// interface, never on `AppDatabase` directly. Name-length/uniqueness
/// validation (DM 5.3) is `MeasurementTypeService`'s job, not this
/// contract's.
abstract class MeasurementTypeRepository {
  /// Built-in + user-created types, sorted by [MeasurementType.sortOrder]
  /// (S-14 tabs). Archived types excluded unless [includeArchived] — same
  /// default as the exercise catalog (S-06); built-in types are never
  /// archived in practice (DM 5.3/04 S-14: only user-created types have
  /// archive UI).
  Stream<List<MeasurementType>> watchAll({bool includeArchived = false});

  /// One-shot read of the same set [watchAll] streams, used for the
  /// uniqueness check in `MeasurementTypeService.create`.
  Future<List<MeasurementType>> getAll();

  Future<MeasurementType?> getById(String id);

  /// Creates a user-created measurement type (S-14 "Добавить замер…", DM
  /// 5.3).
  Future<MeasurementType> create({
    required String nameCustom,
    required MeasurementUnitKind unitKind,
  });

  Future<void> setArchived(String id, {required bool archived});

  /// Whether [id] has at least one non-deleted `BodyMeasurement` logged
  /// against it (06_DATA_MODEL.md, section 10 — the user-created-type
  /// deletion rule).
  Future<bool> hasMeasurements(String id);

  /// Physically removes a user-created measurement type. Callers must have
  /// already established it's safe to do so (`MeasurementTypeService`, DM
  /// 10) — this just performs the write.
  Future<void> delete(String id);
}
