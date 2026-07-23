import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart' hide PersonalRecord;
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/personal_record_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/personal_record.dart';
import 'package:gymlog/services/records_service.dart';

typedef StrengthSet = ({double? weight, int? reps, bool isCompleted});
typedef CardioSet = ({double? distance, int? duration, bool isCompleted});

StrengthSet workingSet({double? weight, int? reps}) =>
    (weight: weight, reps: reps, isCompleted: true);
StrengthSet incompleteSet({double? weight, int? reps}) =>
    (weight: weight, reps: reps, isCompleted: false);

CardioSet cardioWorkingSet({double? distance, int? duration}) =>
    (distance: distance, duration: duration, isCompleted: true);

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late PersonalRecordRepositoryImpl records;
  late RecordsService service;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    records = PersonalRecordRepositoryImpl(db);
    service = RecordsService(workouts, exercises, records);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> completeStrengthWorkout(
    String exerciseId, {
    required DateTime date,
    required List<StrengthSet> sets,
  }) async {
    final workout = await workouts.createDraft(date: date);
    final we = await workouts.addExercise(
      workoutId: workout.id,
      exerciseId: exerciseId,
    );
    for (final s in sets) {
      final set = await workouts.addSet(workoutExerciseId: we.id);
      await workouts.updateSet(
        set.copyWith(
          isCompleted: s.isCompleted,
          actualWeightKg: s.weight,
          actualReps: s.reps,
        ),
      );
    }
    await workouts.updateWorkout(workout.copyWith(status: WorkoutStatus.completed));
  }

  Future<void> completeCardioWorkout(
    String exerciseId, {
    required DateTime date,
    required List<CardioSet> sets,
  }) async {
    final workout = await workouts.createDraft(date: date);
    final we = await workouts.addExercise(
      workoutId: workout.id,
      exerciseId: exerciseId,
    );
    for (final s in sets) {
      final set = await workouts.addSet(workoutExerciseId: we.id);
      await workouts.updateSet(
        set.copyWith(
          isCompleted: s.isCompleted,
          actualDistanceM: s.distance,
          actualDurationSec: s.duration,
        ),
      );
    }
    await workouts.updateWorkout(workout.copyWith(status: WorkoutStatus.completed));
  }

  PersonalRecord? find(List<PersonalRecord> list, RecordType type, {double? keyValue}) {
    for (final r in list) {
      if (r.recordType == type && r.keyValue == keyValue) return r;
    }
    return null;
  }

  test('an exercise with no completed occurrences gets no records', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );

    await service.recompute(exercise.id);

    expect(await records.watchForExercise(exercise.id).first, isEmpty);
  });

  group('strength/reps (TS 9)', () {
    test('maxWeight tracks the highest weight, ignoring incomplete sets', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 1),
        sets: [
          workingSet(weight: 80, reps: 5),
          incompleteSet(weight: 150, reps: 1), // unmarked -- excluded
        ],
      );
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 8),
        sets: [workingSet(weight: 90, reps: 5)],
      );

      await service.recompute(exercise.id);

      final all = await records.watchForExercise(exercise.id).first;
      final maxWeight = find(all, RecordType.maxWeight);
      expect(maxWeight, isNotNull);
      expect(maxWeight!.value, 90);
      expect(maxWeight.achievedAt, DateTime(2026, 7, 8));
    });

    test(
      'max1RM applies the Epley formula and excludes out-of-domain sets '
      '(D-6: reps outside 1-12, weight <= 0)',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        await completeStrengthWorkout(
          exercise.id,
          date: DateTime(2026, 7, 1),
          sets: [
            workingSet(weight: 100, reps: 5), // 1RM = 100*(1+5/30) = 116.667
            workingSet(weight: 40, reps: 20), // out of domain (reps > 12)
            workingSet(weight: 0, reps: 5), // out of domain (weight <= 0)
          ],
        );

        await service.recompute(exercise.id);

        final all = await records.watchForExercise(exercise.id).first;
        final oneRm = find(all, RecordType.max1RM);
        expect(oneRm, isNotNull);
        expect(oneRm!.value, closeTo(100 * (1 + 5 / 30), 1e-9));
      },
    );

    test('maxRepsAtWeight produces one record per distinct weight used', () async {
      final exercise = await exercises.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 1),
        sets: [
          workingSet(weight: 60, reps: 10),
          workingSet(weight: 80, reps: 5),
        ],
      );
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 8),
        sets: [workingSet(weight: 60, reps: 12)], // same weight, more reps
      );

      await service.recompute(exercise.id);

      final all = await records.watchForExercise(exercise.id).first;
      final at60 = find(all, RecordType.maxRepsAtWeight, keyValue: 60);
      final at80 = find(all, RecordType.maxRepsAtWeight, keyValue: 80);
      expect(at60!.value, 12);
      expect(at80!.value, 5);
    });

    test(
      'maxVolumeWorkout sums weight x reps per workout (reps without weight '
      'contribute 0) and keeps the highest-tonnage workout',
      () async {
        final exercise = await exercises.create(
          name: 'Leg Press',
          exerciseType: ExerciseType.reps,
        );
        await completeStrengthWorkout(
          exercise.id,
          date: DateTime(2026, 7, 1),
          sets: [
            workingSet(weight: 100, reps: 10), // 1000
            workingSet(weight: null, reps: 15), // reps without weight -> 0
          ],
        );
        await completeStrengthWorkout(
          exercise.id,
          date: DateTime(2026, 7, 8),
          sets: [
            workingSet(weight: 100, reps: 5), // 500
            workingSet(weight: 50, reps: 8), // 400 -> total 900
          ],
        );

        await service.recompute(exercise.id);

        final all = await records.watchForExercise(exercise.id).first;
        final volume = find(all, RecordType.maxVolumeWorkout);
        expect(volume!.value, 1000);
        expect(volume.achievedAt, DateTime(2026, 7, 1));
        expect(volume.exerciseSetId, isNull);
      },
    );
  });

  group('cardio (TS 9)', () {
    test('maxDistance and longestDuration track the best set independently', () async {
      final exercise = await exercises.create(
        name: 'Running',
        exerciseType: ExerciseType.cardio,
      );
      await completeCardioWorkout(
        exercise.id,
        date: DateTime(2026, 7, 1),
        sets: [cardioWorkingSet(distance: 5000, duration: 1800)],
      );
      await completeCardioWorkout(
        exercise.id,
        date: DateTime(2026, 7, 8),
        sets: [cardioWorkingSet(distance: 3000, duration: 2000)],
      );

      await service.recompute(exercise.id);

      final all = await records.watchForExercise(exercise.id).first;
      expect(find(all, RecordType.maxDistance)!.value, 5000);
      expect(find(all, RecordType.longestDuration)!.value, 2000);
    });

    test('bestPace only considers sets with distance >= 500m', () async {
      final exercise = await exercises.create(
        name: 'Running',
        exerciseType: ExerciseType.cardio,
      );
      await completeCardioWorkout(
        exercise.id,
        date: DateTime(2026, 7, 1),
        // 200m in 40s = very fast pace, but below the 500m floor -- excluded.
        sets: [cardioWorkingSet(distance: 200, duration: 40)],
      );
      await completeCardioWorkout(
        exercise.id,
        date: DateTime(2026, 7, 8),
        // 1000m in 300s = 300 sec/km.
        sets: [cardioWorkingSet(distance: 1000, duration: 300)],
      );

      await service.recompute(exercise.id);

      final all = await records.watchForExercise(exercise.id).first;
      final pace = find(all, RecordType.bestPace);
      expect(pace, isNotNull);
      expect(pace!.value, closeTo(300, 1e-9));
      expect(pace.achievedAt, DateTime(2026, 7, 8));
    });
  });

  test('time/stretch exercises get no records (not covered by S-10/TS 9)', () async {
    final exercise = await exercises.create(
      name: 'Plank',
      exerciseType: ExerciseType.stretch,
    );
    final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
    final we = await workouts.addExercise(
      workoutId: workout.id,
      exerciseId: exercise.id,
    );
    final set = await workouts.addSet(workoutExerciseId: we.id);
    await workouts.updateSet(set.copyWith(isCompleted: true, actualDurationSec: 60));
    await workouts.updateWorkout(workout.copyWith(status: WorkoutStatus.completed));

    await service.recompute(exercise.id);

    expect(await records.watchForExercise(exercise.id).first, isEmpty);
  });

  test(
    'recompute fully replaces the previous record set -- a record that is '
    'no longer the best disappears',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 1),
        sets: [workingSet(weight: 100, reps: 5)],
      );
      await service.recompute(exercise.id);
      expect(
        find(
          await records.watchForExercise(exercise.id).first,
          RecordType.maxWeight,
        )!.value,
        100,
      );

      // A second, heavier occurrence -- recompute must move the record, not
      // leave the old 100kg row sitting alongside a new one.
      await completeStrengthWorkout(
        exercise.id,
        date: DateTime(2026, 7, 8),
        sets: [workingSet(weight: 110, reps: 5)],
      );
      await service.recompute(exercise.id);

      final all = await records.watchForExercise(exercise.id).first;
      final maxWeightRecords = all.where((r) => r.recordType == RecordType.maxWeight);
      expect(maxWeightRecords, hasLength(1));
      expect(maxWeightRecords.single.value, 110);
    },
  );
}
