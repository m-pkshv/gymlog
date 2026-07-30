import 'dart:io';

import '../../core/constants.dart';
import '../../data/database.dart';
import 'backup_archive.dart';
import 'backup_file_name.dart';
import 'backup_manifest.dart';

/// Whole-database backup export/import (Stage 11) -- a manual, ZIP-wrapped
/// copy of the app's single SQLite file. Distinct from both the CSV export
/// (TS 10, human-readable, one-way, Stage 8) and the OS-level Auto Backup
/// (TS-1, automatic, opaque to the user): a third mechanism the owner
/// explicitly asked for, reusing the same underlying data.
class BackupService {
  const BackupService();

  /// Writes the finished ZIP into [outputDirectory] and returns its `File`.
  /// [db] is the app's live connection (used only to flush any WAL
  /// contents into the main file and read `PRAGMA user_version` -- it's
  /// *not* closed by this method, unlike [restoreBackup]'s precondition).
  Future<File> exportBackup({
    required AppDatabase db,
    required File databaseFile,
    required Directory outputDirectory,
  }) async {
    // A no-op if the connection isn't in WAL mode; if it is, this ensures
    // the raw bytes read below are a complete, consistent snapshot rather
    // than a partially-checkpointed one.
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final versionRow = await db.customSelect('PRAGMA user_version').getSingle();
    final schemaVersion = versionRow.data['user_version'] as int;

    final now = DateTime.now().toUtc();
    final databaseBytes = await databaseFile.readAsBytes();
    final zipBytes = buildBackupArchive(
      manifest: BackupManifest(
        formatVersion: BackupFormat.formatVersion,
        appVersion: ExportFormat.appVersion,
        schemaVersion: schemaVersion,
        createdAtUtc: now,
      ),
      databaseBytes: databaseBytes,
    );

    final file = File(
      '${outputDirectory.path}${Platform.pathSeparator}${backupZipFileName(now)}',
    );
    await file.writeAsBytes(zipBytes, flush: true);
    return file;
  }

  /// Parses [zipFile] without touching the real database -- the caller
  /// shows the result to the user (backup date, schema version) for
  /// confirmation before ever calling [restoreBackup]. Throws
  /// [FormatException] if [zipFile] isn't a well-formed backup.
  Future<BackupManifest> inspectBackup(File zipFile) async {
    final bytes = await zipFile.readAsBytes();
    return readBackupArchive(bytes).manifest;
  }

  /// Overwrites [databaseFile] with [zipFile]'s database bytes --
  /// irreversible. The caller must have already closed the live `AppDatabase`
  /// connection (the file is locked while one is open) and must tell the
  /// user to fully restart the app afterward: the in-memory connection this
  /// process was using is gone for good, by design (owner-confirmed
  /// 2026-07-30) -- there is no in-app "hot swap" of the database file.
  Future<void> restoreBackup({
    required File zipFile,
    required File databaseFile,
  }) async {
    final bytes = await zipFile.readAsBytes();
    // Re-parsed (not reusing an earlier `inspectBackup` call) so the
    // destructive write is always preceded by its own fresh validation,
    // not a possibly-stale one.
    final parsed = readBackupArchive(bytes);
    await databaseFile.writeAsBytes(parsed.databaseBytes, flush: true);
  }
}
