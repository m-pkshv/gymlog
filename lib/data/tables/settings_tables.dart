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

/// Single-row user profile (06_DATA_MODEL.md, section 6.15, Stage 11) --
/// nickname/first/last name plus a path to a locally-copied avatar image.
/// The service layer always writes/reads the row with `id = 'singleton'`,
/// same convention as [AppSettingsTable].
@DataClassName('UserProfileRow')
class UserProfileTable extends Table {
  TextColumn get id => text()();

  TextColumn get nickname => text().nullable()();

  TextColumn get firstName => text().nullable()();

  TextColumn get lastName => text().nullable()();

  /// Absolute path to the copied avatar file under the app's documents
  /// directory (same directory as `gymlog.sqlite`), or NULL if no avatar
  /// has been set.
  TextColumn get avatarPath => text().nullable()();

  TextColumn get updatedAt => text()();

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
