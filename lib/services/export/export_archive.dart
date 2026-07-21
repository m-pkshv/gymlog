import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'csv_bom.dart';
import 'manifest.dart';

/// Builds the complete export ZIP bytes in memory: `manifest.json` (plain
/// UTF-8) plus the three BOM-prefixed CSV files (03_TECHNICAL_SPEC.md,
/// section 10.1/10.2). Everything happens in memory so the caller only
/// ever writes one complete file to disk -- never a partial one (TS 10.1:
/// "ZIP формируется полностью и только затем передаётся в шаринг").
Uint8List buildExportArchive({
  required ExportManifest manifest,
  required String workoutsCsv,
  required String measurementsCsv,
  required String exercisesCsv,
}) {
  final archive = Archive()
    ..addFile(_utf8File('manifest.json', manifest.toJsonString()))
    ..addFile(_bomCsvFile('workouts.csv', workoutsCsv))
    ..addFile(_bomCsvFile('measurements.csv', measurementsCsv))
    ..addFile(_bomCsvFile('exercises.csv', exercisesCsv));
  return ZipEncoder().encodeBytes(archive);
}

ArchiveFile _bomCsvFile(String name, String content) {
  final bytes = utf8BytesWithBom(content);
  return ArchiveFile(name, bytes.length, bytes);
}

ArchiveFile _utf8File(String name, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(name, bytes.length, bytes);
}
