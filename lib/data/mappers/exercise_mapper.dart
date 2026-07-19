import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../database.dart' as drift;

/// Maps a drift `Exercises` row to the domain `Exercise` model
/// (06_DATA_MODEL.md, section 6.1). Secondary muscle groups live in a
/// separate join table, so callers pass them in after a separate query.
extension ExerciseRowMapper on drift.Exercise {
  Exercise toDomain({List<String> secondaryMuscleGroupIds = const []}) {
    return Exercise(
      id: id,
      name: name,
      description: description,
      youtubeUrl: youtubeUrl,
      imageAsset: imageAsset,
      exerciseType: ExerciseType.values.byName(exerciseType),
      primaryMuscleGroupId: primaryMuscleGroupId,
      equipmentId: equipmentId,
      effortMetric: EffortMetric.values.byName(effortMetric),
      isBuiltIn: isBuiltIn,
      isArchived: isArchived,
      secondaryMuscleGroupIds: secondaryMuscleGroupIds,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension ExerciseCompanionMapper on Exercise {
  drift.ExercisesCompanion toInsertCompanion() {
    return drift.ExercisesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      youtubeUrl: Value(youtubeUrl),
      imageAsset: Value(imageAsset),
      exerciseType: exerciseType.name,
      primaryMuscleGroupId: Value(primaryMuscleGroupId),
      equipmentId: Value(equipmentId),
      effortMetric: Value(effortMetric.name),
      isBuiltIn: Value(isBuiltIn),
      isArchived: Value(isArchived),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }
}
