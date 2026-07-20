import '../../core/reference_data_ids.dart';
import '../database.dart';

/// Built-in muscle groups (06_DATA_MODEL.md, section 5.1), built from the
/// canonical id list so the seed can never drift from the exercise form's
/// picker. Localized names live in ARB.
final List<MuscleGroupsCompanion> muscleGroupSeed = [
  for (var i = 0; i < muscleGroupIds.length; i++)
    MuscleGroupsCompanion.insert(id: muscleGroupIds[i], sortOrder: i),
];

/// Built-in equipment list (06_DATA_MODEL.md, section 5.2), same rationale
/// as [muscleGroupSeed].
final List<EquipmentsCompanion> equipmentSeed = [
  for (var i = 0; i < equipmentIds.length; i++)
    EquipmentsCompanion.insert(id: equipmentIds[i], sortOrder: i),
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
