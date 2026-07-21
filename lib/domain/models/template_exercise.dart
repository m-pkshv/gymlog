/// An exercise entry within a template (06_DATA_MODEL.md, section 6.8) —
/// the template counterpart of `WorkoutExercise`, minus the fields that
/// only make sense for an actually-performed workout
/// (`progressionDecision`).
class TemplateExercise {
  const TemplateExercise({
    required this.id,
    required this.templateId,
    required this.exerciseId,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.comment,
  });

  final String id;
  final String templateId;
  final String exerciseId;
  final int orderIndex;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  TemplateExercise copyWith({
    int? orderIndex,
    String? comment,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TemplateExercise(
      id: id,
      templateId: templateId,
      exerciseId: exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      comment: comment ?? this.comment,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
