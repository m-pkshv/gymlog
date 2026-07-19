import 'package:drift/drift.dart';

/// Single-row app settings table (06_DATA_MODEL.md, section 6.12). The
/// service layer always writes/reads the row with `id = 'singleton'`.
@DataClassName('AppSettingsRow')
class AppSettingsTable extends Table {
  TextColumn get id => text()();

  TextColumn get unitSystem => text()
      .customConstraint(
        "NOT NULL DEFAULT 'metric' CHECK (unitSystem IN ('metric', 'imperial'))",
      )
      .withDefault(const Constant('metric'))();

  TextColumn get theme => text()
      .customConstraint(
        "NOT NULL DEFAULT 'system' CHECK (theme IN ('system', 'light', 'dark'))",
      )
      .withDefault(const Constant('system'))();

  TextColumn get locale => text()
      .customConstraint(
        "NOT NULL DEFAULT 'system' CHECK (locale IN ('system', 'ru', 'en'))",
      )
      .withDefault(const Constant('system'))();

  BoolColumn get showTags => boolean().withDefault(const Constant(true))();

  /// Seconds, 10-600 (validated in the service layer). Default 120 (Q-4).
  IntColumn get defaultRestTimerSec =>
      integer().withDefault(const Constant(120))();

  BoolColumn get restTimerAutoStart =>
      boolean().withDefault(const Constant(true))();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Export/import operation log (06_DATA_MODEL.md, section 6.13). Only the
/// last 50 rows are kept; older ones are physically deleted.
@DataClassName('ImportExportOperation')
class ImportExportOperations extends Table {
  TextColumn get id => text()();

  TextColumn get operationType => text()
      .customConstraint(
        "NOT NULL DEFAULT 'export' CHECK (operationType IN ('export', 'import'))",
      )
      .withDefault(const Constant('export'))();

  TextColumn get status => text().customConstraint(
    "NOT NULL CHECK (status IN ('inProgress', 'success', 'failed'))",
  )();

  IntColumn get formatVersion => integer()();

  TextColumn get startedAt => text()();

  TextColumn get finishedAt => text().nullable()();

  TextColumn get itemCountsJson => text().nullable()();

  TextColumn get errorSummary => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bookkeeping for the built-in content seed (06_DATA_MODEL.md, section
/// 12): a single row whose presence/version tells the app whether the seed
/// already ran and which version it is at.
@DataClassName('SeedInfoRow')
class SeedInfoTable extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();

  IntColumn get seedVersion => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
