import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_mapper.dart';

/// Drift-backed `ExerciseRepository` (06_DATA_MODEL.md, section 6.1).
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<Exercise>> watchAll() {
    final query = _db.select(_db.exercises)
      ..where((e) => e.isArchived.equals(false) & e.isDeleted.equals(false))
      ..orderBy([(e) => OrderingTerm.desc(e.createdAt)]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return const <Exercise>[];
      final secondaryByExercise = await _secondaryMuscleGroupIdsByExercise(
        rows.map((row) => row.id).toList(),
      );
      return rows
          .map(
            (row) => row.toDomain(
              secondaryMuscleGroupIds: secondaryByExercise[row.id] ?? const [],
            ),
          )
          .toList();
    });
  }

  @override
  Future<Exercise?> getById(String id) async {
    final row = await (_db.select(
      _db.exercises,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final secondaryByExercise = await _secondaryMuscleGroupIdsByExercise([id]);
    return row.toDomain(
      secondaryMuscleGroupIds: secondaryByExercise[id] ?? const [],
    );
  }

  @override
  Future<Exercise> create({
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  }) async {
    final now = DateTime.now().toUtc();
    final exercise = Exercise(
      id: const Uuid().v4(),
      name: name,
      exerciseType: exerciseType,
      description: description,
      youtubeUrl: youtubeUrl,
      primaryMuscleGroupId: primaryMuscleGroupId,
      equipmentId: equipmentId,
      effortMetric: effortMetric,
      isBuiltIn: false,
      isArchived: false,
      secondaryMuscleGroupIds: secondaryMuscleGroupIds,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.transaction(() async {
      await _db.into(_db.exercises).insert(exercise.toInsertCompanion());
      for (final muscleGroupId in secondaryMuscleGroupIds) {
        await _db
            .into(_db.exerciseSecondaryMuscles)
            .insert(
              drift.ExerciseSecondaryMusclesCompanion.insert(
                exerciseId: exercise.id,
                muscleGroupId: muscleGroupId,
              ),
            );
      }
    });
    return exercise;
  }

  @override
  Future<bool> isUsedInWorkouts(String exerciseId) async {
    final row =
        await (_db.select(_db.workoutExercises)
              ..where(
                (we) =>
                    we.exerciseId.equals(exerciseId) &
                    we.isDeleted.equals(false),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  @override
  Future<bool> hasLoggedSets(String exerciseId) async {
    final query =
        _db.select(_db.exerciseSets).join([
            innerJoin(
              _db.workoutExercises,
              _db.workoutExercises.id.equalsExp(
                _db.exerciseSets.workoutExerciseId,
              ),
            ),
          ])
          ..where(
            _db.workoutExercises.exerciseId.equals(exerciseId) &
                _db.workoutExercises.isDeleted.equals(false) &
                _db.exerciseSets.isDeleted.equals(false),
          )
          ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null;
  }

  @override
  Future<void> setArchived(String exerciseId, {required bool archived}) async {
    await (_db.update(
      _db.exercises,
    )..where((e) => e.id.equals(exerciseId))).write(
      drift.ExercisesCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  @override
  Future<void> delete(String exerciseId) async {
    await (_db.delete(
      _db.exercises,
    )..where((e) => e.id.equals(exerciseId))).go();
  }

  Future<Map<String, List<String>>> _secondaryMuscleGroupIdsByExercise(
    List<String> exerciseIds,
  ) async {
    final rows = await (_db.select(
      _db.exerciseSecondaryMuscles,
    )..where((s) => s.exerciseId.isIn(exerciseIds))).get();
    final result = <String, List<String>>{};
    for (final row in rows) {
      result.putIfAbsent(row.exerciseId, () => []).add(row.muscleGroupId);
    }
    return result;
  }
}
