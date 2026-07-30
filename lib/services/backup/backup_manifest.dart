import 'dart:convert';

/// `manifest.json` inside a full-database backup ZIP (Stage 11) -- distinct
/// from `services/export/manifest.dart`'s `ExportManifest` (the CSV
/// export): a separate format/version space that can evolve on its own
/// schedule.
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAtUtc,
  });

  final int formatVersion;
  final String appVersion;

  /// The exported database's `PRAGMA user_version` (i.e. `AppDatabase.
  /// schemaVersion` at export time) -- read from the live file, not
  /// hand-mirrored, so it can never drift out of sync the way
  /// `ExportFormat.appVersion` (necessarily) does from `pubspec.yaml`.
  final int schemaVersion;
  final DateTime createdAtUtc;

  String toJsonString() {
    final map = {
      'formatVersion': formatVersion,
      'appVersion': appVersion,
      'schemaVersion': schemaVersion,
      'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// Throws [FormatException] if [jsonString] isn't a well-formed backup
  /// manifest -- the import flow must never proceed to touch the real
  /// database file on a manifest it can't parse.
  factory BackupManifest.fromJsonString(String jsonString) {
    final Object? decoded;
    try {
      decoded = jsonDecode(jsonString);
    } on FormatException {
      throw const FormatException('manifest.json is not valid JSON');
    }
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('manifest.json is not a JSON object');
    }
    final formatVersion = decoded['formatVersion'];
    final appVersion = decoded['appVersion'];
    final schemaVersion = decoded['schemaVersion'];
    final createdAtUtc = decoded['createdAtUtc'];
    if (formatVersion is! int ||
        appVersion is! String ||
        schemaVersion is! int ||
        createdAtUtc is! String) {
      throw const FormatException(
        'manifest.json is missing one or more required fields',
      );
    }
    final DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(createdAtUtc);
    } on FormatException {
      throw const FormatException(
        'manifest.json has an invalid createdAtUtc',
      );
    }
    return BackupManifest(
      formatVersion: formatVersion,
      appVersion: appVersion,
      schemaVersion: schemaVersion,
      createdAtUtc: parsedDate,
    );
  }
}
