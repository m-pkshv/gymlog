import '../models/active_workout_state.dart';

/// Persistence for the single active-workout timer row (06_DATA_MODEL.md,
/// section 6.14). At most one row per workout, present only while that
/// workout is `inProgress`.
abstract class ActiveWorkoutRepository {
  Future<ActiveWorkoutState?> getByWorkoutId(String workoutId);

  Stream<ActiveWorkoutState?> watch(String workoutId);

  Future<void> upsert(ActiveWorkoutState state);

  Future<void> delete(String workoutId);
}
