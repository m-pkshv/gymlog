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
