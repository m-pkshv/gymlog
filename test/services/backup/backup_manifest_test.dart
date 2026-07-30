import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/backup/backup_manifest.dart';

void main() {
  test('serializes the expected shape', () {
    final manifest = BackupManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      schemaVersion: 7,
      createdAtUtc: DateTime.utc(2026, 7, 30, 14),
    );

    final decoded =
        jsonDecode(manifest.toJsonString()) as Map<String, dynamic>;

    expect(decoded['formatVersion'], 1);
    expect(decoded['appVersion'], '1.0.0');
    expect(decoded['schemaVersion'], 7);
    expect(decoded['createdAtUtc'], '2026-07-30T14:00:00.000Z');
  });

  test('createdAtUtc is always converted to UTC before formatting', () {
    final manifest = BackupManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      schemaVersion: 7,
      createdAtUtc: DateTime(2026, 7, 30, 10),
    );

    final decoded =
        jsonDecode(manifest.toJsonString()) as Map<String, dynamic>;
    expect(decoded['createdAtUtc'], endsWith('Z'));
  });

  test('round-trips through fromJsonString', () {
    final manifest = BackupManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      schemaVersion: 7,
      createdAtUtc: DateTime.utc(2026, 7, 30, 14),
    );

    final parsed = BackupManifest.fromJsonString(manifest.toJsonString());

    expect(parsed.formatVersion, 1);
    expect(parsed.appVersion, '1.0.0');
    expect(parsed.schemaVersion, 7);
    expect(parsed.createdAtUtc, DateTime.utc(2026, 7, 30, 14));
  });

  test('fromJsonString rejects invalid JSON', () {
    expect(
      () => BackupManifest.fromJsonString('not json'),
      throwsFormatException,
    );
  });

  test('fromJsonString rejects a JSON value that is not an object', () {
    expect(
      () => BackupManifest.fromJsonString('[1, 2, 3]'),
      throwsFormatException,
    );
  });

  test('fromJsonString rejects a manifest missing required fields', () {
    expect(
      () => BackupManifest.fromJsonString('{"formatVersion": 1}'),
      throwsFormatException,
    );
  });

  test('fromJsonString rejects an invalid createdAtUtc', () {
    expect(
      () => BackupManifest.fromJsonString(
        '{"formatVersion":1,"appVersion":"1.0.0","schemaVersion":7,'
        '"createdAtUtc":"not-a-date"}',
      ),
      throwsFormatException,
    );
  });
}
