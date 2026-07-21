import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/import_export_operation.dart';
import '../../domain/repositories/import_export_operation_repository.dart';
import '../database.dart' as drift;
import '../mappers/import_export_operation_mapper.dart';

/// Only the last 50 journal rows are kept (06_DATA_MODEL.md, section 6.13).
const _maxJournalRows = 50;

/// Drift-backed `ImportExportOperationRepository` (06_DATA_MODEL.md, section
/// 6.13).
class ImportExportOperationRepositoryImpl
    implements ImportExportOperationRepository {
  ImportExportOperationRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<ImportExportOperation>> watchAll() {
    final query = _db.select(_db.importExportOperations)
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<ImportExportOperation> startExport({required int formatVersion}) async {
    final operation = ImportExportOperation(
      id: const Uuid().v4(),
      operationType: ImportExportOperationType.export,
      status: ImportExportOperationStatus.inProgress,
      formatVersion: formatVersion,
      startedAt: DateTime.now().toUtc(),
    );
    await _db.transaction(() async {
      await _db
          .into(_db.importExportOperations)
          .insert(operation.toInsertCompanion());
      await _prune();
    });
    return operation;
  }

  Future<void> _prune() async {
    final keptIds =
        await (_db.select(_db.importExportOperations)
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
              ..limit(_maxJournalRows))
            .map((row) => row.id)
            .get();
    await (_db.delete(
      _db.importExportOperations,
    )..where((t) => t.id.isNotIn(keptIds))).go();
  }

  @override
  Future<void> markSuccess({
    required String operationId,
    required ImportExportOperationCounts counts,
  }) async {
    await _write(
      operationId: operationId,
      status: ImportExportOperationStatus.success,
      itemCounts: counts,
    );
  }

  @override
  Future<void> markFailed({
    required String operationId,
    required String errorSummary,
  }) async {
    await _write(
      operationId: operationId,
      status: ImportExportOperationStatus.failed,
      errorSummary: errorSummary,
    );
  }

  Future<void> _write({
    required String operationId,
    required ImportExportOperationStatus status,
    ImportExportOperationCounts? itemCounts,
    String? errorSummary,
  }) async {
    final now = DateTime.now().toUtc();
    await (_db.update(
      _db.importExportOperations,
    )..where((t) => t.id.equals(operationId))).write(
      drift.ImportExportOperationsCompanion(
        status: Value(status.name),
        finishedAt: Value(now.toIso8601String()),
        itemCountsJson: Value(
          itemCounts == null ? null : jsonEncode(itemCounts.toJson()),
        ),
        errorSummary: Value(errorSummary),
      ),
    );
  }
}
