import '../enums.dart';

/// A planned set within a template exercise (06_DATA_MODEL.md, section
/// 6.8) — the template counterpart of `ExerciseSet`, carrying only the
/// planned metrics (templates never carry facts).
class TemplateSet {
  const TemplateSet({
    required this.id,
    required this.templateExerciseId,
    required this.setNumber,
    required this.side,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.plannedWeightKg,
    this.plannedReps,
    this.plannedDurationSec,
    this.plannedDistanceM,
  });

  final String id;
  final String templateExerciseId;
  final int setNumber;
  final double? plannedWeightKg;
  final int? plannedReps;
  final int? plannedDurationSec;
  final double? plannedDistanceM;
  final BodySide side;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// Same sentinel-default rationale as `ExerciseSet.copyWith` (Stage 1):
  /// distinguishes "not passed, keep the current value" from "explicitly
  /// passed `null`, clear the field" — the template editor (S-13) needs to
  /// clear a field the owner backspaced to empty.
  static const Object _unset = Object();

  TemplateSet copyWith({
    Object? plannedWeightKg = _unset,
    Object? plannedReps = _unset,
    Object? plannedDurationSec = _unset,
    Object? plannedDistanceM = _unset,
    BodySide? side,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TemplateSet(
      id: id,
      templateExerciseId: templateExerciseId,
      setNumber: setNumber,
      plannedWeightKg: identical(plannedWeightKg, _unset)
          ? this.plannedWeightKg
          : _asDouble(plannedWeightKg),
      plannedReps: identical(plannedReps, _unset)
          ? this.plannedReps
          : plannedReps as int?,
      plannedDurationSec: identical(plannedDurationSec, _unset)
          ? this.plannedDurationSec
          : plannedDurationSec as int?,
      plannedDistanceM: identical(plannedDistanceM, _unset)
          ? this.plannedDistanceM
          : _asDouble(plannedDistanceM),
      side: side ?? this.side,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  static double? _asDouble(Object? value) => (value as num?)?.toDouble();
}
