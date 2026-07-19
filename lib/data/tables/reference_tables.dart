import 'package:drift/drift.dart';

/// Built-in muscle group reference list (06_DATA_MODEL.md, section 5.1).
/// Localized names live in ARB under `muscleGroup.<id>`, not in this table.
@DataClassName('MuscleGroup')
class MuscleGroups extends Table {
  TextColumn get id => text()();

  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Built-in equipment reference list (06_DATA_MODEL.md, section 5.2).
/// Localized names live in ARB under `equipment.<id>`, not in this table.
@DataClassName('Equipment')
class Equipments extends Table {
  TextColumn get id => text()();

  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Body measurement types: built-in (stable slug id) and user-created (UUID
/// id) (06_DATA_MODEL.md, section 5.3). Built-in rows have [nameCustom] ==
/// null; their display name comes from ARB instead.
@DataClassName('MeasurementType')
class MeasurementTypes extends Table {
  TextColumn get id => text()();

  TextColumn get nameCustom => text().nullable()();

  TextColumn get unitKind => text().customConstraint(
    "NOT NULL CHECK (unitKind IN ('mass', 'percent', 'length'))",
  )();

  BoolColumn get isBuiltIn => boolean()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  IntColumn get sortOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
