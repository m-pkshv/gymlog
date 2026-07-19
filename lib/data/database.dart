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

/// The app's single SQLite database (D-2). Schema version 1 covers every
/// table in 06_DATA_MODEL.md, sections 5-6 at once (02_DEVELOPMENT_PLAN.md,
/// Stage 0) so Stage 0 doesn't need a second migration.
@DriftDatabase(
  tables: [
    MuscleGroups,
    Equipments,
    MeasurementTypes,
    Exercises,
    ExerciseSecondaryMuscles,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
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
