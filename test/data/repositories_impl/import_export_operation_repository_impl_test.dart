import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart' hide ImportExportOperation;
import 'package:gymlog/data/repositories_impl/import_export_operation_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/import_export_operation.dart';

void main() {
  late AppDatabase db;
  late ImportExportOperationRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ImportExportOperationRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('startExport journals a new inProgress export operation', () async {
    final operation = await repository.startExport(formatVersion: 1);

    expect(operation.operationType, ImportExportOperationType.export);
    expect(operation.status, ImportExportOperationStatus.inProgress);
    expect(operation.formatVersion, 1);
    expect(operation.finishedAt, isNull);
    expect(operation.itemCounts, isNull);

    final journal = await repository.watchAll().first;
    expect(journal.single.id, operation.id);
  });

  test('watchAll lists newest first', () async {
    final older = await repository.startExport(formatVersion: 1);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final newer = await repository.startExport(formatVersion: 1);

    final journal = await repository.watchAll().first;
    expect(journal.map((o) => o.id), [newer.id, older.id]);
  });

  test('markSuccess sets status/finishedAt and round-trips the item counts', () async {
    final operation = await repository.startExport(formatVersion: 1);

    await repository.markSuccess(
      operationId: operation.id,
      counts: const ImportExportOperationCounts(
        workouts: 12,
        sets: 340,
        measurements: 56,
        exercises: 199,
      ),
    );

    final journal = await repository.watchAll().first;
    final updated = journal.single;
    expect(updated.status, ImportExportOperationStatus.success);
    expect(updated.finishedAt, isNotNull);
    expect(updated.itemCounts, isNotNull);
    expect(updated.itemCounts!.workouts, 12);
    expect(updated.itemCounts!.sets, 340);
    expect(updated.itemCounts!.measurements, 56);
    expect(updated.itemCounts!.exercises, 199);
  });

  test('markFailed sets status/finishedAt/errorSummary, no item counts', () async {
    final operation = await repository.startExport(formatVersion: 1);

    await repository.markFailed(
      operationId: operation.id,
      errorSummary: 'Disk full',
    );

    final journal = await repository.watchAll().first;
    final updated = journal.single;
    expect(updated.status, ImportExportOperationStatus.failed);
    expect(updated.finishedAt, isNotNull);
    expect(updated.errorSummary, 'Disk full');
    expect(updated.itemCounts, isNull);
  });

  test(
    'only the 50 most recent rows are kept (06_DATA_MODEL.md section 6.13)',
    () async {
      // 50 old rows, deterministically ordered by second (00..49) so
      // pruning behavior doesn't depend on system clock precision.
      for (var i = 0; i < 50; i++) {
        await db
            .into(db.importExportOperations)
            .insert(
              ImportExportOperationsCompanion.insert(
                id: 'old-$i',
                status: 'success',
                formatVersion: 1,
                startedAt:
                    '2020-01-01T00:00:${i.toString().padLeft(2, '0')}.000Z',
              ),
            );
      }

      // The 51st row -- newer than all the seeded ones -- pushes the total
      // to 51, so exactly the single oldest row ("old-0") must be pruned.
      final newest = await repository.startExport(formatVersion: 1);

      final journal = await repository.watchAll().first;
      expect(journal, hasLength(50));
      expect(journal.map((o) => o.id), isNot(contains('old-0')));
      expect(journal.map((o) => o.id), contains('old-1'));
      expect(journal.map((o) => o.id), contains('old-49'));
      expect(journal.first.id, newest.id); // newest first
    },
  );
}
