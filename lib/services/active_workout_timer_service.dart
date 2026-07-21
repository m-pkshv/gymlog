import '../domain/models/active_workout_state.dart';
import '../domain/repositories/active_workout_repository.dart';

/// The workout timer (03_TECHNICAL_SPEC.md, section 7.1): one running clock
/// per `inProgress` workout, always derived from UTC anchors in
/// `ActiveWorkoutState`, never an in-memory tick — a manual Pause/Resume is
/// the only user control over it (distinct from the per-set rest timer,
/// Stage 4 later step). `WorkoutService` is the only caller — it owns
/// wiring this into the `Workout.status` state machine (DM 6.4.1).
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
}
