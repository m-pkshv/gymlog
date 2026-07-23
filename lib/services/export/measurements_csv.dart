import '../../domain/enums.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/measurement_type.dart';
import 'csv_format.dart';

const measurementsCsvHeader = [
  'date',
  'type',
  'custom_type_name',
  'value',
  'unit',
  'source',
];

String _unitFor(MeasurementUnitKind kind) => switch (kind) {
  MeasurementUnitKind.mass => 'kg',
  MeasurementUnitKind.percent => 'percent',
  MeasurementUnitKind.length => 'cm',
};

/// `measurements.csv` (03_TECHNICAL_SPEC.md, section 10.4). `type` is the
/// built-in slug (== `MeasurementType.id`) or the literal `custom` for
/// user-created types, matching `custom_type_name` to only the latter.
/// [types] must contain every `MeasurementType` referenced by
/// [measurements] (built-in + custom), keyed by id -- this function only
/// formats, it never queries the database. Row order (date, then id) isn't
/// mandated by TS 10.4 the way it is for `workouts.csv`; this is a
/// deterministic default, not a format requirement.
String buildMeasurementsCsv(
  List<BodyMeasurement> measurements,
  Map<String, MeasurementType> types,
) {
  final sorted = [...measurements]..sort((a, b) {
    final byDate = a.date.compareTo(b.date);
    if (byDate != 0) return byDate;
    return a.id.compareTo(b.id);
  });

  final buffer = StringBuffer()..write(csvRow(measurementsCsvHeader));
  for (final measurement in sorted) {
    final type = types[measurement.measurementTypeId]!;
    buffer.write(
      csvRow([
        formatCsvDate(measurement.date),
        type.isBuiltIn ? type.id : 'custom',
        type.isBuiltIn ? '' : (type.nameCustom ?? ''),
        formatCsvDecimal(measurement.valueMetric),
        _unitFor(type.unitKind),
        measurement.source.name,
      ]),
    );
  }
  return buffer.toString();
}
