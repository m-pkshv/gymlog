import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/measurement_type.dart';
import '../../domain/repositories/measurement_type_repository.dart';
import '../database.dart' as drift;
import '../mappers/measurement_type_mapper.dart';

/// Drift-backed `MeasurementTypeRepository` (06_DATA_MODEL.md, section 5.3).
class MeasurementTypeRepositoryImpl implements MeasurementTypeRepository {
  MeasurementTypeRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<MeasurementType>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.measurementTypes)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<List<MeasurementType>> getAll() async {
    final rows = await _db.select(_db.measurementTypes).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<MeasurementType?> getById(String id) async {
    final row = await (_db.select(
      _db.measurementTypes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<MeasurementType> create({
    required String nameCustom,
    required MeasurementUnitKind unitKind,
  }) async {
    final type = MeasurementType(
      id: const Uuid().v4(),
      nameCustom: nameCustom,
      unitKind: unitKind,
      isBuiltIn: false,
      isArchived: false,
      sortOrder: 0,
    );
    await _db.into(_db.measurementTypes).insert(type.toInsertCompanion());
    return type;
  }

  @override
  Future<void> setArchived(String id, {required bool archived}) async {
    await (_db.update(
      _db.measurementTypes,
    )..where((t) => t.id.equals(id))).write(
      drift.MeasurementTypesCompanion(isArchived: Value(archived)),
    );
  }

  @override
  Future<bool> hasMeasurements(String id) async {
    final row =
        await (_db.select(_db.bodyMeasurements)
              ..where(
                (m) =>
                    m.measurementTypeId.equals(id) & m.isDeleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> delete(String id) async {
    await (_db.delete(
      _db.measurementTypes,
    )..where((t) => t.id.equals(id))).go();
  }
}
