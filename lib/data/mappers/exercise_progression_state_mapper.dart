import 'package:drift/drift.dart';

import '../../domain/models/exercise_progression_state.dart';
import '../database.dart' as drift;

extension ExerciseProgressionStateRowMapper on drift.ExerciseProgressionState {
  ExerciseProgressionState toDomain() {
    return ExerciseProgressionState(
      exerciseId: exerciseId,
      stagnationCount: stagnationCount,
      lastCountedWorkoutId: lastCountedWorkoutId!,
      computedAt: DateTime.parse(computedAt),
    );
  }
}

extension ExerciseProgressionStateCompanionMapper on ExerciseProgressionState {
  drift.ExerciseProgressionStatesCompanion toUpsertCompanion() {
    return drift.ExerciseProgressionStatesCompanion.insert(
      exerciseId: exerciseId,
      stagnationCount: stagnationCount,
      lastCountedWorkoutId: Value(lastCountedWorkoutId),
      computedAt: computedAt.toUtc().toIso8601String(),
    );
  }
}
