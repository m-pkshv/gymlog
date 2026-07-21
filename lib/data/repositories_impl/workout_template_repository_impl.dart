import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import '../../domain/models/template_details.dart';
import '../../domain/models/template_exercise.dart';
import '../../domain/models/template_list_entry.dart';
import '../../domain/models/template_set.dart';
import '../../domain/models/workout_template.dart';
import '../../domain/repositories/workout_template_repository.dart';
import '../database.dart' as drift;
import '../mappers/exercise_mapper.dart';
import '../mappers/template_mapper.dart';

/// Drift-backed `WorkoutTemplateRepository` for the template aggregate
/// (06_DATA_MODEL.md, section 6.8).
class WorkoutTemplateRepositoryImpl implements WorkoutTemplateRepository {
  WorkoutTemplateRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<WorkoutTemplate>> watchAll({bool includeArchived = false}) {
    final query = _db.select(_db.workoutTemplates)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Stream<List<TemplateListEntry>> watchAllWithExerciseCount({
    bool includeArchived = false,
  }) {
    // `exerciseCount` per template is a SQL aggregate (TS 11.6), same
    // pattern as `WorkoutRepositoryImpl.watchHistory`'s exerciseCount.
    final exerciseCount = _db.templateExercises.id.count();
    final query =
        _db.select(_db.workoutTemplates).join([
            leftOuterJoin(
              _db.templateExercises,
              _db.templateExercises.templateId.equalsExp(
                _db.workoutTemplates.id,
              ) &
                  _db.templateExercises.isDeleted.equals(false),
            ),
          ])
          ..addColumns([exerciseCount])
          ..where(_db.workoutTemplates.isDeleted.equals(false))
          ..groupBy([_db.workoutTemplates.id])
          ..orderBy([OrderingTerm.desc(_db.workoutTemplates.createdAt)]);
    if (!includeArchived) {
      query.where(_db.workoutTemplates.isArchived.equals(false));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => TemplateListEntry(
              template: row.readTable(_db.workoutTemplates).toDomain(),
              exerciseCount: row.read(exerciseCount) ?? 0,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<TemplateDetails?> getDetails(String templateId) async {
    final templateRow = await (_db.select(_db.workoutTemplates)..where(
      (t) => t.id.equals(templateId) & t.isDeleted.equals(false),
    )).getSingleOrNull();
    if (templateRow == null) return null;

    final templateExerciseRows =
        await (_db.select(_db.templateExercises)
              ..where(
                (te) =>
                    te.templateId.equals(templateId) &
                    te.isDeleted.equals(false),
              )
              ..orderBy([(te) => OrderingTerm.asc(te.orderIndex)]))
            .get();

    if (templateExerciseRows.isEmpty) {
      return TemplateDetails(template: templateRow.toDomain(), exercises: const []);
    }

    final exerciseIds = templateExerciseRows
        .map((te) => te.exerciseId)
        .toSet()
        .toList();
    final exerciseRows = await (_db.select(
      _db.exercises,
    )..where((e) => e.id.isIn(exerciseIds))).get();
    final exerciseById = {for (final row in exerciseRows) row.id: row};

    final templateExerciseIds = templateExerciseRows
        .map((te) => te.id)
        .toList();
    final setRows =
        await (_db.select(_db.templateSets)
              ..where(
                (s) =>
                    s.templateExerciseId.isIn(templateExerciseIds) &
                    s.isDeleted.equals(false),
              )
              ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
            .get();
    final setsByTemplateExercise = <String, List<drift.TemplateSet>>{};
    for (final row in setRows) {
      setsByTemplateExercise
          .putIfAbsent(row.templateExerciseId, () => [])
          .add(row);
    }

    final exercises = templateExerciseRows.map((teRow) {
      final exerciseRow = exerciseById[teRow.exerciseId]!;
      final sets =
          setsByTemplateExercise[teRow.id] ?? const <drift.TemplateSet>[];
      return TemplateExerciseDetails(
        templateExercise: teRow.toDomain(),
        exercise: exerciseRow.toDomain(),
        sets: sets.map((s) => s.toDomain()).toList(),
      );
    }).toList();

    return TemplateDetails(template: templateRow.toDomain(), exercises: exercises);
  }

  @override
  Future<WorkoutTemplate> create({required String name, String? comment}) async {
    final now = DateTime.now().toUtc();
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: name,
      comment: comment,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.workoutTemplates).insert(template.toInsertCompanion());
    return template;
  }

  @override
  Future<WorkoutTemplate> duplicate({
    required String templateId,
    required String name,
  }) async {
    final source = await getDetails(templateId);
    if (source == null) {
      throw ArgumentError('Template $templateId not found');
    }

    final now = DateTime.now().toUtc();
    final copy = WorkoutTemplate(
      id: const Uuid().v4(),
      name: name,
      comment: source.template.comment,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );

    await _db.transaction(() async {
      await _db.into(_db.workoutTemplates).insert(copy.toInsertCompanion());
      for (final exerciseDetails in source.exercises) {
        final sourceTemplateExercise = exerciseDetails.templateExercise;
        final templateExercise = TemplateExercise(
          id: const Uuid().v4(),
          templateId: copy.id,
          exerciseId: sourceTemplateExercise.exerciseId,
          orderIndex: sourceTemplateExercise.orderIndex,
          comment: sourceTemplateExercise.comment,
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );
        await _db
            .into(_db.templateExercises)
            .insert(templateExercise.toInsertCompanion());

        for (final sourceSet in exerciseDetails.sets) {
          final copiedSet = TemplateSet(
            id: const Uuid().v4(),
            templateExerciseId: templateExercise.id,
            setNumber: sourceSet.setNumber,
            isWarmup: sourceSet.isWarmup,
            plannedWeightKg: sourceSet.plannedWeightKg,
            plannedReps: sourceSet.plannedReps,
            plannedDurationSec: sourceSet.plannedDurationSec,
            plannedDistanceM: sourceSet.plannedDistanceM,
            side: sourceSet.side,
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
          );
          await _db.into(_db.templateSets).insert(copiedSet.toInsertCompanion());
        }
      }
    });

    return copy;
  }

  @override
  Future<WorkoutTemplate> createFromWorkout({
    required String workoutId,
    required String name,
  }) async {
    final workoutRow = await (_db.select(_db.workouts)..where(
      (w) => w.id.equals(workoutId) & w.isDeleted.equals(false),
    )).getSingleOrNull();
    if (workoutRow == null) {
      throw ArgumentError('Workout $workoutId not found');
    }

    final workoutExerciseRows =
        await (_db.select(_db.workoutExercises)
              ..where(
                (we) =>
                    we.workoutId.equals(workoutId) & we.isDeleted.equals(false),
              )
              ..orderBy([(we) => OrderingTerm.asc(we.orderIndex)]))
            .get();

    final now = DateTime.now().toUtc();
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: name,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );

    await _db.transaction(() async {
      await _db.into(_db.workoutTemplates).insert(template.toInsertCompanion());
      for (final weRow in workoutExerciseRows) {
        final templateExercise = TemplateExercise(
          id: const Uuid().v4(),
          templateId: template.id,
          exerciseId: weRow.exerciseId,
          orderIndex: weRow.orderIndex,
          comment: weRow.comment,
          createdAt: now,
          updatedAt: now,
          isDeleted: false,
        );
        await _db
            .into(_db.templateExercises)
            .insert(templateExercise.toInsertCompanion());

        final setRows =
            await (_db.select(_db.exerciseSets)
                  ..where(
                    (s) =>
                        s.workoutExerciseId.equals(weRow.id) &
                        s.isDeleted.equals(false),
                  )
                  ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
                .get();
        for (final setRow in setRows) {
          final templateSet = TemplateSet(
            id: const Uuid().v4(),
            templateExerciseId: templateExercise.id,
            setNumber: setRow.setNumber,
            isWarmup: setRow.isWarmup,
            plannedWeightKg: setRow.plannedWeightKg,
            plannedReps: setRow.plannedReps,
            plannedDurationSec: setRow.plannedDurationSec,
            plannedDistanceM: setRow.plannedDistanceM,
            side: BodySide.values.byName(setRow.side),
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
          );
          await _db.into(_db.templateSets).insert(templateSet.toInsertCompanion());
        }
      }
    });

    return template;
  }

  @override
  Future<void> update(WorkoutTemplate template) async {
    await (_db.update(
      _db.workoutTemplates,
    )..where((t) => t.id.equals(template.id))).write(template.toUpdateCompanion());
  }

  @override
  Future<TemplateExercise> addExercise({
    required String templateId,
    required String exerciseId,
  }) async {
    final now = DateTime.now().toUtc();
    final maxOrderIndex = await _maxOrderIndex(templateId);
    final templateExercise = TemplateExercise(
      id: const Uuid().v4(),
      templateId: templateId,
      exerciseId: exerciseId,
      orderIndex: maxOrderIndex + 1,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db
        .into(_db.templateExercises)
        .insert(templateExercise.toInsertCompanion());
    return templateExercise;
  }

  @override
  Future<void> updateTemplateExercise(TemplateExercise templateExercise) async {
    await (_db.update(_db.templateExercises)..where(
      (te) => te.id.equals(templateExercise.id),
    )).write(templateExercise.toUpdateCompanion());
  }

  Future<int> _maxOrderIndex(String templateId) async {
    final rows =
        await (_db.select(_db.templateExercises)..where(
              (te) =>
                  te.templateId.equals(templateId) & te.isDeleted.equals(false),
            ))
            .get();
    if (rows.isEmpty) return -1;
    return rows.map((row) => row.orderIndex).reduce((a, b) => a > b ? a : b);
  }

  @override
  Future<TemplateSet> addSet({
    required String templateExerciseId,
    required bool isWarmup,
  }) async {
    final now = DateTime.now().toUtc();
    final nextSetNumber = await _nextSetNumber(templateExerciseId);
    final templateSet = TemplateSet(
      id: const Uuid().v4(),
      templateExerciseId: templateExerciseId,
      setNumber: nextSetNumber,
      isWarmup: isWarmup,
      side: BodySide.none,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.templateSets).insert(templateSet.toInsertCompanion());
    return templateSet;
  }

  Future<int> _nextSetNumber(String templateExerciseId) async {
    final rows =
        await (_db.select(_db.templateSets)..where(
              (s) =>
                  s.templateExerciseId.equals(templateExerciseId) &
                  s.isDeleted.equals(false),
            ))
            .get();
    if (rows.isEmpty) return 1;
    return rows.map((row) => row.setNumber).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<void> updateTemplateSet(TemplateSet set) async {
    await (_db.update(
      _db.templateSets,
    )..where((s) => s.id.equals(set.id))).write(set.toUpdateCompanion());
  }

  @override
  Future<void> reorderExercises({
    required String templateId,
    required List<String> orderedTemplateExerciseIds,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      for (var i = 0; i < orderedTemplateExerciseIds.length; i++) {
        await (_db.update(_db.templateExercises)..where(
          (te) => te.id.equals(orderedTemplateExerciseIds[i]),
        )).write(
          drift.TemplateExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  @override
  Future<void> deleteTemplate(String templateId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      await (_db.update(
        _db.workoutTemplates,
      )..where((t) => t.id.equals(templateId))).write(
        drift.WorkoutTemplatesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      final templateExerciseIds = await _nonDeletedTemplateExerciseIds(
        templateId,
      );
      await (_db.update(_db.templateExercises)..where(
        (te) => te.id.isIn(templateExerciseIds),
      )).write(
        drift.TemplateExercisesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );

      await (_db.update(_db.templateSets)..where(
        (s) => s.templateExerciseId.isIn(templateExerciseIds),
      )).write(
        drift.TemplateSetsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }

  @override
  Future<void> restoreTemplate(String templateId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      await (_db.update(
        _db.workoutTemplates,
      )..where((t) => t.id.equals(templateId))).write(
        drift.WorkoutTemplatesCompanion(
          isDeleted: const Value(false),
          updatedAt: Value(now),
        ),
      );

      final templateExerciseIds = await (_db.select(
        _db.templateExercises,
      )..where((te) => te.templateId.equals(templateId))).map((te) => te.id).get();

      await (_db.update(_db.templateExercises)..where(
        (te) => te.templateId.equals(templateId),
      )).write(
        drift.TemplateExercisesCompanion(
          isDeleted: const Value(false),
          updatedAt: Value(now),
        ),
      );

      await (_db.update(_db.templateSets)..where(
        (s) => s.templateExerciseId.isIn(templateExerciseIds),
      )).write(
        drift.TemplateSetsCompanion(
          isDeleted: const Value(false),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<List<String>> _nonDeletedTemplateExerciseIds(String templateId) async {
    final rows = await (_db.select(_db.templateExercises)..where(
      (te) => te.templateId.equals(templateId) & te.isDeleted.equals(false),
    )).get();
    return rows.map((row) => row.id).toList();
  }
}
