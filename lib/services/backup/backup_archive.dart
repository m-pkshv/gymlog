import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'backup_manifest.dart';

const backupManifestEntryName = 'manifest.json';
const backupDatabaseEntryName = 'gymlog.sqlite';

/// Builds the complete backup ZIP bytes in memory (Stage 11) -- same
/// "assemble fully in memory, write exactly one file" discipline as
/// `services/export/export_archive.dart`'s `buildExportArchive` (TS 10.1:
/// never leave a partially-written file on disk).
Uint8List buildBackupArchive({
  required BackupManifest manifest,
  required Uint8List databaseBytes,
}) {
  final manifestBytes = utf8.encode(manifest.toJsonString());
  final archive = Archive()
    ..addFile(
      ArchiveFile(
        backupManifestEntryName,
        manifestBytes.length,
        manifestBytes,
      ),
    )
    ..addFile(
      ArchiveFile(
        backupDatabaseEntryName,
        databaseBytes.length,
        databaseBytes,
      ),
    );
  return ZipEncoder().encodeBytes(archive);
}

/// The parsed contents of a backup ZIP, read back for the import flow.
class ParsedBackupArchive {
  const ParsedBackupArchive({
    required this.manifest,
    required this.databaseBytes,
  });

  final BackupManifest manifest;
  final Uint8List databaseBytes;
}

/// Throws [FormatException] if [zipBytes] isn't a well-formed backup
/// archive (not a ZIP, missing an entry, an unreadable manifest) -- the
/// import flow must never touch the real database file on a ZIP it can't
/// fully parse first.
ParsedBackupArchive readBackupArchive(Uint8List zipBytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(zipBytes);
  } catch (error) {
    throw FormatException('Not a valid ZIP file: $error');
  }
  final manifestFile = archive.findFile(backupManifestEntryName);
  final databaseFile = archive.findFile(backupDatabaseEntryName);
  if (manifestFile == null || databaseFile == null) {
    throw const FormatException(
      'Missing manifest.json or gymlog.sqlite entry -- not an IronBook backup',
    );
  }
  final manifest = BackupManifest.fromJsonString(
    utf8.decode(manifestFile.content as List<int>),
  );
  final databaseBytes = Uint8List.fromList(
    databaseFile.content as List<int>,
  );
  return ParsedBackupArchive(manifest: manifest, databaseBytes: databaseBytes);
}
