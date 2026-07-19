import '../database.dart';

/// Built-in muscle groups (06_DATA_MODEL.md, section 5.1). Localized names
/// live in ARB under `muscleGroup.<id>`, not here.
final List<MuscleGroupsCompanion> muscleGroupSeed = [
  MuscleGroupsCompanion.insert(id: 'chest', sortOrder: 0),
  MuscleGroupsCompanion.insert(id: 'back', sortOrder: 1),
  MuscleGroupsCompanion.insert(id: 'shoulders', sortOrder: 2),
  MuscleGroupsCompanion.insert(id: 'biceps', sortOrder: 3),
  MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 4),
  MuscleGroupsCompanion.insert(id: 'forearms', sortOrder: 5),
  MuscleGroupsCompanion.insert(id: 'abs', sortOrder: 6),
  MuscleGroupsCompanion.insert(id: 'glutes', sortOrder: 7),
  MuscleGroupsCompanion.insert(id: 'quads', sortOrder: 8),
  MuscleGroupsCompanion.insert(id: 'hamstrings', sortOrder: 9),
  MuscleGroupsCompanion.insert(id: 'calves', sortOrder: 10),
  MuscleGroupsCompanion.insert(id: 'full_body', sortOrder: 11),
  MuscleGroupsCompanion.insert(id: 'cardio_system', sortOrder: 12),
];

/// Built-in equipment list (06_DATA_MODEL.md, section 5.2). Localized names
/// live in ARB under `equipment.<id>`, not here.
final List<EquipmentsCompanion> equipmentSeed = [
  EquipmentsCompanion.insert(id: 'barbell', sortOrder: 0),
  EquipmentsCompanion.insert(id: 'dumbbell', sortOrder: 1),
  EquipmentsCompanion.insert(id: 'kettlebell', sortOrder: 2),
  EquipmentsCompanion.insert(id: 'machine', sortOrder: 3),
  EquipmentsCompanion.insert(id: 'cable', sortOrder: 4),
  EquipmentsCompanion.insert(id: 'bodyweight', sortOrder: 5),
  EquipmentsCompanion.insert(id: 'band', sortOrder: 6),
  EquipmentsCompanion.insert(id: 'cardio_machine', sortOrder: 7),
  EquipmentsCompanion.insert(id: 'other', sortOrder: 8),
];

/// Built-in body measurement types (06_DATA_MODEL.md, section 5.3).
/// Localized names live in ARB, keyed by [MeasurementType.id].
final List<MeasurementTypesCompanion> measurementTypeSeed = [
  MeasurementTypesCompanion.insert(
    id: 'body_weight',
    unitKind: 'mass',
    isBuiltIn: true,
    sortOrder: 0,
  ),
  MeasurementTypesCompanion.insert(
    id: 'body_fat',
    unitKind: 'percent',
    isBuiltIn: true,
    sortOrder: 1,
  ),
  MeasurementTypesCompanion.insert(
    id: 'neck',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 2,
  ),
  MeasurementTypesCompanion.insert(
    id: 'shoulders_girth',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 3,
  ),
  MeasurementTypesCompanion.insert(
    id: 'chest_girth',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 4,
  ),
  MeasurementTypesCompanion.insert(
    id: 'waist',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 5,
  ),
  MeasurementTypesCompanion.insert(
    id: 'hips',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 6,
  ),
  MeasurementTypesCompanion.insert(
    id: 'biceps_left',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 7,
  ),
  MeasurementTypesCompanion.insert(
    id: 'biceps_right',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 8,
  ),
  MeasurementTypesCompanion.insert(
    id: 'forearm_left',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 9,
  ),
  MeasurementTypesCompanion.insert(
    id: 'forearm_right',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 10,
  ),
  MeasurementTypesCompanion.insert(
    id: 'thigh_left',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 11,
  ),
  MeasurementTypesCompanion.insert(
    id: 'thigh_right',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 12,
  ),
  MeasurementTypesCompanion.insert(
    id: 'calf_left',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 13,
  ),
  MeasurementTypesCompanion.insert(
    id: 'calf_right',
    unitKind: 'length',
    isBuiltIn: true,
    sortOrder: 14,
  ),
];

/// Inserts the built-in reference data. Called once by `SeedRunner`, inside
/// its transaction, so this doesn't guard against being run twice itself.
Future<void> insertReferenceDataSeed(AppDatabase db) async {
  await db.batch((batch) {
    batch.insertAll(db.muscleGroups, muscleGroupSeed);
    batch.insertAll(db.equipments, equipmentSeed);
    batch.insertAll(db.measurementTypes, measurementTypeSeed);
  });
}
