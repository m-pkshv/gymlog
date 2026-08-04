import 'package:drift/drift.dart';

import 'common.dart';
import 'reference_tables.dart';

/// Catalog entry: built-in or user-created (06_DATA_MODEL.md, section 6.1).
/// Built-in rows use a stable slug as [id] (needed to update the seed on
/// app updates); user-created rows use a UUID.
/// Indexes per 06_DATA_MODEL.md, section 8.
@DataClassName('Exercise')
@TableIndex(name: 'exercisesIsArchivedIdx', columns: {#isArchived})
@TableIndex.sql(
  'CREATE INDEX exercisesNameIdx ON Exercises (name COLLATE NOCASE)',
)
class Exercises extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  /// 1-80 chars after trim, validated in the service layer. For built-in
  /// exercises this is the canonical English name (used in CSV/search).
  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  TextColumn get youtubeUrl => text().nullable()();

  /// Asset path; only ever populated for built-in exercises (D-3).
  TextColumn get imageAsset => text().nullable()();

  /// Small icon shown in the catalog list (S-06) -- a device file path
  /// (`Image.file`), not a bundled asset like [imageAsset] above. Stage 12/
  /// redesign_v2, owner-requested: user-created exercises can upload their
  /// own icon. Only ever populated for user-created exercises in practice
  /// (built-in ones have no edit form to set it from, DM 10), but nothing
  /// in the schema enforces that.
  TextColumn get customIconPath => text().nullable()();

  /// Large photo shown on the exercise's own card (S-07) -- same file-path
  /// vs. bundled-asset distinction as [customIconPath] above, just the
  /// "big picture" slot instead of the list icon. The two are independent:
  /// setting one doesn't imply or require the other.
  TextColumn get customImagePath => text().nullable()();

  TextColumn get exerciseType => text().customConstraint(
    "NOT NULL CHECK (exerciseType IN ('strength', 'cardio', 'reps', 'time', 'stretch'))",
  )();

  TextColumn get primaryMuscleGroupId =>
      text().nullable().references(MuscleGroups, #id)();

  TextColumn get equipmentId => text().nullable().references(Equipments, #id)();

  TextColumn get effortMetric => text()
      .customConstraint(
        "NOT NULL DEFAULT 'none' CHECK (effortMetric IN ('none', 'rpe', 'rir'))",
      )
      .withDefault(const Constant('none'))();

  /// Reserved for a future exercise-type constructor (D-14); unused in MVP.
  TextColumn get statsMetricsJson => text().nullable()();

  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Secondary muscle groups of an exercise (M:N) (06_DATA_MODEL.md, section
/// 6.2). Deleted alongside the exercise (physical deletion only applies to
/// unused user-created exercises, section 10).
class ExerciseSecondaryMuscles extends Table {
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();

  TextColumn get muscleGroupId => text().references(MuscleGroups, #id)();

  @override
  Set<Column> get primaryKey => {exerciseId, muscleGroupId};
}

/// Localized name/description of a built-in exercise (06_DATA_MODEL.md,
/// section 12). `Exercises.name`/`description` hold the canonical English
/// text; this table holds the per-locale display text written by the seed.
/// Not used for user-created exercises (they aren't translated).
class ExerciseL10n extends Table {
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();

  TextColumn get locale =>
      text().customConstraint("NOT NULL CHECK (locale IN ('ru', 'en'))")();

  TextColumn get name => text()();

  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {exerciseId, locale};
}
