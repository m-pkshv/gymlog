import '../enums.dart';

/// A workout event (06_DATA_MODEL.md, section 6.4). Status transitions are
/// enforced by `workout_service`, not by this class (section 6.4.1).
class Workout {
  const Workout({
    required this.id,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.name,
    this.comment,
    this.startedAt,
    this.finishedAt,
    this.actualDurationSec,
  });

  final String id;

  /// Local calendar date (time-of-day components are not meaningful).
  final DateTime date;
  final String? name;
  final WorkoutStatus status;
  final String? comment;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int? actualDurationSec;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// Sentinel default for the nullable params of [copyWith]: distinguishes
  /// "not passed, keep the current value" from "explicitly passed `null`,
  /// clear the field" — same rationale as `ExerciseSet.copyWith` (Stage 1).
  /// Needed here so renaming a workout back to the "Тренировка + date"
  /// fallback (Stage 10, owner-reported: rename support) can actually clear
  /// `name`, which a plain `?? this.name` pattern could never express.
  static const Object _unset = Object();

  Workout copyWith({
    DateTime? date,
    Object? name = _unset,
    WorkoutStatus? status,
    Object? comment = _unset,
    Object? startedAt = _unset,
    Object? finishedAt = _unset,
    Object? actualDurationSec = _unset,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Workout(
      id: id,
      date: date ?? this.date,
      name: identical(name, _unset) ? this.name : name as String?,
      status: status ?? this.status,
      comment: identical(comment, _unset) ? this.comment : comment as String?,
      startedAt: identical(startedAt, _unset)
          ? this.startedAt
          : startedAt as DateTime?,
      finishedAt: identical(finishedAt, _unset)
          ? this.finishedAt
          : finishedAt as DateTime?,
      actualDurationSec: identical(actualDurationSec, _unset)
          ? this.actualDurationSec
          : actualDurationSec as int?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
