import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/template_exercise.dart';
import '../../domain/models/template_set.dart';
import '../../domain/models/workout_template.dart';
import '../database.dart' as drift;

extension WorkoutTemplateRowMapper on drift.WorkoutTemplate {
  WorkoutTemplate toDomain() {
    return WorkoutTemplate(
      id: id,
      name: name,
      comment: comment,
      isArchived: isArchived,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension WorkoutTemplateCompanionMapper on WorkoutTemplate {
  drift.WorkoutTemplatesCompanion toInsertCompanion() {
    return drift.WorkoutTemplatesCompanion.insert(
      id: id,
      name: name,
      comment: Value(comment),
      isArchived: Value(isArchived),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.WorkoutTemplatesCompanion toUpdateCompanion() {
    return drift.WorkoutTemplatesCompanion(
      name: Value(name),
      comment: Value(comment),
      isArchived: Value(isArchived),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}

extension TemplateExerciseRowMapper on drift.TemplateExercise {
  TemplateExercise toDomain() {
    return TemplateExercise(
      id: id,
      templateId: templateId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      comment: comment,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension TemplateExerciseCompanionMapper on TemplateExercise {
  drift.TemplateExercisesCompanion toInsertCompanion() {
    return drift.TemplateExercisesCompanion.insert(
      id: id,
      templateId: templateId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      comment: Value(comment),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.TemplateExercisesCompanion toUpdateCompanion() {
    return drift.TemplateExercisesCompanion(
      orderIndex: Value(orderIndex),
      comment: Value(comment),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}

extension TemplateSetRowMapper on drift.TemplateSet {
  TemplateSet toDomain() {
    return TemplateSet(
      id: id,
      templateExerciseId: templateExerciseId,
      setNumber: setNumber,
      isWarmup: isWarmup,
      plannedWeightKg: plannedWeightKg,
      plannedReps: plannedReps,
      plannedDurationSec: plannedDurationSec,
      plannedDistanceM: plannedDistanceM,
      side: BodySide.values.byName(side),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension TemplateSetCompanionMapper on TemplateSet {
  drift.TemplateSetsCompanion toInsertCompanion() {
    return drift.TemplateSetsCompanion.insert(
      id: id,
      templateExerciseId: templateExerciseId,
      setNumber: setNumber,
      isWarmup: Value(isWarmup),
      plannedWeightKg: Value(plannedWeightKg),
      plannedReps: Value(plannedReps),
      plannedDurationSec: Value(plannedDurationSec),
      plannedDistanceM: Value(plannedDistanceM),
      side: Value(side.name),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.TemplateSetsCompanion toUpdateCompanion() {
    return drift.TemplateSetsCompanion(
      isWarmup: Value(isWarmup),
      plannedWeightKg: Value(plannedWeightKg),
      plannedReps: Value(plannedReps),
      plannedDurationSec: Value(plannedDurationSec),
      plannedDistanceM: Value(plannedDistanceM),
      side: Value(side.name),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}
