import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/export/manifest.dart';

void main() {
  test('serializes exactly the shape TS 10.2 specifies', () {
    final manifest = ExportManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      exportedAtUtc: DateTime.utc(2026, 7, 19, 14),
      workoutCount: 12,
      setCount: 340,
      measurementCount: 56,
      exerciseCount: 199,
    );

    final decoded = jsonDecode(manifest.toJsonString()) as Map<String, dynamic>;

    expect(decoded['formatVersion'], 1);
    expect(decoded['appVersion'], '1.0.0');
    expect(decoded['exportedAtUtc'], '2026-07-19T14:00:00.000Z');
    expect(decoded['files'], {
      'workouts': 'workouts.csv',
      'measurements': 'measurements.csv',
      'exercises': 'exercises.csv',
    });
    expect(decoded['counts'], {
      'workouts': 12,
      'sets': 340,
      'measurements': 56,
      'exercises': 199,
    });
  });

  test('exportedAtUtc is always converted to UTC before formatting', () {
    // A local (non-UTC) DateTime should still serialize with a "Z" suffix.
    final manifest = ExportManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      exportedAtUtc: DateTime(2026, 7, 19, 10),
      workoutCount: 0,
      setCount: 0,
      measurementCount: 0,
      exerciseCount: 0,
    );

    final decoded = jsonDecode(manifest.toJsonString()) as Map<String, dynamic>;
    expect(decoded['exportedAtUtc'], endsWith('Z'));
  });
}
