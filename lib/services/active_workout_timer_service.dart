import '../domain/models/active_workout_state.dart';
import '../domain/repositories/active_workout_repository.dart';

/// The workout timer and the rest timer (03_TECHNICAL_SPEC.md, section 7):
/// both are anchor-based clocks stored on `ActiveWorkoutState`, never an
/// in-memory tick. The *workout* timer is one running clock per
/// `inProgress` workout, with a manual Pause/Resume — `WorkoutService` is
/// the only caller of [start]/[resumeCompleted]/[finish], which it wires
/// into the `Workout.status` state machine (DM 6.4.1). The *rest* timer
/// (TS 7.2 step 2) is a separate, independent countdown between sets —
/// started (if `AppSettings.restTimerAutoStart`) when a set is marked done,
/// adjustable by ±15s, skippable — called directly from the workout editor
/// controller, not through `WorkoutService`.
class ActiveWorkoutTimerService {
  ActiveWorkoutTimerService(this._repository);

  final ActiveWorkoutRepository _repository;

  /// Starts a fresh timer for [workoutId] (draft/planned -> inProgress,
  /// TS 7.2 step 1).
  Future<void> start(String workoutId) async {
    final now = DateTime.now().toUtc();
    await _repository.upsert(
      ActiveWorkoutState(workoutId: workoutId, startedAtUtc: now, updatedAt: now),
    );
  }

  /// Resumes a previously completed workout within DM 6.4.1's 24h window.
  /// [priorDurationSec] (the workout's existing `actualDurationSec`) seeds
  /// `accumulatedActiveSec` so the next Finish adds to it instead of
  /// replacing it (owner-confirmed 2026-07-21: time already logged for this
  /// workout is not discarded).
  Future<void> resumeCompleted(
    String workoutId, {
    required int priorDurationSec,
  }) async {
    final now = DateTime.now().toUtc();
    await _repository.upsert(
      ActiveWorkoutState(
        workoutId: workoutId,
        startedAtUtc: now,
        accumulatedActiveSec: priorDurationSec,
        updatedAt: now,
      ),
    );
  }

  /// Freezes the running segment into `accumulatedActiveSec` and marks the
  /// timer paused; a no-op if there is no active state or it's already
  /// paused.
  Future<void> pause(String workoutId) async {
    final state = await _repository.getByWorkoutId(workoutId);
    if (state == null || state.isPaused) return;
    final now = DateTime.now().toUtc();
    await _repository.upsert(
      state.copyWith(
        accumulatedActiveSec:
            state.accumulatedActiveSec + now.difference(state.startedAtUtc).inSeconds,
        isPaused: true,
        pauseStartedAtUtc: now,
        updatedAt: now,
      ),
    );
  }

  /// Resets the running-segment anchor to now and clears the paused flag; a
  /// no-op if there is no active state or it isn't paused.
  Future<void> resume(String workoutId) async {
    final state = await _repository.getByWorkoutId(workoutId);
    if (state == null || !state.isPaused) return;
    final now = DateTime.now().toUtc();
    await _repository.upsert(
      state.copyWith(
        startedAtUtc: now,
        isPaused: false,
        pauseStartedAtUtc: null,
        updatedAt: now,
      ),
    );
  }

  /// The TS 7.1 elapsed-time formula: `accumulatedActiveSec + (isPaused ? 0
  /// : now - startedAtUtc)`. Safe to call at any moment, including right
  /// after a process restart, since it never depends on an in-memory tick.
  int elapsedSeconds(ActiveWorkoutState state, {DateTime? now}) {
    final n = now ?? DateTime.now().toUtc();
    return state.accumulatedActiveSec +
        (state.isPaused ? 0 : n.difference(state.startedAtUtc).inSeconds);
  }

  /// Removes the row (present only while `inProgress`, DM 6.14) and returns
  /// the final elapsed seconds for the caller to store as
  /// `actualDurationSec` — called when leaving `inProgress` in either
  /// direction (completed/cancelled).
  Future<int> finish(String workoutId) async {
    final state = await _repository.getByWorkoutId(workoutId);
    final elapsed = state == null ? 0 : elapsedSeconds(state);
    await _repository.delete(workoutId);
    return elapsed;
  }

  /// Starts (or replaces) the rest timer for [workoutId] with a fresh
  /// [durationSec] countdown (TS 7.2 step 2 — marking a set done, if
  /// `AppSettings.restTimerAutoStart`). A no-op if there's no active
  /// workout timer (the rest timer only makes sense while `inProgress`).
  Future<void> startRestTimer(String workoutId, {required int durationSec}) async {
    final state = await _repository.getByWorkoutId(workoutId);
    if (state == null) return;
    final now = DateTime.now().toUtc();
    await _repository.upsert(
      state.copyWith(
        restTimerEndsAtUtc: now.add(Duration(seconds: durationSec)),
        restTimerDurationSec: durationSec,
        updatedAt: now,
      ),
    );
  }

  /// Adjusts the running rest timer's remaining time by [deltaSec] (S-04:
  /// "±15 с") — positive extends, negative shortens. A no-op if no rest
  /// timer is currently running.
  Future<void> adjustRestTimer(String workoutId, {required int deltaSec}) async {
    final state = await _repository.getByWorkoutId(workoutId);
    final endsAt = state?.restTimerEndsAtUtc;
    if (state == null || endsAt == null) return;
    final newEndsAt = endsAt.add(Duration(seconds: deltaSec));
    await _repository.upsert(
      state.copyWith(
        restTimerEndsAtUtc: newEndsAt,
        restTimerDurationSec:
            (state.restTimerDurationSec ?? 0) + deltaSec,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Cancels the rest timer early (S-04: "пропустить"). A no-op if none is
  /// running.
  Future<void> skipRestTimer(String workoutId) async {
    final state = await _repository.getByWorkoutId(workoutId);
    if (state == null || state.restTimerEndsAtUtc == null) return;
    await _repository.upsert(
      state.copyWith(
        restTimerEndsAtUtc: null,
        restTimerDurationSec: null,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// The TS 7.1 rest-timer formula: `endsAt - now`. `null` when no rest
  /// timer is running; negative once it has expired (the caller decides
  /// how to display that — this step doesn't fire a notification, TS 7.3).
  int? remainingRestSeconds(ActiveWorkoutState state, {DateTime? now}) {
    final endsAt = state.restTimerEndsAtUtc;
    if (endsAt == null) return null;
    final n = now ?? DateTime.now().toUtc();
    return endsAt.difference(n).inSeconds;
  }
}
