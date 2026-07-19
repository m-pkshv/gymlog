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
  }) async {
    final now = DateTime.now().toUtc();
    final exercise = Exercise(
      id: const Uuid().v4(),
      name: name,
      exerciseType: exerciseType,
      effortMetric: EffortMetric.none,
      isBuiltIn: false,
      isArchived: false,
      secondaryMuscleGroupIds: const [],
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.exercises).insert(exercise.toInsertCompanion());
    return exercise;
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
