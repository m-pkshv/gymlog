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
  });

  final String id;
  final String measurementTypeId;
  final DateTime date;
  final double valueMetric;
  final MeasurementSource source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  BodyMeasurement copyWith({
    DateTime? date,
    double? valueMetric,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return BodyMeasurement(
      id: id,
      measurementTypeId: measurementTypeId,
      date: date ?? this.date,
      valueMetric: valueMetric ?? this.valueMetric,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
