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
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String templateId;
  final String exerciseId;
  final int orderIndex;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  /// Sentinel default for [comment] — same rationale as
  /// `WorkoutExercise.copyWith`.
  static const Object _unset = Object();

  TemplateExercise copyWith({
    int? orderIndex,
    Object? comment = _unset,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return TemplateExercise(
      id: id,
      templateId: templateId,
      exerciseId: exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      comment: identical(comment, _unset) ? this.comment : comment as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
