import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/services/backup/backup_service.dart';

void main() {
  late Directory tempDir;
  late File dbFile;
  late AppDatabase db;
  const service = BackupService();

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gymlog_backup_test_');
    dbFile = File('${tempDir.path}${Platform.pathSeparator}gymlog.sqlite');
    db = AppDatabase(NativeDatabase(dbFile));
    // Force the (lazily-created) file to actually exist on disk before any
    // test reads it directly.
    await db.customSelect('SELECT 1').getSingleOrNull();
  });

  tearDown(() async {
    // One test below closes `db` itself mid-test (to simulate the real
    // restore flow); closing an already-closed connection again here is
    // harmless cleanup, not a real error to surface.
    try {
      await db.close();
    } catch (_) {
      // Already closed.
    }
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
        return;
      } on FileSystemException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  });

  test(
    'exportBackup writes a ZIP whose manifest reflects the real schema '
    'version',
    () async {
      final outputDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}out',
      )..createSync();

      final zipFile = await service.exportBackup(
        db: db,
        databaseFile: dbFile,
        outputDirectory: outputDir,
      );

      expect(await zipFile.exists(), isTrue);
      final manifest = await service.inspectBackup(zipFile);
      expect(manifest.schemaVersion, db.schemaVersion);
      expect(manifest.formatVersion, BackupFormat.formatVersion);
      expect(manifest.appVersion, ExportFormat.appVersion);
    },
  );

  test(
    'restoreBackup overwrites the database file with the backup\'s data, '
    'discarding anything written afterward',
    () async {
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'squat',
              name: 'Squat',
              exerciseType: ExerciseType.strength.name,
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      final outputDir = Directory(
        '${tempDir.path}${Platform.pathSeparator}out',
      )..createSync();
      final zipFile = await service.exportBackup(
        db: db,
        databaseFile: dbFile,
        outputDirectory: outputDir,
      );

      // Diverge from the backup *after* it was taken.
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'bench',
              name: 'Bench Press',
              exerciseType: ExerciseType.strength.name,
              createdAt: '2026-07-02T00:00:00.000Z',
              updatedAt: '2026-07-02T00:00:00.000Z',
            ),
          );
      await db.close();

      await service.restoreBackup(zipFile: zipFile, databaseFile: dbFile);

      final reopened = AppDatabase(NativeDatabase(dbFile));
      addTearDown(reopened.close);
      final exercises = await reopened.select(reopened.exercises).get();
      expect(exercises.map((e) => e.id), ['squat']);
    },
  );

  test('inspectBackup rejects a file that is not a valid backup', () async {
    final garbageFile = File(
      '${tempDir.path}${Platform.pathSeparator}not_a_backup.zip',
    );
    await garbageFile.writeAsBytes([1, 2, 3, 4]);

    expect(
      () => service.inspectBackup(garbageFile),
      throwsFormatException,
    );
  });

  test('restoreBackup rejects a file that is not a valid backup and does '
      'not touch the database file', () async {
    final garbageFile = File(
      '${tempDir.path}${Platform.pathSeparator}not_a_backup.zip',
    );
    await garbageFile.writeAsBytes([1, 2, 3, 4]);
    final before = await dbFile.readAsBytes();

    await expectLater(
      service.restoreBackup(zipFile: garbageFile, databaseFile: dbFile),
      throwsFormatException,
    );

    expect(await dbFile.readAsBytes(), before);
  });
}
