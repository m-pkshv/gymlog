import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/export/export_archive.dart';
import 'package:gymlog/services/export/manifest.dart';

void main() {
  test(
    'produces a ZIP with all 4 entries -- BOM-prefixed CSVs, plain-UTF-8 '
    'manifest -- readable back byte-for-byte',
    () {
      final manifest = ExportManifest(
        formatVersion: 1,
        appVersion: '1.0.0',
        exportedAtUtc: DateTime.utc(2026, 7, 19, 14),
        workoutCount: 1,
        setCount: 2,
        measurementCount: 3,
        exerciseCount: 4,
      );
      const workoutsCsv = 'exercise_name\r\nSquat\r\n';
      const measurementsCsv = 'date,value\r\n2026-07-01,82.4\r\n';
      const exercisesCsv = 'exercise_id,name\r\nsquat,Squat\r\n';

      final zipBytes = buildExportArchive(
        manifest: manifest,
        workoutsCsv: workoutsCsv,
        measurementsCsv: measurementsCsv,
        exercisesCsv: exercisesCsv,
      );

      final decoded = ZipDecoder().decodeBytes(zipBytes);
      expect(decoded.length, 4);

      final manifestEntry = decoded.findFile('manifest.json')!;
      expect(
        jsonDecode(utf8.decode(manifestEntry.content)),
        jsonDecode(manifest.toJsonString()),
      );
      // No BOM on manifest.json.
      expect(manifestEntry.content.sublist(0, 3), isNot([0xEF, 0xBB, 0xBF]));

      for (final MapEntry(key: name, value: expectedCsv) in {
        'workouts.csv': workoutsCsv,
        'measurements.csv': measurementsCsv,
        'exercises.csv': exercisesCsv,
      }.entries) {
        final entry = decoded.findFile(name)!;
        expect(entry.content.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
        expect(utf8.decode(entry.content.sublist(3)), expectedCsv);
      }
    },
  );
}
