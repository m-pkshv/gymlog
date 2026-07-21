import '../enums.dart';

/// One body measurement entry (06_DATA_MODEL.md, section 6.9). [date] is a
/// local calendar date (no time-of-day) — DM 6.9 stores it as `YYYY-MM-DD`
/// and allows at most one entry per [measurementTypeId] per [date]; the
/// service layer offers to replace an existing same-day entry instead of a
/// DB-level uniqueness constraint (the table's index on
/// `(measurementTypeId, date)` is only for lookup speed).
class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.measurementTypeId,
    required this.date,
    required this.valueMetric,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.comment,
  });

  final String id;
  final String measurementTypeId;
  final DateTime date;
  final double valueMetric;
  final MeasurementSource source;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// Sentinel default for [comment]: distinguishes "not passed, keep the
  /// current value" from "explicitly passed `null`, clear the field" — same
  /// reasoning as `ExerciseSet.copyWith` (Stage 1).
  static const Object _unset = Object();

  BodyMeasurement copyWith({
    DateTime? date,
    double? valueMetric,
    Object? comment = _unset,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return BodyMeasurement(
      id: id,
      measurementTypeId: measurementTypeId,
      date: date ?? this.date,
      valueMetric: valueMetric ?? this.valueMetric,
      source: source,
      comment: identical(comment, _unset) ? this.comment : comment as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
