import '../domain/enums.dart';
import '../domain/models/exercise_history_entry.dart';
import '../domain/models/exercise_set.dart';
import '../domain/models/personal_record.dart';
import '../domain/models/workout.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/personal_record_repository.dart';
import '../domain/repositories/workout_repository.dart';

/// The personal-record cache algorithm (D-8, 03_TECHNICAL_SPEC.md section 9)
/// — the single point of truth for `PersonalRecord`. Recomputed in full from
/// history every time (06_DATA_MODEL.md section 6.10: "не является
/// источником истины; полностью перестраивается из истории"), mirroring
/// `ProgressionService`'s role for the D-7 stagnation counter.
///
/// Record coverage by exercise type, per 04_UI_UX_SPEC.md's S-10 ("Для
/// strength/reps: ... макс. веса, расчётного 1ПМ, тоннажа; ... «повторения
/// при весе». Для cardio: дистанция, темп, длительность."): `strength`/
/// `reps` get [RecordType.maxWeight]/[RecordType.max1RM]/
/// [RecordType.maxVolumeWorkout]/[RecordType.maxRepsAtWeight]; `cardio` gets
/// [RecordType.maxDistance]/[RecordType.bestPace]/
/// [RecordType.longestDuration]. `time`/`stretch` produce no records — S-10
/// doesn't cover them and TS 9's formula table defines nothing for them.
class RecordsService {
  RecordsService(
    this._workoutRepository,
    this._exerciseRepository,
    this._personalRecordRepository,
  );

  final WorkoutRepository _workoutRepository;
  final ExerciseRepository _exerciseRepository;
  final PersonalRecordRepository _personalRecordRepository;

  /// Full, idempotent recompute of [exerciseId]'s personal records
  /// (06_DATA_MODEL.md section 6.10 triggers: workout completed/resumed/
  /// deleted/restored, a set of an already-completed workout edited, or the
  /// exercise archived). Replaces the exercise's entire cached record set,
  /// including clearing it to empty if the exercise no longer has any
  /// qualifying history.
  Future<void> recompute(String exerciseId) async {
    final exercise = await _exerciseRepository.getById(exerciseId);
    if (exercise == null) return;

    final history = await _workoutRepository.getExerciseHistory(exerciseId);
    final now = DateTime.now().toUtc();

    final records = switch (exercise.exerciseType) {
      ExerciseType.strength || ExerciseType.reps => _strengthRecords(
        exerciseId,
        history,
        now,
      ),
      ExerciseType.cardio => _cardioRecords(exerciseId, history, now),
      ExerciseType.time || ExerciseType.stretch => const <PersonalRecord>[],
    };

    await _personalRecordRepository.replaceForExercise(exerciseId, records);
  }

