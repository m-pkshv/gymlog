import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/active_workout_tables.dart';
import 'tables/cache_tables.dart';
import 'tables/exercise_tables.dart';
import 'tables/measurement_tables.dart';
import 'tables/reference_tables.dart';
import 'tables/settings_tables.dart';
import 'tables/template_tables.dart';
import 'tables/workout_tables.dart';

part 'database.g.dart';

/// The app's single SQLite database (D-2). Schema version 1 covered every
/// table in 06_DATA_MODEL.md, sections 5-6 at once (02_DEVELOPMENT_PLAN.md,
/// Stage 0). Version 2 (Stage 10, owner-confirmed 2026-07-23) drops
/// `ExerciseSets.isWarmup`/`TemplateSets.isWarmup` — the "warm-up set"
/// concept was removed from the app entirely; every set now counts toward
/// statistics, so the column would only ever read `false`. Version 3 (Stage
/// 10, owner-confirmed 2026-07-23) drops `BodyMeasurements.comment` — the
/// per-entry comment was removed in favor of a faster bulk-entry flow.
/// Version 4 (Stage 10, owner-confirmed 2026-07-24) drops
/// `ExerciseSets.comment` in favor of a "delete set" action. Version 5
/// (Stage 10 redesign, owner-confirmed 2026-07-26) drops
/// `WorkoutExercises.comment`/`TemplateExercises.comment` — the
/// per-exercise comment field was removed entirely; `Workout.comment` and
/// `WorkoutTemplate.comment` (the workout/template-level comments) are
/// untouched. Version 6 (Stage 11, owner-confirmed 2026-07-28) adds
/// `WorkoutExercises.comment`/`TemplateExercises.comment` back — the
/// per-exercise comment field turned out to still be wanted after all. Any
/// install that already passed through v5 lost its old comment data at
/// that drop; this migration only restores the empty column, not the text.
/// Version 7 (Stage 11, owner-confirmed 2026-07-29) adds `UserProfileTable`
/// (06_DATA_MODEL.md, section 6.15) -- a brand-new table, not a column
/// change; nothing existing is touched. Version 8 (Stage 11, owner-confirmed
/// 2026-07-31) drops `ImportExportOperations` entirely -- the CSV-export
/// operations journal (06_DATA_MODEL.md, former section 6.13) was removed
/// from the screen, the write path, and the table together (owner-reported:
/// no user-facing value, and CSV export already gives immediate
/// success/failure feedback via a snackbar/share sheet without needing a
/// persisted log). No migration can bring back old journal rows -- the
/// table is gone for good.
@DriftDatabase(
  tables: [
    MuscleGroups,
    Equipments,
    MeasurementTypes,
    Exercises,
    ExerciseSecondaryMuscles,
    ExerciseL10n,
    WorkoutTags,
    Workouts,
    WorkoutTagLinks,
    WorkoutExercises,
    ExerciseSets,
    WorkoutTemplates,
    TemplateExercises,
    TemplateSets,
    BodyMeasurements,
    PersonalRecords,
    ExerciseProgressionStates,
    AppSettingsTable,
    SeedInfoTable,
    ActiveWorkoutStates,
    UserProfileTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // v1 -> v2 (Stage 10, 2026-07-23): the "warm-up set" concept was
          // removed from the app; every set now counts toward statistics.
          // `dropColumn` requires sqlite 3.35+ (bundled by
          // sqlite3_flutter_libs); neither column was indexed or referenced
          // by another table/view/trigger.
          await m.dropColumn(exerciseSets, 'isWarmup');
          await m.dropColumn(templateSets, 'isWarmup');
        }
        if (from < 3) {
          // v2 -> v3 (Stage 10, 2026-07-23): per-entry measurement comments
          // removed in favor of a faster bulk-entry flow (S-14 "Замеры").
          await m.dropColumn(bodyMeasurements, 'comment');
        }
        if (from < 4) {
          // v3 -> v4 (Stage 10, 2026-07-24): per-set comments removed in
          // favor of a "delete set" action in the same screen spot (DM 10
          // already specified soft-delete + renumbering for sets; this is
          // the first time it's wired up to UI).
          await m.dropColumn(exerciseSets, 'comment');
        }
        if (from < 5) {
          // v4 -> v5 (Stage 10 redesign, 2026-07-26): the per-exercise
          // comment field was removed entirely (owner-reported) --
          // `Workout.comment`/`WorkoutTemplate.comment` are untouched.
          await m.dropColumn(workoutExercises, 'comment');
          await m.dropColumn(templateExercises, 'comment');
        }
        if (from < 6) {
          // v5 -> v6 (Stage 11, 2026-07-28): the per-exercise comment field
          // is back (owner-reported) -- a plain `addColumn`, always NULL
          // for existing rows (the v4->v5 drop above already destroyed any
          // old comment text for installs that passed through it).
          await m.addColumn(workoutExercises, workoutExercises.comment);
          await m.addColumn(templateExercises, templateExercises.comment);
        }
        if (from < 7) {
          // v6 -> v7 (Stage 11, 2026-07-29): a brand-new singleton table
          // (nickname/first/last name + avatar path), not a column change --
          // nothing existing is touched.
          await m.createTable(userProfileTable);
        }
        if (from < 8) {
          // v7 -> v8 (Stage 11, 2026-07-31): the CSV-export operations
          // journal was removed entirely (owner-reported: no user-facing
          // value). `deleteTable` takes a plain string, not a `TableInfo`,
          // precisely because the Dart table class is gone by this point.
          await m.deleteTable('ImportExportOperations');
        }
      },
      beforeOpen: (details) async {
        // Foreign keys are off by default in SQLite; DM 3 requires them on
        // (needed for ExerciseSecondaryMuscles' cascade delete, among others).
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final file = await resolveDatabaseFile();
      return NativeDatabase.createInBackground(file);
    });
  }
}

/// The on-disk path of the app's single SQLite file -- the same
/// computation [AppDatabase._openConnection] uses, exposed so the backup
/// feature (Stage 11) can locate the real file without duplicating this
/// logic or opening a second connection to it.
Future<File> resolveDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/gymlog.sqlite');
}
