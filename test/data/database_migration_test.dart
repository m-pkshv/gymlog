import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/seed/seed_runner.dart';

/// Stage 10 (02_DEVELOPMENT_PLAN.md): "migration test v1 -> current version".
///
/// The schema has stayed at `schemaVersion = 1` for the entire project (no
/// step ever required a schema change - see CLAUDE.md history). A classic
/// "vN with data -> upgrade -> vN+1" migration test is therefore not
/// applicable, same reasoning already recorded for Stage 0 in
/// `test/data/database_test.dart`. The closest meaningful equivalent for a
/// release regression is: does a real on-disk database file (as produced by
/// `AppDatabase._openConnection`, not the in-memory instance every other
/// test uses) survive a full app restart - reopened by a *fresh*
/// `AppDatabase` instance - without losing user data or re-seeding
/// duplicates? All other tests in the project reuse a single in-memory
/// instance and never exercise this file-reopen path.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('gymlog_migration_test_');
    dbFile = File('${tempDir.path}/gymlog.sqlite');
  });

  tearDown(() async {
    // On Windows, the native sqlite handle can take a moment to release
    // after `close()`; retry a couple of times instead of failing the test
    // on an unrelated cleanup error.
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
    'seeded data and user data survive closing and reopening the file with a fresh instance',
    () async {
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      await SeedRunner(firstRun).run();
      await firstRun.into(firstRun.workouts).insert(
        WorkoutsCompanion.insert(
          id: 'workout-1',
          date: '2026-07-22',
          createdAt: '2026-07-22T00:00:00.000Z',
          updatedAt: '2026-07-22T00:00:00.000Z',
        ),
      );
      final exerciseCountBefore = await firstRun.select(firstRun.exercises).get();
      await firstRun.close();

      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);

      // beforeOpen ran again on the reopened file (foreign keys stay enforced).
      final fkRows = await secondRun.customSelect('PRAGMA foreign_keys').get();
      expect(fkRows.single.data['foreign_keys'], 1);

      final workouts = await secondRun.select(secondRun.workouts).get();
      expect(workouts.map((w) => w.id), contains('workout-1'));

      final exercisesAfter = await secondRun.select(secondRun.exercises).get();
      expect(exercisesAfter.length, exerciseCountBefore.length);

      // Re-running the seed against the reopened file must stay idempotent
      // (upsert, not duplicate insert - same guarantee already covered for
      // a single long-lived instance in seed_runner_test.dart, here proven
      // across an actual close/reopen of the file).
      await SeedRunner(secondRun).run();
      final exercisesAfterReseed = await secondRun.select(secondRun.exercises).get();
      expect(exercisesAfterReseed.length, exerciseCountBefore.length);
    },
  );
}
