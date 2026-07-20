/// A workout tag (06_DATA_MODEL.md, section 6.3). [isHidden] is a per-tag
/// hide flag distinct from the global `AppSettings.showTags` switch; this
/// step doesn't yet offer UI to set it (Stage 3 scope: creation, assignment,
/// and the global switch only), so it always reads `false` for tags created
/// here.
class WorkoutTag {
  const WorkoutTag({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  final String id;
  final String name;
  final String colorHex;
  final bool isHidden;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  WorkoutTag copyWith({
    String? name,
    String? colorHex,
    bool? isHidden,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return WorkoutTag(
      id: id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
