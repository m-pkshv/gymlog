import '../enums.dart';

/// One set within a workout exercise (06_DATA_MODEL.md, section 6.7). A
/// single class covers all 5 exercise types (D-14); the app only
/// shows/validates the fields relevant to the exercise's type.
class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
    required this.isWarmup,
    required this.isCompleted,
    required this.side,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.plannedWeightKg,
    this.plannedReps,
    this.actualWeightKg,
    this.actualReps,
    this.rpe,
    this.rir,
    this.plannedDurationSec,
    this.actualDurationSec,
    this.plannedDistanceM,
    this.actualDistanceM,
    this.resistance,
    this.inclinePercent,
    this.avgHeartRate,
    this.comment,
  });

  final String id;
  final String workoutExerciseId;
  final int setNumber;
  final bool isWarmup;
  final bool isCompleted;
  final double? plannedWeightKg;
  final int? plannedReps;
  final double? actualWeightKg;
  final int? actualReps;
  final double? rpe;
  final int? rir;
  final int? plannedDurationSec;
  final int? actualDurationSec;
  final double? plannedDistanceM;
  final double? actualDistanceM;
  final double? resistance;
  final double? inclinePercent;
  final int? avgHeartRate;
  final BodySide side;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// "Выполнил как запланировано" (06_DATA_MODEL.md, section 6.7): marking
  /// a set completed with empty facts copies the planned values into them.
  /// Unmarking leaves the copied values in place.
  ExerciseSet markCompleted() {
    return copyWith(
      isCompleted: true,
      actualWeightKg: actualWeightKg ?? plannedWeightKg,
      actualReps: actualReps ?? plannedReps,
      actualDurationSec: actualDurationSec ?? plannedDurationSec,
      actualDistanceM: actualDistanceM ?? plannedDistanceM,
    );
  }

  ExerciseSet copyWith({
    bool? isWarmup,
    bool? isCompleted,
    double? plannedWeightKg,
    int? plannedReps,
    double? actualWeightKg,
    int? actualReps,
    double? rpe,
    int? rir,
    int? plannedDurationSec,
    int? actualDurationSec,
    double? plannedDistanceM,
    double? actualDistanceM,
    double? resistance,
    double? inclinePercent,
    int? avgHeartRate,
    BodySide? side,
    String? comment,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ExerciseSet(
      id: id,
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      isWarmup: isWarmup ?? this.isWarmup,
      isCompleted: isCompleted ?? this.isCompleted,
      plannedWeightKg: plannedWeightKg ?? this.plannedWeightKg,
      plannedReps: plannedReps ?? this.plannedReps,
      actualWeightKg: actualWeightKg ?? this.actualWeightKg,
      actualReps: actualReps ?? this.actualReps,
      rpe: rpe ?? this.rpe,
      rir: rir ?? this.rir,
      plannedDurationSec: plannedDurationSec ?? this.plannedDurationSec,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      plannedDistanceM: plannedDistanceM ?? this.plannedDistanceM,
      actualDistanceM: actualDistanceM ?? this.actualDistanceM,
      resistance: resistance ?? this.resistance,
      inclinePercent: inclinePercent ?? this.inclinePercent,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      side: side ?? this.side,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
