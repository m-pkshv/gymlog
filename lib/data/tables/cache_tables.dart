import 'package:drift/drift.dart';

import 'exercise_tables.dart';
import 'workout_tables.dart';

/// Personal-record cache (06_DATA_MODEL.md, section 6.10, D-8). Not a
/// source of truth: fully rebuilt from history whenever a trigger listed in
/// section 6.10 fires. [keyValue] holds the weight (kg) for
/// `maxRepsAtWeight` records and is null otherwise.
@DataClassName('PersonalRecord')
class PersonalRecords extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();

  TextColumn get recordType => text().customConstraint(
    "NOT NULL CHECK (recordType IN ('maxWeight', 'maxRepsAtWeight', 'max1RM', "
    "'maxVolumeWorkout', 'maxDistance', 'bestPace', 'longestDuration'))",
  )();

  RealColumn get keyValue => real().nullable()();

  RealColumn get value => real()();

  TextColumn get workoutId => text().references(Workouts, #id)();

  TextColumn get exerciseSetId =>
      text().nullable().references(ExerciseSets, #id)();

  /// Local calendar date `YYYY-MM-DD` of the source workout.
  TextColumn get achievedAt => text()();

  TextColumn get computedAt => text()();

  @override
  Set<Column> get primaryKey => {exerciseId, recordType, keyValue};
}

/// Stagnation-counter cache for the progression algorithm (D-7)
/// (06_DATA_MODEL.md, section 6.11). Recomputed by the same triggers as
/// [PersonalRecords] (see section 6.10).
@DataClassName('ExerciseProgressionState')
class ExerciseProgressionStates extends Table {
  TextColumn get exerciseId => text().references(Exercises, #id)();

  IntColumn get stagnationCount => integer()();

  TextColumn get lastCountedWorkoutId =>
      text().nullable().references(Workouts, #id)();

  TextColumn get computedAt => text()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
