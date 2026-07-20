import '../../domain/enums.dart';
import '../../domain/models/exercise_set.dart';

/// One-line summary of a logged set's *actual* values, keyed by exercise
/// type — used wherever a past occurrence is shown as a compact read-only
/// line (S-07 "История" tab, S-03 "Прошлые результаты").
String formatSetSummary(ExerciseSet set, ExerciseType type) {
  switch (type) {
    case ExerciseType.strength:
      final weight = set.actualWeightKg?.toStringAsFixed(1) ?? '—';
      final reps = set.actualReps?.toString() ?? '—';
      return '$weight kg × $reps';
    case ExerciseType.reps:
      return '${set.actualReps?.toString() ?? '—'} reps';
    case ExerciseType.cardio:
      final km = set.actualDistanceM != null
          ? (set.actualDistanceM! / 1000).toStringAsFixed(2)
          : '—';
      final duration = set.actualDurationSec?.toString() ?? '—';
      return '$km km · ${duration}s';
    case ExerciseType.time:
    case ExerciseType.stretch:
      return '${set.actualDurationSec?.toString() ?? '—'}s';
  }
}
