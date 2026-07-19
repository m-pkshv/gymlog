import '../models/exercise_set.dart';
import '../models/workout.dart';
import '../models/workout_details.dart';
import '../models/workout_exercise.dart';

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

  /// Completed, non-deleted workouts, most recent date first (S-02,
  /// Stage 1 scope — no filters yet, those arrive in Stage 3).
  Stream<List<Workout>> watchHistory();

  Future<Workout> createDraft({required DateTime date});

  /// Persists workout-level field changes (status, name, comment, dates).
  Future<void> updateWorkout(Workout workout);

  Future<WorkoutExercise> addExercise({
    required String workoutId,
    required String exerciseId,
  });

  Future<ExerciseSet> addSet({
    required String workoutExerciseId,
    required bool isWarmup,
  });

  /// Persists set field changes — the autosave write (TS 5).
  Future<void> updateSet(ExerciseSet set);
}
