import '../../domain/models/active_workout_state.dart';
import '../../domain/repositories/active_workout_repository.dart';
import '../database.dart' as drift;
import '../mappers/active_workout_state_mapper.dart';

/// Drift-backed `ActiveWorkoutRepository` (06_DATA_MODEL.md, section 6.14).
class ActiveWorkoutRepositoryImpl implements ActiveWorkoutRepository {
  ActiveWorkoutRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Future<ActiveWorkoutState?> getByWorkoutId(String workoutId) async {
    final row = await (_db.select(
      _db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId))).getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Stream<ActiveWorkoutState?> watch(String workoutId) {
    final query = _db.select(
      _db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId));
    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  @override
  Future<void> upsert(ActiveWorkoutState state) async {
    await _db
        .into(_db.activeWorkoutStates)
        .insertOnConflictUpdate(state.toUpsertCompanion());
  }

  @override
  Future<void> delete(String workoutId) async {
    await (_db.delete(
      _db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId))).go();
  }
}
