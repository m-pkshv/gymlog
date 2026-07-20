import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise_history_entry.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/models/workout_exercise.dart';
import '../../domain/models/workout_history_entry.dart';
import '../../domain/models/workout_history_filter.dart';
import '../../domain/models/workout_tag.dart';
import '../../domain/repositories/workout_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_mapper.dart';
import '../mappers/workout_mapper.dart';
import '../mappers/workout_tag_mapper.dart';

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

    final tags = await _tagsForWorkout(workoutId);

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
        tags: tags,
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

    return WorkoutDetails(
      workout: workoutRow.toDomain(),
      exercises: exercises,
      tags: tags,
    );
  }

  Future<List<WorkoutTag>> _tagsForWorkout(String workoutId) async {
    final byWorkout = await _tagsByWorkouts([workoutId]);
    return byWorkout[workoutId] ?? const [];
  }

  /// Batched version of [_tagsForWorkout] — one query for [watchHistory]'s
  /// whole result page instead of one query per row.
  Future<Map<String, List<WorkoutTag>>> _tagsByWorkouts(
    List<String> workoutIds,
  ) async {
    if (workoutIds.isEmpty) return const {};
    final query = _db.select(_db.workoutTagLinks).join([
      innerJoin(
        _db.workoutTags,
        _db.workoutTags.id.equalsExp(_db.workoutTagLinks.tagId),
      ),
    ])..where(
      _db.workoutTagLinks.workoutId.isIn(workoutIds) &
          _db.workoutTags.isDeleted.equals(false),
    );
    final rows = await query.get();
    final result = <String, List<WorkoutTag>>{};
    for (final row in rows) {
      final workoutId = row.readTable(_db.workoutTagLinks).workoutId;
      final tag = row.readTable(_db.workoutTags).toDomain();
      result.putIfAbsent(workoutId, () => []).add(tag);
    }
    return result;
  }

  @override
  Stream<List<WorkoutHistoryEntry>> watchHistory({
    WorkoutHistoryFilter filter = emptyWorkoutHistoryFilter,
  }) {
    // `exerciseCount` per workout is a SQL aggregate (TS 11.6: aggregate in
    // the query, not by fetching every WorkoutExercise into Dart).
    final exerciseCount = _db.workoutExercises.id.count();
    // Empty statuses defaults to "completed only" (Stage 1 behavior,
    // owner-confirmed 2026-07-21) rather than "any status".
    final statuses = filter.statuses.isEmpty
        ? const {WorkoutStatus.completed}
        : filter.statuses;

    final query =
        _db.select(_db.workouts).join([
            leftOuterJoin(
              _db.workoutExercises,
              _db.workoutExercises.workoutId.equalsExp(_db.workouts.id) &
                  _db.workoutExercises.isDeleted.equals(false),
            ),
          ])
          ..addColumns([exerciseCount])
          ..where(
            _db.workouts.status.isIn(statuses.map((s) => s.name)) &
                _db.workouts.isDeleted.equals(false),
          )
          ..groupBy([_db.workouts.id])
          ..orderBy([OrderingTerm.desc(_db.workouts.date)]);
    if (filter.dateFrom != null) {
      query.where(
        _db.workouts.date.isBiggerOrEqualValue(
          dateOnlyString(filter.dateFrom!),
        ),
      );
    }
    if (filter.dateTo != null) {
      query.where(
        _db.workouts.date.isSmallerOrEqualValue(
          dateOnlyString(filter.dateTo!),
        ),
      );
    }

    return query.watch().asyncMap((rows) async {
      if (rows.isEmpty) return const <WorkoutHistoryEntry>[];

      var workouts = rows
          .map((row) => row.readTable(_db.workouts).toDomain())
          .toList();
      final exerciseCountByWorkout = {
        for (final row in rows)
          row.readTable(_db.workouts).id: row.read(exerciseCount) ?? 0,
      };

      final tagsByWorkout = await _tagsByWorkouts(
        workouts.map((w) => w.id).toList(),
      );

      // Multi-tag filter, OR mode (02_DEVELOPMENT_PLAN.md Stage 3
      // acceptance criteria) — done in Dart against the already
      // status/date-narrowed set rather than a 3-way SQL join, which would
      // otherwise multiply/duplicate the exerciseCount aggregate rows.
      if (filter.tagIds.isNotEmpty) {
        workouts = workouts
            .where(
              (w) => (tagsByWorkout[w.id] ?? const []).any(
                (tag) => filter.tagIds.contains(tag.id),
              ),
            )
            .toList();
      }

      // Name search: Dart-side, same reasoning as the exercise catalog's
      // search (ASSUMPTION(dart-side-text-search), Stage 2) — sqlite3's
      // `LIKE` only case-folds ASCII, so a Cyrillic query wouldn't match
      // correctly via SQL.
      final normalizedQuery = filter.query.trim().toLowerCase();
      if (normalizedQuery.isNotEmpty) {
        workouts = workouts
            .where(
              (w) =>
                  w.name != null &&
                  w.name!.toLowerCase().contains(normalizedQuery),
            )
            .toList();
      }

      return workouts
          .map(
            (w) => WorkoutHistoryEntry(
              workout: w,
              exerciseCount: exerciseCountByWorkout[w.id] ?? 0,
              tags: tagsByWorkout[w.id] ?? const [],
            ),
          )
          .toList();
    });
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

  @override
  Future<void> updateWorkoutExercise(WorkoutExercise workoutExercise) async {
    await (_db.update(_db.workoutExercises)..where(
      (we) => we.id.equals(workoutExercise.id),
    )).write(workoutExercise.toUpdateCompanion());
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

  @override
  Future<List<ExerciseHistoryEntry>> getExerciseHistory(
    String exerciseId,
  ) async {
    final query =
        _db.select(_db.workoutExercises).join([
            innerJoin(
              _db.workouts,
              _db.workouts.id.equalsExp(_db.workoutExercises.workoutId),
            ),
          ])
          ..where(
            _db.workoutExercises.exerciseId.equals(exerciseId) &
                _db.workoutExercises.isDeleted.equals(false) &
                _db.workouts.status.equals(WorkoutStatus.completed.name) &
                _db.workouts.isDeleted.equals(false),
          )
          ..orderBy([OrderingTerm.desc(_db.workouts.date)]);
    final rows = await query.get();
    if (rows.isEmpty) return const [];

    final workoutExerciseIds = rows
        .map((row) => row.readTable(_db.workoutExercises).id)
        .toList();
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

    return rows.map((row) {
      final workoutExercise = row.readTable(_db.workoutExercises);
      final workout = row.readTable(_db.workouts);
      final sets =
          setsByWorkoutExercise[workoutExercise.id] ??
          const <drift.ExerciseSet>[];
      return ExerciseHistoryEntry(
        workout: workout.toDomain(),
        sets: sets.map((s) => s.toDomain()).toList(),
      );
    }).toList();
  }

  @override
  Future<void> setWorkoutTags({
    required String workoutId,
    required List<String> tagIds,
  }) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.workoutTagLinks,
      )..where((l) => l.workoutId.equals(workoutId))).go();
      for (final tagId in tagIds) {
        await _db
            .into(_db.workoutTagLinks)
            .insert(
              drift.WorkoutTagLinksCompanion.insert(
                workoutId: workoutId,
                tagId: tagId,
              ),
            );
      }
    });
  }

  @override
  Future<Workout> copyWorkout({
    required String sourceWorkoutId,
    required DateTime date,
  }) async {
    final source = await getDetails(sourceWorkoutId);
    if (source == null) {
      throw ArgumentError('Workout $sourceWorkoutId not found');
    }

    final now = DateTime.now().toUtc();
    final copy = Workout(
      id: const Uuid().v4(),
      date: date,
      status: WorkoutStatus.draft,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );

    await _db.transaction(() async {
      await _db.into(_db.workouts).insert(copy.toInsertCompanion());
      for (final exerciseDetails in source.exercises) {
        final sourceWorkoutExercise = exerciseDetails.workoutExercise;
        final workoutExercise = WorkoutExercise(
          id: const Uuid().v4(),
          workoutId: copy.id,
          exerciseId: sourceWorkoutExercise.exerciseId,
          orderIndex: sourceWorkoutExercise.orderIndex,
          comment: sourceWorkoutExercise.comment,
          progressionDecision: ProgressionDecision.none,
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );
        await _db
            .into(_db.workoutExercises)
            .insert(workoutExercise.toInsertCompanion());

        for (final sourceSet in exerciseDetails.sets) {
          final copiedSet = ExerciseSet(
            id: const Uuid().v4(),
            workoutExerciseId: workoutExercise.id,
            setNumber: sourceSet.setNumber,
            isWarmup: sourceSet.isWarmup,
            isCompleted: false,
            plannedWeightKg: sourceSet.plannedWeightKg,
            plannedReps: sourceSet.plannedReps,
            plannedDurationSec: sourceSet.plannedDurationSec,
            plannedDistanceM: sourceSet.plannedDistanceM,
            side: sourceSet.side,
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
          );
          await _db
              .into(_db.exerciseSets)
              .insert(copiedSet.toInsertCompanion());
        }
      }
    });

    return copy;
  }

  @override
  Future<void> reorderExercises({
    required String workoutId,
    required List<String> orderedWorkoutExerciseIds,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      for (var i = 0; i < orderedWorkoutExerciseIds.length; i++) {
        await (_db.update(_db.workoutExercises)..where(
          (we) => we.id.equals(orderedWorkoutExerciseIds[i]),
        )).write(
          drift.WorkoutExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }
}
