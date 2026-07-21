import '../models/body_measurement.dart';

/// Storage contract for `BodyMeasurement` (06_DATA_MODEL.md, section 6.9).
/// Implemented in the Data layer (D-13); services/UI depend only on this
/// interface, never on `AppDatabase` directly. Range validation and the
/// same-day-duplicate prompt (DM 6.9) are `BodyMeasurementService`'s job,
/// not this contract's.
abstract class BodyMeasurementRepository {
  /// Non-deleted entries for one measurement type, newest date first (S-14
  /// list + graph).
  Stream<List<BodyMeasurement>> watchByType(String measurementTypeId);

  /// The one non-deleted entry for [measurementTypeId] on [date], if any —
  /// used to detect the DM 6.9 same-day duplicate before creating a new
  /// entry.
  Future<BodyMeasurement?> getByTypeAndDate({
    required String measurementTypeId,
    required DateTime date,
  });

  Future<BodyMeasurement> create({
    required String measurementTypeId,
    required DateTime date,
    required double valueMetric,
    String? comment,
  });

  /// Overwrites [measurement]'s mutable fields (date, value, comment) —
  /// the caller (S-15 "replace existing?", or an edit) always submits the
  /// complete new state, mirroring `WorkoutTemplateRepository.update`.
  Future<void> update(BodyMeasurement measurement);

  /// Soft-deletes [id] (DM 10: "Измерение — мягкое удаление + Undo").
  Future<void> delete(String id);

  /// Reverses [delete] within the Undo window.
  Future<void> restore(String id);
}
