import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';

/// Stage 10: real schema migrations, exercised against a fixture shaped
/// like a v1 install upgrading directly to whatever's current -- the only
/// migration path that will ever really happen, since this app has no
/// release yet (no phone was ever on an intermediate version). Every v1
/// table is otherwise byte-identical to the current schema, so the v1
/// fixture is built by taking the current schema (`createAll`) and
/// re-adding the columns removed since v1 via raw SQL, rather than
/// hand-writing all 20 `CREATE TABLE` statements from scratch.
///
/// v1 -> v2 (2026-07-23, owner-confirmed): `ExerciseSets.isWarmup`/
/// `TemplateSets.isWarmup` dropped -- the warm-up concept was removed from
/// the app entirely.
/// v2 -> v3 (2026-07-23, owner-confirmed): `BodyMeasurements.comment`
/// dropped -- per-entry measurement comments were removed in favor of a
/// faster bulk-entry flow.
/// v3 -> v4 (2026-07-24, owner-confirmed): `ExerciseSets.comment` dropped --
/// per-set comments were removed in favor of a "delete set" action in the
/// same screen spot.
/// v4 -> v5 (2026-07-26, owner-confirmed): `WorkoutExercises.comment`/
/// `TemplateExercises.comment` dropped -- the per-exercise comment field
/// was removed entirely.
/// v5 -> v6 (2026-07-28, owner-confirmed): `WorkoutExercises.comment`/
/// `TemplateExercises.comment` added back -- the per-exercise comment field
/// turned out to still be wanted. A v1 install migrating straight through
/// to current runs both steps in sequence, so any comment text set before
/// the v5 drop is genuinely gone by the time the v6 column reappears --
/// this test asserts that explicitly, it isn't an oversight.
/// v6 -> v7 (2026-07-29, owner-confirmed): `UserProfileTable` added -- a
/// brand-new table, not a column change. Unlike the dropped-column cases
/// above (where `createAll()` already reflects the *current*, post-drop
/// schema and the fixture has to add the old column back via raw SQL), a
/// v1 fixture never had this table at all, so it's dropped right back out
/// after `createAll()` builds it, before `user_version` is forced to 1.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File dbFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'gymlog_migration_v1_current_test_',
    );
    dbFile = File('${tempDir.path}/gymlog.sqlite');
  });

  tearDown(() async {
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
    'a v1 install upgrades to the current schema, preserving data and '
    're-enabling foreign keys',
    () async {
      // Build a v1-shaped file: current schema (createAll) plus every
      // column removed since v1, with user_version forced back to 1.
      final firstRun = AppDatabase(NativeDatabase(dbFile));
      final exercise = await firstRun
          .into(firstRun.exercises)
          .insertReturning(
            ExercisesCompanion.insert(
              id: 'squat',
              name: 'Squat',
              exerciseType: ExerciseType.strength.name,
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      final workout = await firstRun
          .into(firstRun.workouts)
          .insertReturning(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-01',
              status: const Value('completed'),
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      final workoutExercise = await firstRun
          .into(firstRun.workoutExercises)
          .insertReturning(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: workout.id,
              exerciseId: exercise.id,
              orderIndex: 0,
              // Set directly through the typed API -- `createAll()` already
              // builds this column (it's back in the current schema, see
              // the v5 -> v6 note above), unlike the columns further below
              // that still need a raw `ALTER TABLE` to simulate a v1 shape.
              comment: const Value('go heavy'),
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      await firstRun
          .into(firstRun.exerciseSets)
          .insert(
            ExerciseSetsCompanion.insert(
              id: 's1',
              workoutExerciseId: workoutExercise.id,
              setNumber: 1,
              actualWeightKg: const Value(100),
              actualReps: const Value(5),
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      final massType = await firstRun
          .into(firstRun.measurementTypes)
          .insertReturning(
            MeasurementTypesCompanion.insert(
              id: 'body_weight_test',
              unitKind: MeasurementUnitKind.mass.name,
              isBuiltIn: false,
              sortOrder: 0,
            ),
          );
      await firstRun
          .into(firstRun.bodyMeasurements)
          .insert(
            BodyMeasurementsCompanion.insert(
              id: 'm1',
              measurementTypeId: massType.id,
              date: '2026-07-01',
              valueMetric: 82.5,
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      final template = await firstRun
          .into(firstRun.workoutTemplates)
          .insertReturning(
            WorkoutTemplatesCompanion.insert(
              id: 't1',
              name: 'Leg day',
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );
      await firstRun
          .into(firstRun.templateExercises)
          .insert(
            TemplateExercisesCompanion.insert(
              id: 'te1',
              templateId: template.id,
              exerciseId: exercise.id,
              orderIndex: 0,
              comment: const Value('go heavy'),
              createdAt: '2026-07-01T00:00:00.000Z',
              updatedAt: '2026-07-01T00:00:00.000Z',
            ),
          );

      await firstRun.customStatement(
        'ALTER TABLE "ExerciseSets" ADD COLUMN "isWarmup" INTEGER NOT NULL DEFAULT 0',
      );
      await firstRun.customStatement(
        'ALTER TABLE "TemplateSets" ADD COLUMN "isWarmup" INTEGER NOT NULL DEFAULT 0',
      );
      await firstRun.customStatement(
        'ALTER TABLE "BodyMeasurements" ADD COLUMN "comment" TEXT',
      );
      await firstRun.customStatement(
        'ALTER TABLE "ExerciseSets" ADD COLUMN "comment" TEXT',
      );
      await firstRun.customStatement(
        'UPDATE "ExerciseSets" SET "comment" = \'felt heavy\' WHERE "id" = \'s1\'',
      );
      // `createAll()` above already created `UserProfileTable` (it's part
      // of the *current* schema) -- drop it so the fixture genuinely
      // matches a v1 install, which never had this table.
      await firstRun.customStatement('DROP TABLE "UserProfileTable"');
      await firstRun.customStatement('PRAGMA user_version = 1');
      await firstRun.close();

      // Reopen with the current app code -- this must run onUpgrade.
      final secondRun = AppDatabase(NativeDatabase(dbFile));
      addTearDown(secondRun.close);

      final exerciseSetColumns = await secondRun
          .customSelect('PRAGMA table_info("ExerciseSets")')
          .get();
      expect(
        exerciseSetColumns.map((r) => r.data['name']),
        isNot(contains('isWarmup')),
      );
      final templateSetColumns = await secondRun
          .customSelect('PRAGMA table_info("TemplateSets")')
          .get();
      expect(
        templateSetColumns.map((r) => r.data['name']),
        isNot(contains('isWarmup')),
      );
      final bodyMeasurementColumns = await secondRun
          .customSelect('PRAGMA table_info("BodyMeasurements")')
          .get();
      expect(
        bodyMeasurementColumns.map((r) => r.data['name']),
        isNot(contains('comment')),
      );
      expect(
        exerciseSetColumns.map((r) => r.data['name']),
        isNot(contains('comment')),
      );
      // `comment` is back on both tables (v5 -> v6) -- unlike the other
      // dropped columns above, this one is expected to exist again.
      final workoutExerciseColumns = await secondRun
          .customSelect('PRAGMA table_info("WorkoutExercises")')
          .get();
      expect(
        workoutExerciseColumns.map((r) => r.data['name']),
        contains('comment'),
      );
      final templateExerciseColumns = await secondRun
          .customSelect('PRAGMA table_info("TemplateExercises")')
          .get();
      expect(
        templateExerciseColumns.map((r) => r.data['name']),
        contains('comment'),
      );

      final userProfileTables = await secondRun
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name='UserProfileTable'",
          )
          .get();
      expect(userProfileTables, hasLength(1));

      final versionRow = await secondRun
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(versionRow.data['user_version'], 7);

      final fkRows = await secondRun.customSelect('PRAGMA foreign_keys').get();
      expect(fkRows.single.data['foreign_keys'], 1);

      // The pre-migration data survived, untouched apart from the columns.
      final storedSets = await secondRun.select(secondRun.exerciseSets).get();
      expect(storedSets.single.id, 's1');
      expect(storedSets.single.actualWeightKg, 100.0);
      expect(storedSets.single.actualReps, 5);

      final storedMeasurements = await secondRun
          .select(secondRun.bodyMeasurements)
          .get();
      expect(storedMeasurements.single.id, 'm1');
      expect(storedMeasurements.single.valueMetric, 82.5);

      final storedWorkoutExercises = await secondRun
          .select(secondRun.workoutExercises)
          .get();
      expect(storedWorkoutExercises.single.id, 'we1');
      expect(storedWorkoutExercises.single.orderIndex, 0);
      // The 'go heavy' text set on `firstRun` didn't survive: the v5 drop
      // (which this v1 install passes through on the way to v6) genuinely
      // destroys it, and v6's `addColumn` only brings back an empty column,
      // not the old data -- see this file's top doc comment.
      expect(storedWorkoutExercises.single.comment, isNull);

      final storedTemplateExercises = await secondRun
          .select(secondRun.templateExercises)
          .get();
      expect(storedTemplateExercises.single.id, 'te1');
      expect(storedTemplateExercises.single.orderIndex, 0);
      expect(storedTemplateExercises.single.comment, isNull);
    },
  );
}
