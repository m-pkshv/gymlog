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
    ImportExportOperations,
    SeedInfoTable,
    ActiveWorkoutStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/gymlog.sqlite');
      return NativeDatabase.createInBackground(file);
    });
  }
}
