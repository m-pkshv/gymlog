/// Single-row active-workout state, present only while a workout is
/// `inProgress` (06_DATA_MODEL.md, section 6.14). The workout timer (TS
/// 7.1) is always derived from [startedAtUtc]/[accumulatedActiveSec], never
/// an in-memory tick, so recovery after the app is backgrounded or the
/// process is killed just re-reads this row.
class ActiveWorkoutState {
  const ActiveWorkoutState({
    required this.workoutId,
    required this.startedAtUtc,
    this.accumulatedActiveSec = 0,
    this.isPaused = false,
    this.pauseStartedAtUtc,
    this.restTimerEndsAtUtc,
    this.restTimerDurationSec,
    required this.updatedAt,
  });

  final String workoutId;

  /// Anchor for the *current running segment*: reset to "now" every time
  /// the timer starts or resumes from a pause. Not the workout's original
  /// start time once it has been paused/resumed at least once.
  final DateTime startedAtUtc;

  /// Active seconds accumulated up to the last pause (or resume-from-
  /// completed baseline) — excludes time spent paused.
  final int accumulatedActiveSec;

  final bool isPaused;
  final DateTime? pauseStartedAtUtc;

  /// NULL when no rest timer is currently running (TS 7.1).
  final DateTime? restTimerEndsAtUtc;
  final int? restTimerDurationSec;

  final DateTime updatedAt;

  ActiveWorkoutState copyWith({
    DateTime? startedAtUtc,
    int? accumulatedActiveSec,
    bool? isPaused,
    Object? pauseStartedAtUtc = _unset,
    Object? restTimerEndsAtUtc = _unset,
    Object? restTimerDurationSec = _unset,
    DateTime? updatedAt,
  }) {
    return ActiveWorkoutState(
      workoutId: workoutId,
      startedAtUtc: startedAtUtc ?? this.startedAtUtc,
      accumulatedActiveSec: accumulatedActiveSec ?? this.accumulatedActiveSec,
      isPaused: isPaused ?? this.isPaused,
      pauseStartedAtUtc: pauseStartedAtUtc == _unset
          ? this.pauseStartedAtUtc
          : pauseStartedAtUtc as DateTime?,
      restTimerEndsAtUtc: restTimerEndsAtUtc == _unset
          ? this.restTimerEndsAtUtc
          : restTimerEndsAtUtc as DateTime?,
      restTimerDurationSec: restTimerDurationSec == _unset
          ? this.restTimerDurationSec
          : restTimerDurationSec as int?,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

const _unset = Object();
