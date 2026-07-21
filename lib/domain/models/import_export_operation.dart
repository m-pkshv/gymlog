import '../enums.dart';

/// Item counts recorded on a finished operation (06_DATA_MODEL.md, section
/// 6.13; matches `manifest.json`'s `counts` object, 03_TECHNICAL_SPEC.md
/// section 10.2 exactly) — stored as JSON in `itemCountsJson`.
class ImportExportOperationCounts {
  const ImportExportOperationCounts({
    required this.workouts,
    required this.sets,
    required this.measurements,
    required this.exercises,
  });

  final int workouts;
  final int sets;
  final int measurements;
  final int exercises;

  Map<String, int> toJson() => {
    'workouts': workouts,
    'sets': sets,
    'measurements': measurements,
    'exercises': exercises,
  };

  factory ImportExportOperationCounts.fromJson(Map<String, dynamic> json) {
    return ImportExportOperationCounts(
      workouts: json['workouts'] as int,
      sets: json['sets'] as int,
      measurements: json['measurements'] as int,
      exercises: json['exercises'] as int,
    );
  }
}

/// One row of the export/import journal (06_DATA_MODEL.md, section 6.13,
/// D-9) — S-16's operations list. Not a source of truth for anything else;
/// purely a user-facing log of what was exported and when. Only the last 50
/// rows are kept (older ones are physically deleted by the repository).
class ImportExportOperation {
  const ImportExportOperation({
    required this.id,
    required this.operationType,
    required this.status,
    required this.formatVersion,
    required this.startedAt,
    this.finishedAt,
    this.itemCounts,
    this.errorSummary,
  });

  final String id;
  final ImportExportOperationType operationType;
  final ImportExportOperationStatus status;
  final int formatVersion;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final ImportExportOperationCounts? itemCounts;
  final String? errorSummary;
}
