import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise_history_entry.dart';
import 'package:gymlog/domain/models/exercise_set.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/features/stats/exercise_progress_series.dart';

Workout _workout(DateTime date) {
  return Workout(
    id: 'w-${date.toIso8601String()}',
    date: date,
    status: WorkoutStatus.completed,
    createdAt: date,
    updatedAt: date,
    isDeleted: false,
  );
}

ExerciseSet _set({
  required bool isWarmup,
  required bool isCompleted,
  double? actualWeightKg,
  int? actualReps,
  double? actualDistanceM,
  int? actualDurationSec,
}) {
  return ExerciseSet(
    id: 's-${identityHashCode(actualWeightKg)}-${identityHashCode(actualReps)}',
    workoutExerciseId: 'we',
    setNumber: 1,
    isWarmup: isWarmup,
    isCompleted: isCompleted,
    side: BodySide.none,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    isDeleted: false,
    actualWeightKg: actualWeightKg,
    actualReps: actualReps,
    actualDistanceM: actualDistanceM,
    actualDurationSec: actualDurationSec,
  );
}

void main() {
  group('maxWeightSeries', () {
    test('one point per workout, oldest first, max weight among working '
        'completed sets', () {
      final history = [
        // Newest first, as getExerciseHistory returns it.
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 15)),
          sets: [
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 100, actualReps: 5),
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 110, actualReps: 3),
          ],
        ),
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: true, isCompleted: true, actualWeightKg: 40, actualReps: 10),
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 90, actualReps: 5),
          ],
        ),
      ];

      final points = maxWeightSeries(history);

      expect(points, hasLength(2));
      expect(points[0].date, DateTime(2026, 7, 1));
      expect(points[0].value, 90); // warmup excluded
      expect(points[1].date, DateTime(2026, 7, 15));
      expect(points[1].value, 110);
    });

    test('a workout with no completed working set is skipped, not zeroed', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [_set(isWarmup: false, isCompleted: false, actualWeightKg: 90, actualReps: 5)],
        ),
      ];

      expect(maxWeightSeries(history), isEmpty);
    });
  });

  group('oneRepMaxSeries (Epley, D-6 domain reps 1-12/weight>0)', () {
    test('picks the best in-domain set per workout', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            // 100 * (1 + 5/30) = 116.666...
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 100, actualReps: 5),
            // 90 * (1 + 8/30) = 114
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 90, actualReps: 8),
          ],
        ),
      ];

      final points = oneRepMaxSeries(history);
      expect(points, hasLength(1));
      expect(points.single.value, closeTo(116.666, 0.01));
    });

    test('reps outside 1-12 are excluded from the estimate', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 100, actualReps: 20),
          ],
        ),
      ];

      expect(oneRepMaxSeries(history), isEmpty);
    });
  });

  group('tonnageSeries (TS 9: Σ weight×reps per workout)', () {
    test('sums working completed sets; warmup and uncompleted excluded', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: true, isCompleted: true, actualWeightKg: 20, actualReps: 10),
            _set(isWarmup: false, isCompleted: true, actualWeightKg: 100, actualReps: 5),
            _set(isWarmup: false, isCompleted: false, actualWeightKg: 100, actualReps: 5),
          ],
        ),
      ];

      expect(tonnageSeries(history).single.value, 500.0);
    });

    test(
      'a working completed set without a weight (reps-type) contributes 0, '
      'the workout is still plotted at 0.0 -- not skipped',
      () {
        final history = [
          ExerciseHistoryEntry(
            workout: _workout(DateTime(2026, 7, 1)),
            sets: [_set(isWarmup: false, isCompleted: true, actualReps: 20)],
          ),
        ];

        final points = tonnageSeries(history);
        expect(points, hasLength(1));
        expect(points.single.value, 0.0);
      },
    );
  });

  group('cardio series (maxDistance/longestDuration/bestPace)', () {
    test('maxDistanceSeries takes the max distance per workout', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 3000, actualDurationSec: 900),
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 5000, actualDurationSec: 1500),
          ],
        ),
      ];

      expect(maxDistanceSeries(history).single.value, 5000.0);
    });

    test('longestDurationSeries takes the max duration per workout', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 3000, actualDurationSec: 900),
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 1000, actualDurationSec: 1800),
          ],
        ),
      ];

      expect(longestDurationSeries(history).single.value, 1800.0);
    });

    test('bestPaceSeries only considers sets with distance >= 500m', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            // 400m in 100s would be a very fast (and excluded) pace.
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 400, actualDurationSec: 100),
            // 5000m in 1500s = 300 s/km.
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 5000, actualDurationSec: 1500),
          ],
        ),
      ];

      expect(bestPaceSeries(history).single.value, 300.0);
    });

    test('a workout with no set of distance >= 500m is skipped for pace', () {
      final history = [
        ExerciseHistoryEntry(
          workout: _workout(DateTime(2026, 7, 1)),
          sets: [
            _set(isWarmup: false, isCompleted: true, actualDistanceM: 400, actualDurationSec: 100),
          ],
        ),
      ];

      expect(bestPaceSeries(history), isEmpty);
    });
  });
}
