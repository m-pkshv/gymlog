import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart' hide PersonalRecord;
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/personal_record_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/personal_record.dart';

void main() {
  late AppDatabase db;
  late PersonalRecordRepositoryImpl records;
  late String exerciseId;
  late String workoutId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    records = PersonalRecordRepositoryImpl(db);
    final exercise = await ExerciseRepositoryImpl(
      db,
    ).create(name: 'Squat', exerciseType: ExerciseType.strength);
    exerciseId = exercise.id;
    final workout = await WorkoutRepositoryImpl(
      db,
    ).createDraft(date: DateTime(2026, 7, 1));
    workoutId = workout.id;
  });

  tearDown(() async {
    await db.close();
  });

  PersonalRecord record({
    RecordType recordType = RecordType.maxWeight,
    double? keyValue,
    double value = 100,
  }) {
    final now = DateTime.now().toUtc();
    return PersonalRecord(
      exerciseId: exerciseId,
      recordType: recordType,
      keyValue: keyValue,
      value: value,
      workoutId: workoutId,
      achievedAt: DateTime(2026, 7, 1),
      computedAt: now,
    );
  }

  test('watchForExercise is empty before anything is computed', () async {
    expect(await records.watchForExercise(exerciseId).first, isEmpty);
  });

  test('replaceForExercise inserts records readable back via watch', () async {
    await records.replaceForExercise(exerciseId, [
      record(recordType: RecordType.maxWeight, value: 120),
      record(recordType: RecordType.max1RM, value: 140),
    ]);

    final stored = await records.watchForExercise(exerciseId).first;
    expect(stored, hasLength(2));
    expect(
      stored.map((r) => r.recordType),
      containsAll([RecordType.maxWeight, RecordType.max1RM]),
    );
  });

  test(
    'maxRepsAtWeight can have multiple rows for the same exercise, keyed '
    'by weight',
    () async {
      await records.replaceForExercise(exerciseId, [
        record(recordType: RecordType.maxRepsAtWeight, keyValue: 60, value: 12),
        record(recordType: RecordType.maxRepsAtWeight, keyValue: 80, value: 8),
      ]);

      final stored = await records.watchForExercise(exerciseId).first;
      expect(stored, hasLength(2));
      expect(stored.map((r) => r.keyValue), containsAll([60, 80]));
    },
  );

  test(
    'replaceForExercise fully replaces the previous set -- stale records '
    'disappear',
    () async {
      await records.replaceForExercise(exerciseId, [
        record(recordType: RecordType.maxWeight, value: 100),
        record(recordType: RecordType.maxRepsAtWeight, keyValue: 60, value: 10),
      ]);

      // A recompute where the 60kg row is no longer valid (e.g. that set
      // was edited away) must remove it, not just add/update others.
      await records.replaceForExercise(exerciseId, [
        record(recordType: RecordType.maxWeight, value: 105),
      ]);

      final stored = await records.watchForExercise(exerciseId).first;
      expect(stored, hasLength(1));
      expect(stored.single.recordType, RecordType.maxWeight);
      expect(stored.single.value, 105);
    },
  );

  test('replaceForExercise only affects the given exercise', () async {
    final otherExercise = await ExerciseRepositoryImpl(
      db,
    ).create(name: 'Bench Press', exerciseType: ExerciseType.strength);

    await records.replaceForExercise(exerciseId, [
      record(recordType: RecordType.maxWeight, value: 100),
    ]);
    await records.replaceForExercise(otherExercise.id, [
      PersonalRecord(
        exerciseId: otherExercise.id,
        recordType: RecordType.maxWeight,
        value: 80,
        workoutId: workoutId,
        achievedAt: DateTime(2026, 7, 1),
        computedAt: DateTime.now().toUtc(),
      ),
    ]);

    expect(await records.watchForExercise(exerciseId).first, hasLength(1));
    expect(
      await records.watchForExercise(otherExercise.id).first,
      hasLength(1),
    );
  });
}
