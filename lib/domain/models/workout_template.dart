/// A workout template (06_DATA_MODEL.md, section 6.8, D-16). Stored
/// separately from workouts by construction, so templates are excluded
/// from history/statistics by design, not by filters.
class WorkoutTemplate {
  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.comment,
  });

  final String id;
  final String name;
  final String? comment;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  WorkoutTemplate copyWith({
    String? name,
    String? comment,
    bool? isArchived,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return WorkoutTemplate(
      id: id,
      name: name ?? this.name,
      comment: comment ?? this.comment,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
