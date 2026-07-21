import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_catalog_filter.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_mapper.dart';

/// Drift-backed `ExerciseRepository` (06_DATA_MODEL.md, section 6.1).
class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<Exercise>> watchAll({
    ExerciseCatalogFilter filter = emptyExerciseCatalogFilter,
  }) {
    final query = _db.select(_db.exercises)
      ..where((e) => e.isDeleted.equals(false));
    if (!filter.includeArchived) {
      query.where((e) => e.isArchived.equals(false));
    }
    if (filter.type != null) {
      query.where((e) => e.exerciseType.equals(filter.type!.name));
    }
    if (filter.equipmentId != null) {
      query.where((e) => e.equipmentId.equals(filter.equipmentId!));
    }
    if (filter.onlyUserCreated) {
      query.where((e) => e.isBuiltIn.equals(false));
    }
    query.orderBy([(e) => OrderingTerm.desc(e.createdAt)]);

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return const <Exercise>[];
      final ids = rows.map((row) => row.id).toList();
      final secondaryByExercise = await _secondaryMuscleGroupIdsByExercise(
        ids,
      );

      var exercises = rows
          .map(
            (row) => row.toDomain(
              secondaryMuscleGroupIds: secondaryByExercise[row.id] ?? const [],
            ),
          )
          .toList();

      final muscleGroupId = filter.muscleGroupId;
      if (muscleGroupId != null) {
        exercises = exercises
            .where(
              (exercise) =>
                  exercise.primaryMuscleGroupId == muscleGroupId ||
                  exercise.secondaryMuscleGroupIds.contains(muscleGroupId),
            )
            .toList();
      }

      final normalizedQuery = filter.query.trim().toLowerCase();
      if (normalizedQuery.isNotEmpty) {
        // Matched in Dart, not SQL: sqlite3's LIKE only case-folds ASCII,
        // so a Cyrillic query wouldn't match a differently-cased localized
        // name via SQL LIKE. The catalog is small enough that filtering
        // the already-narrowed row set here is cheap and locale-correct.
        final localizedNames = await _localizedNamesByExercise(ids);
        exercises = exercises.where((exercise) {
          if (exercise.name.toLowerCase().contains(normalizedQuery)) {
            return true;
          }
          return (localizedNames[exercise.id] ?? const []).any(
            (name) => name.toLowerCase().contains(normalizedQuery),
          );
        }).toList();
      }

      return exercises;
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
  Future<Exercise> update({
    required String id,
    required String name,
    required ExerciseType exerciseType,
    String? description,
    String? youtubeUrl,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric effortMetric = EffortMetric.none,
    List<String> secondaryMuscleGroupIds = const [],
  }) async {
    await _db.transaction(() async {
      await (_db.update(
        _db.exercises,
      )..where((e) => e.id.equals(id))).write(
        drift.ExercisesCompanion(
          name: Value(name),
          exerciseType: Value(exerciseType.name),
          description: Value(description),
          youtubeUrl: Value(youtubeUrl),
          primaryMuscleGroupId: Value(primaryMuscleGroupId),
          equipmentId: Value(equipmentId),
          effortMetric: Value(effortMetric.name),
          updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
        ),
      );
      await (_db.delete(
        _db.exerciseSecondaryMuscles,
      )..where((s) => s.exerciseId.equals(id))).go();
      for (final muscleGroupId in secondaryMuscleGroupIds) {
        await _db
            .into(_db.exerciseSecondaryMuscles)
            .insert(
              drift.ExerciseSecondaryMusclesCompanion.insert(
                exerciseId: id,
                muscleGroupId: muscleGroupId,
              ),
            );
      }
    });
    return (await getById(id))!;
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

  @override
  Future<List<Exercise>> getAllForExport() async {
    final rows = await (_db.select(
      _db.exercises,
    )..where((e) => e.isDeleted.equals(false))).get();
    if (rows.isEmpty) return const [];

    final ids = rows.map((row) => row.id).toList();
    final secondaryByExercise = await _secondaryMuscleGroupIdsByExercise(ids);
    return rows
        .map(
          (row) => row.toDomain(
            secondaryMuscleGroupIds: secondaryByExercise[row.id] ?? const [],
          ),
        )
        .toList();
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

  Future<Map<String, List<String>>> _localizedNamesByExercise(
    List<String> exerciseIds,
  ) async {
    final rows = await (_db.select(
      _db.exerciseL10n,
    )..where((l) => l.exerciseId.isIn(exerciseIds))).get();
    final result = <String, List<String>>{};
    for (final row in rows) {
      result.putIfAbsent(row.exerciseId, () => []).add(row.name);
    }
    return result;
  }
}
