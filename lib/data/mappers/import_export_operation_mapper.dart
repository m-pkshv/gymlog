import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/import_export_operation.dart';
import '../database.dart' as drift;

extension ImportExportOperationRowMapper on drift.ImportExportOperation {
  ImportExportOperation toDomain() {
    return ImportExportOperation(
      id: id,
      operationType: ImportExportOperationType.values.byName(operationType),
      status: ImportExportOperationStatus.values.byName(status),
      formatVersion: formatVersion,
      startedAt: DateTime.parse(startedAt),
      finishedAt: finishedAt == null ? null : DateTime.parse(finishedAt!),
      itemCounts: itemCountsJson == null
          ? null
          : ImportExportOperationCounts.fromJson(
              jsonDecode(itemCountsJson!) as Map<String, dynamic>,
            ),
      errorSummary: errorSummary,
    );
  }
}

extension ImportExportOperationCompanionMapper on ImportExportOperation {
  drift.ImportExportOperationsCompanion toInsertCompanion() {
    return drift.ImportExportOperationsCompanion.insert(
      id: id,
      operationType: Value(operationType.name),
      status: status.name,
      formatVersion: formatVersion,
      startedAt: startedAt.toUtc().toIso8601String(),
      finishedAt: Value(finishedAt?.toUtc().toIso8601String()),
      itemCountsJson: Value(
        itemCounts == null ? null : jsonEncode(itemCounts!.toJson()),
      ),
      errorSummary: Value(errorSummary),
    );
  }

  drift.ImportExportOperationsCompanion toUpdateCompanion() {
    return drift.ImportExportOperationsCompanion(
      id: Value(id),
      status: Value(status.name),
      finishedAt: Value(finishedAt?.toUtc().toIso8601String()),
      itemCountsJson: Value(
        itemCounts == null ? null : jsonEncode(itemCounts!.toJson()),
      ),
      errorSummary: Value(errorSummary),
    );
  }
}
