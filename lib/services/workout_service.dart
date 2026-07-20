import '../core/app_error.dart';
import '../core/result.dart';
import '../domain/enums.dart';
import '../domain/models/workout.dart';
import '../domain/repositories/workout_repository.dart';

/// The single point of truth for workout status changes
/// (03_TECHNICAL_SPEC.md, section 8; 06_DATA_MODEL.md, section 6.4.1). No
/// other layer writes `Workout.status` directly.
class WorkoutService {
  WorkoutService(this._workoutRepository);

  final WorkoutRepository _workoutRepository;

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
    await _workoutRepository.deleteWorkout(workout.id);
    return Ok(workout);
  }
}
