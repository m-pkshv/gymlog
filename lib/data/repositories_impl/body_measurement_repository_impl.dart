import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/repositories/body_measurement_repository.dart';
import '../database.dart' as drift;
import '../mappers/body_measurement_mapper.dart';
import '../mappers/workout_mapper.dart' show dateOnlyString;

/// Drift-backed `BodyMeasurementRepository` (06_DATA_MODEL.md, section 6.9).
class BodyMeasurementRepositoryImpl implements BodyMeasurementRepository {
  BodyMeasurementRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<BodyMeasurement>> watchByType(
    String measurementTypeId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = _db.select(_db.bodyMeasurements)
      ..where(
        (m) =>
            m.measurementTypeId.equals(measurementTypeId) &
            m.isDeleted.equals(false),
      )
      ..orderBy([(m) => OrderingTerm.desc(m.date)]);
    if (from != null) {
      query.where((m) => m.date.isBiggerOrEqualValue(dateOnlyString(from)));
    }
    if (to != null) {
      query.where((m) => m.date.isSmallerOrEqualValue(dateOnlyString(to)));
    }
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<BodyMeasurement?> getByTypeAndDate({
    required String measurementTypeId,
    required DateTime date,
  }) async {
    final row =
        await (_db.select(_db.bodyMeasurements)..where(
              (m) =>
                  m.measurementTypeId.equals(measurementTypeId) &
                  m.date.equals(dateOnlyString(date)) &
                  m.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<BodyMeasurement> create({
    required String measurementTypeId,
    required DateTime date,
    required double valueMetric,
  }) async {
    final now = DateTime.now().toUtc();
    final measurement = BodyMeasurement(
      id: const Uuid().v4(),
      measurementTypeId: measurementTypeId,
      date: date,
      valueMetric: valueMetric,
      source: MeasurementSource.manual,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db
        .into(_db.bodyMeasurements)
        .insert(measurement.toInsertCompanion());
    return measurement;
  }

  @override
  Future<void> update(BodyMeasurement measurement) async {
    await (_db.update(
      _db.bodyMeasurements,
    )..where((m) => m.id.equals(measurement.id))).write(
      measurement
          .copyWith(updatedAt: DateTime.now().toUtc())
          .toUpdateCompanion(),
    );
  }

  @override
  Future<void> delete(String id) async {
    await (_db.update(_db.bodyMeasurements)..where((m) => m.id.equals(id)))
        .write(
          drift.BodyMeasurementsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
  }

  @override
  Future<void> restore(String id) async {
    await (_db.update(_db.bodyMeasurements)..where((m) => m.id.equals(id)))
        .write(
          drift.BodyMeasurementsCompanion(
            isDeleted: const Value(false),
            updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
          ),
        );
  }

  @override
  Future<List<BodyMeasurement>> getAllForExport() async {
    final rows = await (_db.select(
      _db.bodyMeasurements,
    )..where((m) => m.isDeleted.equals(false))).get();
    return rows.map((row) => row.toDomain()).toList();
  }
}
