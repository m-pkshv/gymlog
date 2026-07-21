import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/enums.dart';
import '../domain/models/body_measurement.dart';
import '../domain/repositories/body_measurement_repository.dart';
import '../domain/repositories/measurement_type_repository.dart';

/// Range validation (06_DATA_MODEL.md, section 6.9) and the same-day
/// duplicate rule for `BodyMeasurement` — the single point of truth for
/// whether a measurement value may be saved, mirroring `workout_service`'s
/// role for `Workout.status`. Soft-delete/restore (DM 10) has no business
/// rule beyond the Undo window itself, so — like `WorkoutTemplateRepository`
/// archiving (Stage 5) — the UI calls `BodyMeasurementRepository.delete`/
/// `restore` directly, no wrapper needed here.
class BodyMeasurementService {
  BodyMeasurementService(this._repository, this._typeRepository);

  final BodyMeasurementRepository _repository;
  final MeasurementTypeRepository _typeRepository;

  /// DM 6.9: "Не более одной записи на тип в день: при совпадении —
  /// предложение заменить." The UI calls this before [create]; if it
  /// returns non-null, show the "Заменить существующее значение?" dialog
  /// (S-15) and call [update] on the returned entry instead of [create].
  Future<BodyMeasurement?> findExistingForDay({
    required String measurementTypeId,
    required DateTime date,
  }) {
    return _repository.getByTypeAndDate(
      measurementTypeId: measurementTypeId,
      date: date,
    );
  }

  /// Creates a new entry. Callers are expected to have already checked
  /// [findExistingForDay] and confirmed with the user if it returned an
  /// existing entry — this does not re-check or block on a same-day
  /// duplicate itself (DM 6.9 makes it a replace-prompt, not a hard
  /// rejection).
  Future<Result<BodyMeasurement, AppError>> create({
    required String measurementTypeId,
    required DateTime date,
    required double valueMetric,
    String? comment,
  }) async {
    final rangeError = await _validateRange(measurementTypeId, valueMetric);
    if (rangeError != null) return Err(rangeError);
    final created = await _repository.create(
      measurementTypeId: measurementTypeId,
      date: date,
      valueMetric: valueMetric,
      comment: comment,
    );
    return Ok(created);
  }

  /// Validates and persists edits to an existing entry — covers both the DM
  /// 6.9 same-day replace flow (S-15 "Заменить существующее значение?",
  /// [date] left unchanged) and editing an entry's own fields from the list.
  Future<Result<BodyMeasurement, AppError>> update({
    required BodyMeasurement existing,
    DateTime? date,
    required double valueMetric,
    String? comment,
  }) async {
    final rangeError = await _validateRange(
      existing.measurementTypeId,
      valueMetric,
    );
    if (rangeError != null) return Err(rangeError);
    final updated = existing.copyWith(
      date: date,
      valueMetric: valueMetric,
      comment: comment,
    );
    await _repository.update(updated);
    return Ok(updated);
  }

  Future<AppError?> _validateRange(
    String measurementTypeId,
    double valueMetric,
  ) async {
    final type = await _typeRepository.getById(measurementTypeId);
    if (type == null) {
      return const ValidationError('Measurement type not found');
    }
    final (min, max) = _rangeFor(type.unitKind);
    if (valueMetric < min || valueMetric > max) {
      return ValidationError('Value must be between $min and $max');
    }
    return null;
  }

  (double, double) _rangeFor(MeasurementUnitKind unitKind) {
    switch (unitKind) {
      case MeasurementUnitKind.mass:
        return (
          MeasurementValueRange.minMassKg,
          MeasurementValueRange.maxMassKg,
        );
      case MeasurementUnitKind.percent:
        return (
          MeasurementValueRange.minPercent,
          MeasurementValueRange.maxPercent,
        );
      case MeasurementUnitKind.length:
        return (
          MeasurementValueRange.minLengthCm,
          MeasurementValueRange.maxLengthCm,
        );
    }
  }
}
