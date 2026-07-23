import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/body_measurement.dart';
import '../database.dart' as drift;
import 'workout_mapper.dart' show dateOnlyString;

extension BodyMeasurementRowMapper on drift.BodyMeasurement {
  BodyMeasurement toDomain() {
    return BodyMeasurement(
      id: id,
      measurementTypeId: measurementTypeId,
      date: DateTime.parse(date),
      valueMetric: valueMetric,
      source: MeasurementSource.values.byName(source),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension BodyMeasurementCompanionMapper on BodyMeasurement {
  drift.BodyMeasurementsCompanion toInsertCompanion() {
    return drift.BodyMeasurementsCompanion.insert(
      id: id,
      measurementTypeId: measurementTypeId,
      date: dateOnlyString(date),
      valueMetric: valueMetric,
      source: Value(source.name),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.BodyMeasurementsCompanion toUpdateCompanion() {
    return drift.BodyMeasurementsCompanion(
      id: Value(id),
      date: Value(dateOnlyString(date)),
      valueMetric: Value(valueMetric),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
      isDeleted: Value(isDeleted),
    );
  }
}
