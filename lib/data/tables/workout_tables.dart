import 'package:drift/drift.dart';

import 'common.dart';
import 'exercise_tables.dart';

/// Workout tag (06_DATA_MODEL.md, section 6.3). Hiding a tag
/// ([isHidden]) only affects UI; data and links are preserved.
@DataClassName('WorkoutTag')
class WorkoutTags extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  /// 1-30 chars, unique among non-deleted tags case-insensitively
  /// (validated in the service layer).
  TextColumn get name => text()();

  TextColumn get colorHex => text().withDefault(const Constant('#4C7BD9'))();

  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// A workout event (06_DATA_MODEL.md, section 6.4). Status transitions are
/// enforced by `workout_service`, not by a DB trigger (section 6.4.1).
/// Indexes per 06_DATA_MODEL.md, section 8.
@DataClassName('Workout')
@TableIndex(name: 'workoutsDateIdx', columns: {#date})
@TableIndex(name: 'workoutsStatusIdx', columns: {#status})
@TableIndex(name: 'workoutsIsDeletedIdx', columns: {#isDeleted})
class Workouts extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  /// Local calendar date `YYYY-MM-DD` (not a UTC timestamp).
  TextColumn get date => text()();

  TextColumn get name => text().nullable()();

  TextColumn get status => text()
      .customConstraint(
        "NOT NULL DEFAULT 'draft' CHECK (status IN "
        "('draft', 'planned', 'inProgress', 'completed', 'skipped', 'cancelled'))",
      )
      .withDefault(const Constant('draft'))();

  TextColumn get comment => text().nullable()();

  TextColumn get startedAt => text().nullable()();

  TextColumn get finishedAt => text().nullable()();

  IntColumn get actualDurationSec => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Workout <-> tag link (M:N) (06_DATA_MODEL.md, section 6.5).
@TableIndex(name: 'workoutTagLinksTagIdIdx', columns: {#tagId})
class WorkoutTagLinks extends Table {
  TextColumn get workoutId => text().references(Workouts, #id)();

  TextColumn get tagId => text().references(WorkoutTags, #id)();

  @override
  Set<Column> get primaryKey => {workoutId, tagId};
}

/// An exercise entry within a workout (06_DATA_MODEL.md, section 6.6). The
/// same exercise may appear more than once (supersets).
@DataClassName('WorkoutExercise')
@TableIndex(name: 'workoutExercisesWorkoutIdIdx', columns: {#workoutId})
@TableIndex(name: 'workoutExercisesExerciseIdIdx', columns: {#exerciseId})
class WorkoutExercises extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get workoutId => text().references(Workouts, #id)();

  TextColumn get exerciseId => text().references(Exercises, #id)();

  IntColumn get orderIndex => integer()();

  TextColumn get comment => text().nullable()();

  TextColumn get progressionDecision => text()
      .customConstraint(
        "NOT NULL DEFAULT 'none' CHECK (progressionDecision IN "
        "('none', 'increase', 'repeat', 'decrease'))",
      )
      .withDefault(const Constant('none'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// One set within a workout exercise (06_DATA_MODEL.md, section 6.7). A
/// single nullable-columns table covers all 5 exercise types (D-14); the
/// app only shows/validates the columns relevant to the exercise's type.
@DataClassName('ExerciseSet')
@TableIndex(
  name: 'exerciseSetsWorkoutExerciseIdIdx',
  columns: {#workoutExerciseId},
)
class ExerciseSets extends Table with SoftDeleteColumns {
  TextColumn get id => text()();

  TextColumn get workoutExerciseId =>
      text().references(WorkoutExercises, #id)();

  IntColumn get setNumber => integer()();

  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  RealColumn get plannedWeightKg => real().nullable()();

  IntColumn get plannedReps => integer().nullable()();

  RealColumn get actualWeightKg => real().nullable()();

  IntColumn get actualReps => integer().nullable()();

  RealColumn get rpe => real().nullable()();

  IntColumn get rir => integer().nullable()();

  IntColumn get plannedDurationSec => integer().nullable()();

  IntColumn get actualDurationSec => integer().nullable()();

  RealColumn get plannedDistanceM => real().nullable()();

  RealColumn get actualDistanceM => real().nullable()();

  RealColumn get resistance => real().nullable()();

  RealColumn get inclinePercent => real().nullable()();

  IntColumn get avgHeartRate => integer().nullable()();

  TextColumn get side => text()
      .customConstraint(
        "NOT NULL DEFAULT 'none' CHECK (side IN ('none', 'left', 'right', 'both'))",
      )
      .withDefault(const Constant('none'))();

  TextColumn get comment => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
