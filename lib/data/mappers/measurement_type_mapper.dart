import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/measurement_type.dart';
import '../database.dart' as drift;

extension MeasurementTypeRowMapper on drift.MeasurementType {
  MeasurementType toDomain() {
    return MeasurementType(
      id: id,
      nameCustom: nameCustom,
      unitKind: MeasurementUnitKind.values.byName(unitKind),
      isBuiltIn: isBuiltIn,
      isArchived: isArchived,
      sortOrder: sortOrder,
    );
  }
}

extension MeasurementTypeCompanionMapper on MeasurementType {
  drift.MeasurementTypesCompanion toInsertCompanion() {
    return drift.MeasurementTypesCompanion.insert(
      id: id,
      nameCustom: Value(nameCustom),
      unitKind: unitKind.name,
      isBuiltIn: isBuiltIn,
      isArchived: Value(isArchived),
      sortOrder: sortOrder,
    );
  }

  drift.MeasurementTypesCompanion toUpdateCompanion() {
    return drift.MeasurementTypesCompanion(
      id: Value(id),
      nameCustom: Value(nameCustom),
      isArchived: Value(isArchived),
    );
  }
}
