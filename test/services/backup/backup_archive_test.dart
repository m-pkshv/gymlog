import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/backup/backup_archive.dart';
import 'package:gymlog/services/backup/backup_manifest.dart';

void main() {
  test('builds a ZIP readable back byte-for-byte', () {
    final manifest = BackupManifest(
      formatVersion: 1,
      appVersion: '1.0.0',
      schemaVersion: 7,
      createdAtUtc: DateTime.utc(2026, 7, 30, 14),
    );
    final databaseBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

    final zipBytes = buildBackupArchive(
      manifest: manifest,
      databaseBytes: databaseBytes,
    );
    final parsed = readBackupArchive(zipBytes);

    expect(parsed.manifest.formatVersion, 1);
    expect(parsed.manifest.appVersion, '1.0.0');
    expect(parsed.manifest.schemaVersion, 7);
    expect(parsed.manifest.createdAtUtc, DateTime.utc(2026, 7, 30, 14));
    expect(parsed.databaseBytes, databaseBytes);
  });

  test('readBackupArchive rejects bytes that are not a ZIP at all', () {
    expect(
      () => readBackupArchive(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });

  test('readBackupArchive rejects a ZIP missing the database entry', () {
    // Built directly with the `archive` package, not `buildBackupArchive`,
    // so this genuinely exercises "well-formed ZIP, wrong contents" rather
    // than anything the function under test itself produced.
    final manifestBytes = utf8.encode(
      BackupManifest(
        formatVersion: 1,
        appVersion: '1.0.0',
        schemaVersion: 7,
        createdAtUtc: DateTime.utc(2026, 7, 30),
      ).toJsonString(),
    );
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          backupManifestEntryName,
          manifestBytes.length,
          manifestBytes,
        ),
      );
    final zipBytes = ZipEncoder().encodeBytes(archive);

    expect(
      () => readBackupArchive(Uint8List.fromList(zipBytes)),
      throwsFormatException,
    );
  });

  test('readBackupArchive rejects a ZIP missing the manifest entry', () {
    final content = Uint8List.fromList([1, 2, 3]);
    final archive = Archive()
      ..addFile(ArchiveFile(backupDatabaseEntryName, content.length, content));
    final zipBytes = ZipEncoder().encodeBytes(archive);

    expect(
      () => readBackupArchive(Uint8List.fromList(zipBytes)),
      throwsFormatException,
    );
  });
}
