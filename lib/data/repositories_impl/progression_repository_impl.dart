import '../../domain/models/exercise_progression_state.dart';
import '../../domain/repositories/progression_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_progression_state_mapper.dart';

/// Drift-backed `ProgressionRepository` (06_DATA_MODEL.md, section 6.11).
class ProgressionRepositoryImpl implements ProgressionRepository {
  ProgressionRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<ExerciseProgressionState?> watchState(String exerciseId) {
    final query = _db.select(
      _db.exerciseProgressionStates,
    )..where((s) => s.exerciseId.equals(exerciseId));
    return query.watchSingleOrNull().map((row) => row?.toDomain());
  }

  @override
  Future<void> saveState(ExerciseProgressionState state) async {
    await _db
        .into(_db.exerciseProgressionStates)
        .insertOnConflictUpdate(state.toUpsertCompanion());
  }
}
