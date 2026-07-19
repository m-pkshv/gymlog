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

  Workout copyWith({
    DateTime? date,
    String? name,
    WorkoutStatus? status,
    String? comment,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? actualDurationSec,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Workout(
      id: id,
      date: date ?? this.date,
      name: name ?? this.name,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      actualDurationSec: actualDurationSec ?? this.actualDurationSec,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
