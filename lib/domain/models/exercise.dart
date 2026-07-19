import '../enums.dart';

/// Catalog entry: built-in or user-created (06_DATA_MODEL.md, section 6.1).
class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.exerciseType,
    required this.effortMetric,
    required this.isBuiltIn,
    required this.isArchived,
    required this.secondaryMuscleGroupIds,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.description,
    this.youtubeUrl,
    this.imageAsset,
    this.primaryMuscleGroupId,
    this.equipmentId,
  });

  final String id;
  final String name;
  final String? description;
  final String? youtubeUrl;
  final String? imageAsset;
  final ExerciseType exerciseType;
  final String? primaryMuscleGroupId;
  final String? equipmentId;
  final EffortMetric effortMetric;
  final bool isBuiltIn;
  final bool isArchived;
  final List<String> secondaryMuscleGroupIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  Exercise copyWith({
    String? name,
    String? description,
    String? youtubeUrl,
    String? imageAsset,
    String? primaryMuscleGroupId,
    String? equipmentId,
    EffortMetric? effortMetric,
    bool? isArchived,
    List<String>? secondaryMuscleGroupIds,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      imageAsset: imageAsset ?? this.imageAsset,
      exerciseType: exerciseType,
      primaryMuscleGroupId: primaryMuscleGroupId ?? this.primaryMuscleGroupId,
      equipmentId: equipmentId ?? this.equipmentId,
      effortMetric: effortMetric ?? this.effortMetric,
      isBuiltIn: isBuiltIn,
      isArchived: isArchived ?? this.isArchived,
      secondaryMuscleGroupIds:
          secondaryMuscleGroupIds ?? this.secondaryMuscleGroupIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
