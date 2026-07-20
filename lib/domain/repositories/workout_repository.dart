import '../models/exercise_history_entry.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';
import '../models/workout_details.dart';
import '../models/workout_exercise.dart';
import '../models/workout_history_entry.dart';
import '../models/workout_history_filter.dart';

/// Storage contract for the workout aggregate — `Workout` +
/// `WorkoutExercise` + `ExerciseSet` (06_DATA_MODEL.md, sections 6.4, 6.6,
/// 6.7). Implemented in the Data layer (D-13); services/UI depend only on
/// this interface, never on `AppDatabase` directly. Status-transition
/// rules (DM 6.4.1) are enforced by `workout_service`, not here — this
/// contract only persists whatever the caller decides.
abstract class WorkoutRepository {
  /// The workout currently `inProgress`, if any (DM 6.4.1: at most one).
  Future<Workout?> getInProgressWorkout();

  Future<WorkoutDetails?> getDetails(String workoutId);

  /// Non-deleted workouts matching [filter], with their exercise count and
  /// tags, most recent date first (S-02). [WorkoutHistoryFilter.statuses]
  /// empty defaults to `completed` only (Stage 1 behavior, owner-confirmed
  /// 2026-07-21 when Stage 3 added the status multi-select); an explicit
  /// selection replaces that default rather than adding to it. Tags filter
  /// in OR mode (02_DEVELOPMENT_PLAN.md Stage 3 acceptance criteria).
  Stream<List<WorkoutHistoryEntry>> watchHistory({
    WorkoutHistoryFilter filter = emptyWorkoutHistoryFilter,
  });

  Future<Workout> createDraft({required DateTime date});

  /// Persists workout-level field changes (status, name, comment, dates).
  Future<void> updateWorkout(Workout workout);

  Future<WorkoutExercise> addExercise({
    required String workoutId,
    required String exerciseId,
  });

  /// Persists `WorkoutExercise`-level field changes — the comment autosave
  /// write (S-03, TS 5).
  Future<void> updateWorkoutExercise(WorkoutExercise workoutExercise);

  Future<ExerciseSet> addSet({
    required String workoutExerciseId,
    required bool isWarmup,
  });

  /// Persists set field changes — the autosave write (TS 5).
  Future<void> updateSet(ExerciseSet set);

  /// Past occurrences of [exerciseId] in completed, non-deleted workouts,
  /// most recent date first — the exercise card's "История" tab (S-07,
  /// Stage 2).
  Future<List<ExerciseHistoryEntry>> getExerciseHistory(String exerciseId);

  /// Replaces the full set of tags assigned to [workoutId] with [tagIds]
  /// (S-03 "теги (чипы + «+»)"): existing `WorkoutTagLink` rows for this
  /// workout are dropped and the new set inserted, in one transaction.
  Future<void> setWorkoutTags({
    required String workoutId,
    required List<String> tagIds,
  });

  /// "Скопировать прошлую" (S-02, TS 8 section 8): duplicates
  /// [sourceWorkoutId]'s exercises (order + `WorkoutExercise.comment`) and
  /// each set's planned values into a brand-new `draft` workout dated
  /// [date]. Actuals, `isCompleted`, and `progressionDecision` are never
  /// copied — the copy starts with nothing performed yet. Throws
  /// `ArgumentError` if [sourceWorkoutId] doesn't exist.
  Future<Workout> copyWorkout({
    required String sourceWorkoutId,
    required DateTime date,
  });

  /// Reorder (S-03, drag handle + "⋮ → Вверх/Вниз"): rewrites `orderIndex`
  /// so it matches each id's position in [orderedWorkoutExerciseIds] (DM
  /// 6.6: "непрерывность не требуется", so this doesn't need to preserve
  /// any particular numbering, just the relative order).
  Future<void> reorderExercises({
    required String workoutId,
    required List<String> orderedWorkoutExerciseIds,
  });

  /// Soft-deletes [workoutId] (S-02 "⋮ → Удалить", DM 10): marks the
  /// workout and every one of its non-deleted `WorkoutExercise`/
  /// `ExerciseSet` rows `isDeleted = true`, in one transaction. Callers
  /// (`workout_service`) are responsible for the DM 10 rule that an
  /// `inProgress` workout can't be deleted — this just performs the write.
  Future<void> deleteWorkout(String workoutId);

  /// Reverses [deleteWorkout] within the DM 10 5-second Undo window:
  /// un-marks `isDeleted` on the workout and the same `WorkoutExercise`/
  /// `ExerciseSet` rows it cascaded to.
  Future<void> restoreWorkout(String workoutId);
}
