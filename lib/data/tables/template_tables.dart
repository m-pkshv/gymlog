import 'package:drift/drift.dart';

import 'common.dart';
import 'exercise_tables.dart';

/// A workout template (06_DATA_MODEL.md, section 6.8, D-16). Stored
/// separately from workouts by construction, so templates are excluded
/// from history/statistics by design, not by filters.
@DataClassName('WorkoutTemplate')
class WorkoutTemplates extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get comment => text().nullable()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// An exercise entry within a template (06_DATA_MODEL.md, section 6.8).
@DataClassName('TemplateExercise')
class TemplateExercises extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get templateId => text().references(WorkoutTemplates, #id)();

  TextColumn get exerciseId => text().references(Exercises, #id)();

  IntColumn get orderIndex => integer()();

  TextColumn get comment => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A planned set within a template exercise (06_DATA_MODEL.md, section
/// 6.8). Only planned metrics exist here — templates never carry facts.
@DataClassName('TemplateSet')
class TemplateSets extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get templateExerciseId =>
      text().references(TemplateExercises, #id)();

  IntColumn get setNumber => integer()();

  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  RealColumn get plannedWeightKg => real().nullable()();

  IntColumn get plannedReps => integer().nullable()();

  IntColumn get plannedDurationSec => integer().nullable()();

  RealColumn get plannedDistanceM => real().nullable()();

  TextColumn get side => text()
      .customConstraint(
        "NOT NULL DEFAULT 'none' CHECK (side IN ('none', 'left', 'right', 'both'))",
      )
      .withDefault(const Constant('none'))();

  @override
  Set<Column> get primaryKey => {id};
}
