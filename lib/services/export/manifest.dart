import 'dart:convert';

/// `manifest.json` (03_TECHNICAL_SPEC.md, section 10.2) -- the export
/// format's version marker, file index, and row counts. Plain UTF-8, no
/// BOM (see `csv_bom.dart`'s doc comment for why).
class ExportManifest {
  const ExportManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.exportedAtUtc,
    required this.workoutCount,
    required this.setCount,
    required this.measurementCount,
    required this.exerciseCount,
  });

  final int formatVersion;
  final String appVersion;
  final DateTime exportedAtUtc;
  final int workoutCount;
  final int setCount;
  final int measurementCount;
  final int exerciseCount;

  String toJsonString() {
    final map = {
      'formatVersion': formatVersion,
      'appVersion': appVersion,
      'exportedAtUtc': exportedAtUtc.toUtc().toIso8601String(),
      'files': {
        'workouts': 'workouts.csv',
        'measurements': 'measurements.csv',
        'exercises': 'exercises.csv',
      },
      'counts': {
        'workouts': workoutCount,
        'sets': setCount,
        'measurements': measurementCount,
        'exercises': exerciseCount,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
