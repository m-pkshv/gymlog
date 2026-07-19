import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

String exerciseTypeLabel(AppLocalizations l10n, ExerciseType type) {
  switch (type) {
    case ExerciseType.strength:
      return l10n.exerciseTypeStrength;
    case ExerciseType.cardio:
      return l10n.exerciseTypeCardio;
    case ExerciseType.reps:
      return l10n.exerciseTypeReps;
    case ExerciseType.time:
      return l10n.exerciseTypeTime;
    case ExerciseType.stretch:
      return l10n.exerciseTypeStretch;
  }
}

IconData exerciseTypeIcon(ExerciseType type) {
  switch (type) {
    case ExerciseType.strength:
      return Icons.fitness_center;
    case ExerciseType.cardio:
      return Icons.directions_run;
    case ExerciseType.reps:
      return Icons.repeat;
    case ExerciseType.time:
      return Icons.timer_outlined;
    case ExerciseType.stretch:
      return Icons.self_improvement;
  }
}
