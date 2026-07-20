import '../core/app_error.dart';
import '../core/result.dart';
import '../domain/enums.dart';
import '../domain/models/workout.dart';
import '../domain/models/workout_details.dart';
import '../domain/repositories/workout_repository.dart';
import 'progression_service.dart';

/// The single point of truth for workout status changes
/// (03_TECHNICAL_SPEC.md, section 8; 06_DATA_MODEL.md, section 6.4.1). No
/// other layer writes `Workout.status` directly. Also owns soft
/// delete/restore (DM 10) and, as a side effect of any of those, recomputes
/// the D-7 stagnation counter for every exercise the workout touches when a
/// DM 6.10/6.11 trigger fires (completed/resumed/deleted/restored).
class WorkoutService {
  WorkoutService(this._workoutRepository, this._progressionService);

  final WorkoutRepository _workoutRepository;
  final ProgressionService _progressionService;

  /// Allowed status transitions (DM 6.4.1). Anything not listed here is
  /// rejected. `completed -> inProgress` ("Возобновить") additionally
  /// requires the [resumeWindow] check in [changeStatus].
  static const Map<WorkoutStatus, Set<WorkoutStatus>> allowedTransitions = {
    WorkoutStatus.draft: {WorkoutStatus.planned, WorkoutStatus.inProgress},
    WorkoutStatus.planned: {
      WorkoutStatus.inProgress,
      WorkoutStatus.skipped,
      WorkoutStatus.cancelled,
      WorkoutStatus.draft,
    },
    WorkoutStatus.inProgress: {
      WorkoutStatus.completed,
      WorkoutStatus.cancelled,
    },
    WorkoutStatus.completed: {WorkoutStatus.inProgress},
    WorkoutStatus.skipped: {WorkoutStatus.planned},
    WorkoutStatus.cancelled: {WorkoutStatus.planned},
  };

  /// Window during which a completed workout may be resumed (DM 6.4.1 —
  /// ASSUMPTION pending owner confirmation, DM section 13, DM-2).
  static const Duration resumeWindow = Duration(hours: 24);

  bool isTransitionAllowed(WorkoutStatus from, WorkoutStatus to) {
    return allowedTransitions[from]?.contains(to) ?? false;
  }

  /// Changes [workout]'s status, enforcing DM 6.4.1: the transition must be
  /// on [allowedTransitions], at most one workout may be `inProgress`
  /// (invariant), and resuming a completed workout is only allowed within
  /// [resumeWindow] of `finishedAt`.
  Future<Result<Workout, AppError>> changeStatus({
    required Workout workout,
    required WorkoutStatus newStatus,
  }) async {
    if (!isTransitionAllowed(workout.status, newStatus)) {
      return Err(
        ValidationError(
          'Cannot transition workout from ${workout.status.name} to ${newStatus.name}',
        ),
      );
    }

    if (workout.status == WorkoutStatus.completed &&
        newStatus == WorkoutStatus.inProgress) {
      final finishedAt = workout.finishedAt;
      if (finishedAt == null ||
          DateTime.now().toUtc().difference(finishedAt) > resumeWindow) {
        return const Err(
          ValidationError('The resume window for this workout has passed'),
        );
      }
    }

    if (newStatus == WorkoutStatus.inProgress) {
      final existing = await _workoutRepository.getInProgressWorkout();
      if (existing != null && existing.id != workout.id) {
        return const Err(
          ValidationError('Another workout is already in progress'),
        );
      }
    }

    final now = DateTime.now().toUtc();
    var updated = workout.copyWith(status: newStatus, updatedAt: now);

    if (newStatus == WorkoutStatus.inProgress) {
      // Only set on the first "Начать"; a resume keeps the original anchor.
      updated = updated.copyWith(startedAt: workout.startedAt ?? now);
    }
    if (newStatus == WorkoutStatus.completed) {
      final startedAt = updated.startedAt;
      updated = updated.copyWith(
        finishedAt: now,
        actualDurationSec: startedAt != null
            ? now.difference(startedAt).inSeconds
            : null,
      );
    }

    await _workoutRepository.updateWorkout(updated);

    // DM 6.10/6.11 triggers: a workout finishing OR being resumed (either
    // direction of the completed <-> inProgress edge) changes which
    // occurrences count toward every exercise's history.
    if (newStatus == WorkoutStatus.completed ||
        (workout.status == WorkoutStatus.completed &&
            newStatus == WorkoutStatus.inProgress)) {
      await _recomputeWorkoutExercises(workout.id);
    }

    return Ok(updated);
  }

  /// "⋮ → Удалить" (S-02, DM 10): soft-deletes [workout] with a 5-second
  /// Undo window. Rejects an `inProgress` workout — DM 10: "Удаление
  /// inProgress запрещено (сначала отменить)".
  Future<Result<Workout, AppError>> delete(Workout workout) async {
    if (workout.status == WorkoutStatus.inProgress) {
      return const Err(
        ValidationError(
          'An in-progress workout cannot be deleted; cancel it first',
        ),
      );
    }
    // Exercise ids must be read before deleting -- getDetails excludes
    // deleted workouts, so there'd be nothing left to look up afterward.
    final exerciseIds = workout.status == WorkoutStatus.completed
        ? await _workoutExerciseIds(workout.id)
        : const <String>[];

    await _workoutRepository.deleteWorkout(workout.id);

    for (final exerciseId in exerciseIds) {
      await _progressionService.recompute(exerciseId);
    }
    return Ok(workout);
  }

  /// Reverses [delete] within the Undo window (DM 10).
  Future<void> restore(String workoutId) async {
    await _workoutRepository.restoreWorkout(workoutId);
    // Read back after restoring -- getDetails excludes deleted workouts, so
    // this only sees the exercises once the restore has taken effect.
    final details = await _workoutRepository.getDetails(workoutId);
    if (details == null || details.workout.status != WorkoutStatus.completed) {
      return;
    }
    for (final exerciseId in _distinctExerciseIds(details)) {
      await _progressionService.recompute(exerciseId);
    }
  }

  Future<void> _recomputeWorkoutExercises(String workoutId) async {
    for (final exerciseId in await _workoutExerciseIds(workoutId)) {
      await _progressionService.recompute(exerciseId);
    }
  }

  Future<List<String>> _workoutExerciseIds(String workoutId) async {
    final details = await _workoutRepository.getDetails(workoutId);
    if (details == null) return const [];
    return _distinctExerciseIds(details);
  }

  List<String> _distinctExerciseIds(WorkoutDetails details) {
    final ids = <String>{};
    for (final exerciseDetails in details.exercises) {
      ids.add(exerciseDetails.exercise.id);
    }
    return ids.toList();
  }
}