  /// TS 9: max weight, computed 1RM (Epley, D-6 domain reps 1-12/weight>0),
  /// per-workout tonnage (Σ weight×reps, reps-without-weight contributes 0),
  /// and max reps at each distinct weight ever used.
  List<PersonalRecord> _strengthRecords(
    String exerciseId,
    List<ExerciseHistoryEntry> history,
    DateTime now,
  ) {
    ExerciseSet? bestWeightSet;
    Workout? bestWeightWorkout;

    ExerciseSet? best1RmSet;
    Workout? best1RmWorkout;
    var best1Rm = double.negativeInfinity;

    final repsAtWeight = <double, ({ExerciseSet set, Workout workout})>{};

    Workout? bestVolumeWorkout;
    var bestVolume = double.negativeInfinity;

    for (final entry in history) {
      var tonnage = 0.0;
      var hasWorkingSet = false;

      for (final set in entry.sets.where((s) => s.isCompleted)) {
        hasWorkingSet = true;
        final weight = set.actualWeightKg;
        final reps = set.actualReps;

        if (weight != null && reps != null) {
          tonnage += weight * reps;
        }

        if (weight != null &&
            (bestWeightSet == null || weight > bestWeightSet.actualWeightKg!)) {
          bestWeightSet = set;
          bestWeightWorkout = entry.workout;
        }

        if (weight != null && weight > 0 && reps != null && reps >= 1 && reps <= 12) {
          final oneRm = weight * (1 + reps / 30);
          if (oneRm > best1Rm) {
            best1Rm = oneRm;
            best1RmSet = set;
            best1RmWorkout = entry.workout;
          }
        }

        if (weight != null && reps != null) {
          final existing = repsAtWeight[weight];
          if (existing == null || reps > existing.set.actualReps!) {
            repsAtWeight[weight] = (set: set, workout: entry.workout);
          }
        }
      }

      if (hasWorkingSet && tonnage > bestVolume) {
        bestVolume = tonnage;
        bestVolumeWorkout = entry.workout;
      }
    }

    final records = <PersonalRecord>[];

    if (bestWeightSet != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.maxWeight,
          value: bestWeightSet.actualWeightKg!,
          workoutId: bestWeightWorkout!.id,
          exerciseSetId: bestWeightSet.id,
          achievedAt: bestWeightWorkout.date,
          computedAt: now,
        ),
      );
    }

    if (best1RmSet != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.max1RM,
          value: best1Rm,
          workoutId: best1RmWorkout!.id,
          exerciseSetId: best1RmSet.id,
          achievedAt: best1RmWorkout.date,
          computedAt: now,
        ),
      );
    }

    if (bestVolumeWorkout != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.maxVolumeWorkout,
          value: bestVolume,
          workoutId: bestVolumeWorkout.id,
          achievedAt: bestVolumeWorkout.date,
          computedAt: now,
        ),
      );
    }

    for (final MapEntry(key: weight, value: best) in repsAtWeight.entries) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.maxRepsAtWeight,
          keyValue: weight,
          value: best.set.actualReps!.toDouble(),
          workoutId: best.workout.id,
          exerciseSetId: best.set.id,
          achievedAt: best.workout.date,
          computedAt: now,
        ),
      );
    }

    return records;
  }

  /// TS 9: max distance, longest duration, best pace (sec/km, only among
  /// sets with distance >= 500m).
  List<PersonalRecord> _cardioRecords(
    String exerciseId,
    List<ExerciseHistoryEntry> history,
    DateTime now,
  ) {
    ExerciseSet? bestDistanceSet;
    Workout? bestDistanceWorkout;

    ExerciseSet? bestDurationSet;
    Workout? bestDurationWorkout;

    ExerciseSet? bestPaceSet;
    Workout? bestPaceWorkout;
    var bestPace = double.infinity;

    for (final entry in history) {
      for (final set in entry.sets.where((s) => s.isCompleted)) {
        final distance = set.actualDistanceM;
        final duration = set.actualDurationSec;

        if (distance != null &&
            (bestDistanceSet == null ||
                distance > bestDistanceSet.actualDistanceM!)) {
          bestDistanceSet = set;
          bestDistanceWorkout = entry.workout;
        }

        if (duration != null &&
            (bestDurationSet == null ||
                duration > bestDurationSet.actualDurationSec!)) {
          bestDurationSet = set;
          bestDurationWorkout = entry.workout;
        }

        if (distance != null && distance >= 500 && duration != null) {
          final pace = duration / (distance / 1000);
          if (pace < bestPace) {
            bestPace = pace;
            bestPaceSet = set;
            bestPaceWorkout = entry.workout;
          }
        }
      }
    }

    final records = <PersonalRecord>[];

    if (bestDistanceSet != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.maxDistance,
          value: bestDistanceSet.actualDistanceM!,
          workoutId: bestDistanceWorkout!.id,
          exerciseSetId: bestDistanceSet.id,
          achievedAt: bestDistanceWorkout.date,
          computedAt: now,
        ),
      );
    }

    if (bestDurationSet != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.longestDuration,
          value: bestDurationSet.actualDurationSec!.toDouble(),
          workoutId: bestDurationWorkout!.id,
          exerciseSetId: bestDurationSet.id,
          achievedAt: bestDurationWorkout.date,
          computedAt: now,
        ),
      );
    }

    if (bestPaceSet != null) {
      records.add(
        PersonalRecord(
          exerciseId: exerciseId,
          recordType: RecordType.bestPace,
          value: bestPace,
          workoutId: bestPaceWorkout!.id,
          exerciseSetId: bestPaceSet.id,
          achievedAt: bestPaceWorkout.date,
          computedAt: now,
        ),
      );
    }

    return records;
  }
}
