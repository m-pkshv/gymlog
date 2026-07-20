import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_exercise.dart';
import '../database.dart' as drift;

String dateOnlyString(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

extension WorkoutRowMapper on drift.Workout {
  Workout toDomain() {
    return Workout(
      id: id,
      date: DateTime.parse(date),
      name: name,
      status: WorkoutStatus.values.byName(status),
      comment: comment,
      startedAt: startedAt != null ? DateTime.parse(startedAt!) : null,
      finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
      actualDurationSec: actualDurationSec,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension WorkoutCompanionMapper on Workout {
  drift.WorkoutsCompanion toInsertCompanion() {
    return drift.WorkoutsCompanion.insert(
      id: id,
      date: dateOnlyString(date),
      name: Value(name),
      status: Value(status.name),
      comment: Value(comment),
      startedAt: Value(startedAt?.toUtc().toIso8601String()),
      finishedAt: Value(finishedAt?.toUtc().toIso8601String()),
      actualDurationSec: Value(actualDurationSec),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.WorkoutsCompanion toUpdateCompanion() {
    return drift.WorkoutsCompanion(
      date: Value(dateOnlyString(date)),
      name: Value(name),
      status: Value(status.name),
      comment: Value(comment),
      startedAt: Value(startedAt?.toUtc().toIso8601String()),
      finishedAt: Value(finishedAt?.toUtc().toIso8601String()),
      actualDurationSec: Value(actualDurationSec),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}

extension WorkoutExerciseRowMapper on drift.WorkoutExercise {
  WorkoutExercise toDomain() {
    return WorkoutExercise(
      id: id,
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      comment: comment,
      progressionDecision: ProgressionDecision.values.byName(
        progressionDecision,
      ),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension WorkoutExerciseCompanionMapper on WorkoutExercise {
  drift.WorkoutExercisesCompanion toInsertCompanion() {
    return drift.WorkoutExercisesCompanion.insert(
      id: id,
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      comment: Value(comment),
      progressionDecision: Value(progressionDecision.name),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.WorkoutExercisesCompanion toUpdateCompanion() {
    return drift.WorkoutExercisesCompanion(
      orderIndex: Value(orderIndex),
      comment: Value(comment),
      progressionDecision: Value(progressionDecision.name),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}

extension ExerciseSetRowMapper on drift.ExerciseSet {
  ExerciseSet toDomain() {
    return ExerciseSet(
      id: id,
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      isWarmup: isWarmup,
      isCompleted: isCompleted,
      plannedWeightKg: plannedWeightKg,
      plannedReps: plannedReps,
      actualWeightKg: actualWeightKg,
      actualReps: actualReps,
      rpe: rpe,
      rir: rir,
      plannedDurationSec: plannedDurationSec,
      actualDurationSec: actualDurationSec,
      plannedDistanceM: plannedDistanceM,
      actualDistanceM: actualDistanceM,
      resistance: resistance,
      inclinePercent: inclinePercent,
      avgHeartRate: avgHeartRate,
      side: BodySide.values.byName(side),
      comment: comment,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension ExerciseSetCompanionMapper on ExerciseSet {
  drift.ExerciseSetsCompanion toInsertCompanion() {
    return drift.ExerciseSetsCompanion.insert(
      id: id,
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      isWarmup: Value(isWarmup),
      isCompleted: Value(isCompleted),
      plannedWeightKg: Value(plannedWeightKg),
      plannedReps: Value(plannedReps),
      actualWeightKg: Value(actualWeightKg),
      actualReps: Value(actualReps),
      rpe: Value(rpe),
      rir: Value(rir),
      plannedDurationSec: Value(plannedDurationSec),
      actualDurationSec: Value(actualDurationSec),
      plannedDistanceM: Value(plannedDistanceM),
      actualDistanceM: Value(actualDistanceM),
      resistance: Value(resistance),
      inclinePercent: Value(inclinePercent),
      avgHeartRate: Value(avgHeartRate),
      side: Value(side.name),
      comment: Value(comment),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }

  drift.ExerciseSetsCompanion toUpdateCompanion() {
    return drift.ExerciseSetsCompanion(
      isWarmup: Value(isWarmup),
      isCompleted: Value(isCompleted),
      plannedWeightKg: Value(plannedWeightKg),
      plannedReps: Value(plannedReps),
      actualWeightKg: Value(actualWeightKg),
      actualReps: Value(actualReps),
      rpe: Value(rpe),
      rir: Value(rir),
      plannedDurationSec: Value(plannedDurationSec),
      actualDurationSec: Value(actualDurationSec),
      plannedDistanceM: Value(plannedDistanceM),
      actualDistanceM: Value(actualDistanceM),
      resistance: Value(resistance),
      inclinePercent: Value(inclinePercent),
      avgHeartRate: Value(avgHeartRate),
      side: Value(side.name),
      comment: Value(comment),
      updatedAt: Value(updatedAt.toUtc().toIso8601String()),
    );
  }
}
