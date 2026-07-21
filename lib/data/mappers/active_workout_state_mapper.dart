import 'package:drift/drift.dart';

import '../../domain/models/active_workout_state.dart';
import '../database.dart' as drift;

extension ActiveWorkoutStateRowMapper on drift.ActiveWorkoutState {
  ActiveWorkoutState toDomain() {
    return ActiveWorkoutState(
      workoutId: workoutId,
      startedAtUtc: DateTime.parse(startedAtUtc),
      accumulatedActiveSec: accumulatedActiveSec,
      isPaused: isPaused,
      pauseStartedAtUtc: pauseStartedAtUtc == null
          ? null
          : DateTime.parse(pauseStartedAtUtc!),
      restTimerEndsAtUtc: restTimerEndsAtUtc == null
          ? null
          : DateTime.parse(restTimerEndsAtUtc!),
      restTimerDurationSec: restTimerDurationSec,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}

extension ActiveWorkoutStateCompanionMapper on ActiveWorkoutState {
  drift.ActiveWorkoutStatesCompanion toUpsertCompanion() {
    return drift.ActiveWorkoutStatesCompanion.insert(
      workoutId: workoutId,
      startedAtUtc: startedAtUtc.toUtc().toIso8601String(),
      accumulatedActiveSec: Value(accumulatedActiveSec),
      isPaused: Value(isPaused),
      pauseStartedAtUtc: Value(pauseStartedAtUtc?.toUtc().toIso8601String()),
      restTimerEndsAtUtc: Value(restTimerEndsAtUtc?.toUtc().toIso8601String()),
      restTimerDurationSec: Value(restTimerDurationSec),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }
}
