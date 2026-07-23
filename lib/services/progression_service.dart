import '../domain/enums.dart';
import '../domain/models/exercise_history_entry.dart';
import '../domain/models/exercise_progression_state.dart';
import '../domain/models/exercise_set.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/progression_repository.dart';
import '../domain/repositories/workout_repository.dart';

/// The stagnation-counter algorithm (D-7, 03_TECHNICAL_SPEC.md section 9.4)
/// — the single point of truth for `ExerciseProgressionState`. Recomputed
/// in full from history every time (idempotent, per TS 9.4's own
/// description of the algorithm), not updated incrementally, so a missed
/// trigger just means a stale cache rather than a corrupt one.
///
/// Best-set selection for `reps`/`cardio`/`time`/`stretch` (TS 9.4 only
/// spells out the rule for `strength` explicitly — max Epley 1RM, tie ->
/// higher weight): picks the working set that maximizes the type's first
/// listed comparison metric (reps count / distance / duration), the same
/// "one discriminator picks the representative set" shape TS 9.4 uses for
/// strength. Confirmed by the owner 2026-07-21.
///
/// If every working set in an occurrence falls outside D-6's 1RM domain
/// (reps 1-12, weight > 0), that occurrence is treated as having no
/// measurable strength result (a null/null vector) — the same treatment as
/// an occurrence with no completed working sets at all. Confirmed by the
/// owner 2026-07-21; flagged by the owner to revisit before final release
/// (Stage 10 stabilization) in case a strength occurrence with only
/// out-of-domain reps should instead be excluded from the sequence rather
/// than counted as a null vector.
///
/// A `null` -> value transition (occurrence had no measurable result, next
/// one does) counts as an increase (resets the stagnation counter) — TS
/// 9.4 defines "null stayed null" as unchanged and "value became null" as
/// a decrease, but doesn't spell out this direction; treated as the
/// natural complement. Confirmed by the owner 2026-07-21.
class ProgressionService {
  ProgressionService(this._workoutRepository, this._exerciseRepository, this._progressionRepository);

  final WorkoutRepository _workoutRepository;
  final ExerciseRepository _exerciseRepository;
  final ProgressionRepository _progressionRepository;

  /// Full, idempotent recompute of [exerciseId]'s stagnation counter (DM
  /// 6.10/6.11 triggers: workout completed/resumed/deleted/restored, a set
  /// of an already-completed workout edited, or the exercise archived).
  /// Does nothing if the exercise has no completed occurrences yet.
  Future<void> recompute(String exerciseId) async {
    final exercise = await _exerciseRepository.getById(exerciseId);
    if (exercise == null) return;

    final history = await _workoutRepository.getExerciseHistory(exerciseId);
    if (history.isEmpty) return;

    // TS 9.4 step 1: sort ascending by (date, finishedAt) -- getExerciseHistory
    // returns most-recent-first, and only by date (no finishedAt tie-break).
    final occurrences = List<ExerciseHistoryEntry>.from(history)
      ..sort((a, b) {
        final byDate = a.workout.date.compareTo(b.workout.date);
        if (byDate != 0) return byDate;
        final aFinished = a.workout.finishedAt ?? DateTime.utc(0);
        final bFinished = b.workout.finishedAt ?? DateTime.utc(0);
        return aFinished.compareTo(bFinished);
      });

    var count = 0;
    for (var i = 1; i < occurrences.length; i++) {
      final previous = _bestVector(occurrences[i - 1], exercise.exerciseType);
      final current = _bestVector(occurrences[i], exercise.exerciseType);
      count = _isGrowth(previous, current) ? 0 : count + 1;
    }

    await _progressionRepository.saveState(
      ExerciseProgressionState(
        exerciseId: exerciseId,
        stagnationCount: count,
        lastCountedWorkoutId: occurrences.last.workout.id,
        computedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// The comparison vector for one occurrence (TS 9.4): the working,
  /// completed sets' "best" set picked per [type], reduced to the listed
  /// comparison metrics. `null` entries mean "no measurable result".
  List<double?> _bestVector(ExerciseHistoryEntry entry, ExerciseType type) {
    final workingSets = entry.sets
        .where((s) => s.isCompleted)
        .toList();

    switch (type) {
      case ExerciseType.strength:
        ExerciseSet? best;
        var bestOneRm = double.negativeInfinity;
        for (final set in workingSets) {
          final weight = set.actualWeightKg;
          final reps = set.actualReps;
          if (weight == null || reps == null) continue;
          if (weight <= 0 || reps < 1 || reps > 12) continue; // D-6 domain
          final oneRm = weight * (1 + reps / 30);
          if (best == null ||
              oneRm > bestOneRm ||
              (oneRm == bestOneRm && weight > best.actualWeightKg!)) {
            best = set;
            bestOneRm = oneRm;
          }
        }
        return [best?.actualWeightKg, best?.actualReps?.toDouble()];

      case ExerciseType.reps:
        ExerciseSet? best;
        for (final set in workingSets) {
          if (set.actualReps == null) continue;
          if (best == null || set.actualReps! > best.actualReps!) best = set;
        }
        return [best?.actualReps?.toDouble(), best?.actualWeightKg];

      case ExerciseType.cardio:
        ExerciseSet? best;
        for (final set in workingSets) {
          if (set.actualDistanceM == null) continue;
          if (best == null || set.actualDistanceM! > best.actualDistanceM!) {
            best = set;
          }
        }
        final duration = best?.actualDurationSec;
        return [best?.actualDistanceM, duration == null ? null : -duration.toDouble()];

      case ExerciseType.time:
      case ExerciseType.stretch:
        ExerciseSet? best;
        for (final set in workingSets) {
          if (set.actualDurationSec == null) continue;
          if (best == null || set.actualDurationSec! > best.actualDurationSec!) {
            best = set;
          }
        }
        return [best?.actualDurationSec?.toDouble()];
    }
  }

  /// TS 9.4: growth = some metric strictly increased and none decreased.
  bool _isGrowth(List<double?> previous, List<double?> current) {
    var anyIncrease = false;
    for (var i = 0; i < previous.length; i++) {
      final p = previous[i];
      final c = current[i];
      if (p == null && c == null) continue;
      if (p != null && c == null) return false; // value -> null: decrease
      if (p == null && c != null) {
        anyIncrease = true; // null -> value counts as an increase
        continue;
      }
      if (c! > p!) {
        anyIncrease = true;
      } else if (c < p) {
        return false;
      }
    }
    return anyIncrease;
  }
}
