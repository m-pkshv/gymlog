import 'package:drift/drift.dart';

import 'workout_tables.dart';

/// Single-row active-workout state, present only while a workout is
/// `inProgress` (06_DATA_MODEL.md, section 6.14). Timers are recomputed
/// from these UTC anchors, never from an in-memory ticking counter
/// (03_TECHNICAL_SPEC.md, section 7.1) — this is what makes recovery after
/// the process is killed or the app is backgrounded trivial.
@DataClassName('ActiveWorkoutState')
class ActiveWorkoutStates extends Table {
  TextColumn get workoutId => text().references(Workouts, #id)();

  TextColumn get startedAtUtc => text()();

  IntColumn get accumulatedActiveSec =>
      integer().withDefault(const Constant(0))();

  BoolColumn get isPaused => boolean().withDefault(const Constant(false))();

  TextColumn get pauseStartedAtUtc => text().nullable()();

  TextColumn get restTimerEndsAtUtc => text().nullable()();

  IntColumn get restTimerDurationSec => integer().nullable()();

  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {workoutId};
}
