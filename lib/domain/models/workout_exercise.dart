import '../enums.dart';

/// An exercise entry within a workout (06_DATA_MODEL.md, section 6.6). The
/// same exercise may appear more than once (supersets).
class WorkoutExercise {
  const WorkoutExercise({
    required this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
    required this.progressionDecision,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String workoutId;
  final String exerciseId;
  final int orderIndex;
  final ProgressionDecision progressionDecision;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  WorkoutExercise copyWith({
    int? orderIndex,
    ProgressionDecision? progressionDecision,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return WorkoutExercise(
      id: id,
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      progressionDecision: progressionDecision ?? this.progressionDecision,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
