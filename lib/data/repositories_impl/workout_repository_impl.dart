import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/models/workout_exercise.dart';
import '../../domain/repositories/workout_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_mapper.dart';
import '../mappers/workout_mapper.dart';

/// Drift-backed `WorkoutRepository` for the Workout aggregate
/// (06_DATA_MODEL.md, sections 6.4, 6.6, 6.7).
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Future<Workout?> getInProgressWorkout() async {
    final row =
        await (_db.select(_db.workouts)..where(
              (w) =>
                  w.status.equals(WorkoutStatus.inProgress.name) &
                  w.isDeleted.equals(false),
            ))
            .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<WorkoutDetails?> getDetails(String workoutId) async {
    final workoutRow = await (_db.select(
      _db.workouts,
    )..where((w) => w.id.equals(workoutId))).getSingleOrNull();
    if (workoutRow == null) return null;

    final workoutExerciseRows =
        await (_db.select(_db.workoutExercises)
              ..where(
                (we) =>
                    we.workoutId.equals(workoutId) & we.isDeleted.equals(false),
              )
              ..orderBy([(we) => OrderingTerm.asc(we.orderIndex)]))
            .get();

    if (workoutExerciseRows.isEmpty) {
      return WorkoutDetails(
        workout: workoutRow.toDomain(),
        exercises: const [],
      );
    }

    final exerciseIds = workoutExerciseRows
        .map((we) => we.exerciseId)
        .toSet()
        .toList();
    final exerciseRows = await (_db.select(
      _db.exercises,
    )..where((e) => e.id.isIn(exerciseIds))).get();
    final exerciseById = {for (final row in exerciseRows) row.id: row};

    final workoutExerciseIds = workoutExerciseRows.map((we) => we.id).toList();
    final setRows =
        await (_db.select(_db.exerciseSets)
              ..where(
                (s) =>
                    s.workoutExerciseId.isIn(workoutExerciseIds) &
                    s.isDeleted.equals(false),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
            .get();
    final setsByWorkoutExercise = <String, List<drift.ExerciseSet>>{};
    for (final row in setRows) {
      setsByWorkoutExercise
          .putIfAbsent(row.workoutExerciseId, () => [])
          .add(row);
    }

    final exercises = workoutExerciseRows.map((weRow) {
      final exerciseRow = exerciseById[weRow.exerciseId]!;
      final sets =
          setsByWorkoutExercise[weRow.id] ?? const <drift.ExerciseSet>[];
      return WorkoutExerciseDetails(
        workoutExercise: weRow.toDomain(),
        exercise: exerciseRow.toDomain(),
        sets: sets.map((s) => s.toDomain()).toList(),
      );
    }).toList();

    return WorkoutDetails(workout: workoutRow.toDomain(), exercises: exercises);
  }

  @override
  Stream<List<Workout>> watchHistory() {
    final query = _db.select(_db.workouts)
      ..where(
        (w) =>
            w.status.equals(WorkoutStatus.completed.name) &
            w.isDeleted.equals(false),
      )
      ..orderBy([(w) => OrderingTerm.desc(w.date)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<Workout> createDraft({required DateTime date}) async {
    final now = DateTime.now().toUtc();
    final workout = Workout(
      id: const Uuid().v4(),
      date: date,
      status: WorkoutStatus.draft,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.workouts).insert(workout.toInsertCompanion());
    return workout;
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    await (_db.update(_db.workouts)..where((w) => w.id.equals(workout.id)))
        .write(workout.toUpdateCompanion());
  }

  @override
  Future<WorkoutExercise> addExercise({
    required String workoutId,
    required String exerciseId,
  }) async {
    final now = DateTime.now().toUtc();
    final maxOrderIndex = await _maxOrderIndex(workoutId);
    final workoutExercise = WorkoutExercise(
      id: const Uuid().v4(),
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: maxOrderIndex + 1,
      progressionDecision: ProgressionDecision.none,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db
        .into(_db.workoutExercises)
        .insert(workoutExercise.toInsertCompanion());
    return workoutExercise;
  }

  Future<int> _maxOrderIndex(String workoutId) async {
    final rows =
        await (_db.select(_db.workoutExercises)..where(
              (we) =>
                  we.workoutId.equals(workoutId) & we.isDeleted.equals(false),
            ))
            .get();
    if (rows.isEmpty) return -1;
    return rows.map((row) => row.orderIndex).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<ExerciseSet> addSet({
    required String workoutExerciseId,
    required bool isWarmup,
  }) async {
    final now = DateTime.now().toUtc();
    final nextSetNumber = await _nextSetNumber(workoutExerciseId);
    final exerciseSet = ExerciseSet(
      id: const Uuid().v4(),
      workoutExerciseId: workoutExerciseId,
      setNumber: nextSetNumber,
      isWarmup: isWarmup,
      isCompleted: false,
      side: BodySide.none,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.exerciseSets).insert(exerciseSet.toInsertCompanion());
    return exerciseSet;
  }

  Future<int> _nextSetNumber(String workoutExerciseId) async {
    final rows =
        await (_db.select(_db.exerciseSets)..where(
              (s) =>
                  s.workoutExerciseId.equals(workoutExerciseId) &
                  s.isDeleted.equals(false),
            ))
            .get();
    if (rows.isEmpty) return 1;
    return rows.map((row) => row.setNumber).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<void> updateSet(ExerciseSet set) async {
    await (_db.update(
      _db.exerciseSets,
    )..where((s) => s.id.equals(set.id))).write(set.toUpdateCompanion());
  }
}
