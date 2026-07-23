import '../../domain/models/exercise_history_entry.dart';
import '../../domain/models/exercise_set.dart';

/// One point on an S-10 progress chart: a workout occurrence's best/summed
/// value for one metric, oldest-first.
class ExerciseProgressPoint {
  const ExerciseProgressPoint({required this.date, required this.value});

  final DateTime date;
  final double value;
}

/// ASSUMPTION(progress-chart-per-workout-point): every S-10 chart plots one
/// point per workout occurrence (this workout's best/summed value), not a
/// single all-time number -- a flat repeated line would make the "график"
/// 04_UI_UX_SPEC.md calls for pointless, since the all-time figure is
/// already shown once in the records list. TS 9 states this explicitly for
/// the 1RM chart ("на графике — максимум за тренировку") and for tonnage
/// ("Тоннаж за период" = "Сумма тоннажей тренировок периода", i.e. one
/// tonnage number per workout); this reuses the same per-workout reading for
/// max weight/distance/pace/duration, which TS 9 doesn't spell out
/// separately but which follows the identical pattern. A workout is skipped
/// from a given chart entirely (not plotted as 0/null) when it has no
/// qualifying set for that metric -- mirrors `RecordsService`, which never
/// creates a record for an exercise type it has no data for.
List<ExerciseProgressPoint> _series(
  List<ExerciseHistoryEntry> history,
  double? Function(List<ExerciseSet> workingSets) metric,
) {
  final points = <ExerciseProgressPoint>[];
  for (final entry in history.reversed) {
    final workingSets = entry.sets
        .where((s) => s.isCompleted)
        .toList();
    final value = metric(workingSets);
    if (value != null) {
      points.add(ExerciseProgressPoint(date: entry.workout.date, value: value));
    }
  }
  return points;
}

/// TS 9: `max(actualWeightKg)`, per workout.
List<ExerciseProgressPoint> maxWeightSeries(List<ExerciseHistoryEntry> history) {
  return _series(history, (sets) {
    double? best;
    for (final set in sets) {
      final weight = set.actualWeightKg;
      if (weight != null && (best == null || weight > best)) best = weight;
    }
    return best;
  });
}

/// TS 9 / D-6: Epley `w × (1 + r/30)`, domain `r ∈ [1;12]`, `w > 0`; per
/// workout, the max across qualifying sets.
List<ExerciseProgressPoint> oneRepMaxSeries(
  List<ExerciseHistoryEntry> history,
) {
  return _series(history, (sets) {
    double? best;
    for (final set in sets) {
      final weight = set.actualWeightKg;
      final reps = set.actualReps;
      if (weight != null && weight > 0 && reps != null && reps >= 1 && reps <= 12) {
        final oneRm = weight * (1 + reps / 30);
        if (best == null || oneRm > best) best = oneRm;
      }
    }
    return best;
  });
}

/// TS 9: `Σ actualWeightKg × actualReps` per workout (a `reps`-type set
/// without a weight contributes 0). Plotted as 0.0 -- not skipped -- for a
/// workout that has working sets but none with both weight and reps,
/// mirroring `RecordsService`'s `hasWorkingSet` handling.
List<ExerciseProgressPoint> tonnageSeries(List<ExerciseHistoryEntry> history) {
  return _series(history, (sets) {
    if (sets.isEmpty) return null;
    var tonnage = 0.0;
    for (final set in sets) {
      final weight = set.actualWeightKg;
      final reps = set.actualReps;
      if (weight != null && reps != null) tonnage += weight * reps;
    }
    return tonnage;
  });
}

/// TS 9: `max(actualDistanceM)`, per workout.
List<ExerciseProgressPoint> maxDistanceSeries(
  List<ExerciseHistoryEntry> history,
) {
  return _series(history, (sets) {
    double? best;
    for (final set in sets) {
      final distance = set.actualDistanceM;
      if (distance != null && (best == null || distance > best)) best = distance;
    }
    return best;
  });
}

/// TS 9: `max(actualDurationSec)`, per workout.
List<ExerciseProgressPoint> longestDurationSeries(
  List<ExerciseHistoryEntry> history,
) {
  return _series(history, (sets) {
    double? best;
    for (final set in sets) {
      final duration = set.actualDurationSec;
      if (duration != null && (best == null || duration > best)) {
        best = duration.toDouble();
      }
    }
    return best;
  });
}

/// TS 9: `min(actualDurationSec / (actualDistanceM/1000))` among sets with
/// distance >= 500m, per workout.
List<ExerciseProgressPoint> bestPaceSeries(List<ExerciseHistoryEntry> history) {
  return _series(history, (sets) {
    double? best;
    for (final set in sets) {
      final distance = set.actualDistanceM;
      final duration = set.actualDurationSec;
      if (distance != null && distance >= 500 && duration != null) {
        final pace = duration / (distance / 1000);
        if (best == null || pace < best) best = pace;
      }
    }
    return best;
  });
}
