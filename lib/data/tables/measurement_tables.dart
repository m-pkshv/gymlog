import 'package:drift/drift.dart';

import 'common.dart';
import 'reference_tables.dart';

/// A body measurement entry (06_DATA_MODEL.md, section 6.9). At most one
/// entry per [measurementTypeId] per [date] is intended; the service layer
/// offers to replace an existing same-day entry instead of enforcing a
/// DB-level uniqueness constraint.
@DataClassName('BodyMeasurement')
@TableIndex(
  name: 'bodyMeasurementsTypeDateIdx',
  columns: {#measurementTypeId, #date},
)
class BodyMeasurements extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get measurementTypeId =>
      text().references(MeasurementTypes, #id)();

  /// Local calendar date `YYYY-MM-DD`.
  TextColumn get date => text()();

  RealColumn get valueMetric => real()();

  TextColumn get source => text()
      .customConstraint(
        "NOT NULL DEFAULT 'manual' CHECK (source IN ('manual', 'import', 'health'))",
      )
      .withDefault(const Constant('manual'))();

  @override
  Set<Column> get primaryKey => {id};
}
