import '../enums.dart';

/// One set within a workout exercise (06_DATA_MODEL.md, section 6.7). A
/// single class covers all 5 exercise types (D-14); the app only
/// shows/validates the fields relevant to the exercise's type.
class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.workoutExerciseId,
    required this.setNumber,
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

  /// Sentinel default for the nullable numeric/comment params of [copyWith]:
  /// distinguishes "not passed, keep the current value" from "explicitly
  /// passed `null`, clear the field" — the editor (S-03) needs to be able to
  /// clear a field the user backspaced to empty, which a plain `?? this.x`
  /// pattern can never express.
  static const Object _unset = Object();

  ExerciseSet copyWith({
    bool? isCompleted,
    Object? plannedWeightKg = _unset,
    Object? plannedReps = _unset,
    Object? actualWeightKg = _unset,
    Object? actualReps = _unset,
    Object? rpe = _unset,
    Object? rir = _unset,
    Object? plannedDurationSec = _unset,
    Object? actualDurationSec = _unset,
    Object? plannedDistanceM = _unset,
    Object? actualDistanceM = _unset,
    Object? resistance = _unset,
    Object? inclinePercent = _unset,
    Object? avgHeartRate = _unset,
    BodySide? side,
    Object? comment = _unset,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ExerciseSet(
      id: id,
      workoutExerciseId: workoutExerciseId,
      setNumber: setNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      plannedWeightKg: identical(plannedWeightKg, _unset)
          ? this.plannedWeightKg
          : _asDouble(plannedWeightKg),
      plannedReps: identical(plannedReps, _unset)
          ? this.plannedReps
          : plannedReps as int?,
      actualWeightKg: identical(actualWeightKg, _unset)
          ? this.actualWeightKg
          : _asDouble(actualWeightKg),
      actualReps: identical(actualReps, _unset)
          ? this.actualReps
          : actualReps as int?,
      rpe: identical(rpe, _unset) ? this.rpe : _asDouble(rpe),
      rir: identical(rir, _unset) ? this.rir : rir as int?,
      plannedDurationSec: identical(plannedDurationSec, _unset)
          ? this.plannedDurationSec
          : plannedDurationSec as int?,
      actualDurationSec: identical(actualDurationSec, _unset)
          ? this.actualDurationSec
          : actualDurationSec as int?,
      plannedDistanceM: identical(plannedDistanceM, _unset)
          ? this.plannedDistanceM
          : _asDouble(plannedDistanceM),
      actualDistanceM: identical(actualDistanceM, _unset)
          ? this.actualDistanceM
          : _asDouble(actualDistanceM),
      resistance: identical(resistance, _unset)
          ? this.resistance
          : _asDouble(resistance),
      inclinePercent: identical(inclinePercent, _unset)
          ? this.inclinePercent
          : _asDouble(inclinePercent),
      avgHeartRate: identical(avgHeartRate, _unset)
          ? this.avgHeartRate
          : avgHeartRate as int?,
      side: side ?? this.side,
      comment: identical(comment, _unset) ? this.comment : comment as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// `100` (an `int` literal) no longer auto-widens to `double` once the
  /// `copyWith` param type is `Object?` instead of `double?` — callers can
  /// still pass either, so this normalizes at the cast site.
  static double? _asDouble(Object? value) => (value as num?)?.toDouble();
}
