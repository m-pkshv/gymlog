import 'package:drift/drift.dart';

import '../../domain/models/workout_tag.dart';
import '../database.dart' as drift;

extension WorkoutTagRowMapper on drift.WorkoutTag {
  WorkoutTag toDomain() {
    return WorkoutTag(
      id: id,
      name: name,
      colorHex: colorHex,
      isHidden: isHidden,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      isDeleted: isDeleted,
    );
  }
}

extension WorkoutTagCompanionMapper on WorkoutTag {
  drift.WorkoutTagsCompanion toInsertCompanion() {
    return drift.WorkoutTagsCompanion.insert(
      id: id,
      name: name,
      colorHex: Value(colorHex),
      isHidden: Value(isHidden),
      createdAt: createdAt.toUtc().toIso8601String(),
      updatedAt: updatedAt.toUtc().toIso8601String(),
    );
  }
}
