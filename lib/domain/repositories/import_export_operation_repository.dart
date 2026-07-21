import '../models/import_export_operation.dart';

/// Storage contract for the export/import journal (06_DATA_MODEL.md,
/// section 6.13, D-9) — S-16's operations list. Implemented in the Data
/// layer (D-13); the export service depends only on this interface.
abstract class ImportExportOperationRepository {
  /// The journal, newest first (S-16). Only the last 50 rows ever exist —
  /// [startExport] prunes older ones.
  Stream<List<ImportExportOperation>> watchAll();

  /// Journals the start of a new export (TS 10.1: "операция журналируется"),
  /// in `inProgress`. Prunes the journal down to the 50 most recent rows
  /// afterward (06_DATA_MODEL.md, section 6.13).
  Future<ImportExportOperation> startExport({required int formatVersion});

  /// Marks [operationId] `success` with the final item counts (TS 10.2's
  /// `manifest.json` `counts`).
  Future<void> markSuccess({
    required String operationId,
    required ImportExportOperationCounts counts,
  });

  /// Marks [operationId] `failed` with a short error summary. No partial
  /// file ever reaches the user for a failed operation (TS 10.1) -- this
  /// just records that the attempt didn't finish.
  Future<void> markFailed({
    required String operationId,
    required String errorSummary,
  });
}
