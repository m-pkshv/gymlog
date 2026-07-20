import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise_set.dart';

ExerciseSet _set({double? plannedWeightKg, double? actualWeightKg}) {
  final now = DateTime.utc(2026, 7, 20);
  return ExerciseSet(
    id: 's1',
    workoutExerciseId: 'we1',
    setNumber: 1,
    isWarmup: false,
    isCompleted: false,
    side: BodySide.none,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
    plannedWeightKg: plannedWeightKg,
    actualWeightKg: actualWeightKg,
  );
}

void main() {
  group('copyWith', () {
    test('omitting a param keeps its current value', () {
      final set = _set(plannedWeightKg: 100);
      final updated = set.copyWith(plannedReps: 5);

      expect(updated.plannedWeightKg, 100);
      expect(updated.plannedReps, 5);
    });

    test('explicitly passing null clears the field (editor backspace)', () {
      final set = _set(plannedWeightKg: 100);
      final updated = set.copyWith(plannedWeightKg: null);

      expect(updated.plannedWeightKg, isNull);
    });

    test('passing a new value overwrites the old one', () {
      final set = _set(plannedWeightKg: 100);
      final updated = set.copyWith(plannedWeightKg: 120);

      expect(updated.plannedWeightKg, 120);
    });
  });

  group('markCompleted (DM 6.7)', () {
    test('copies planned into empty actual fields', () {
      final set = _set().copyWith(
        plannedWeightKg: 80,
        plannedReps: 8,
        isWarmup: false,
      );

      final completed = set.markCompleted();

      expect(completed.isCompleted, isTrue);
      expect(completed.actualWeightKg, 80);
      expect(completed.actualReps, 8);
    });

    test('does not overwrite an already-filled actual value', () {
      final set = _set(plannedWeightKg: 80, actualWeightKg: 75);

      final completed = set.markCompleted();

      expect(completed.actualWeightKg, 75);
    });

    test('unmarking leaves the copied actual values in place', () {
      final completed = _set(
        plannedWeightKg: 80,
      ).markCompleted().copyWith(isCompleted: false);

      expect(completed.isCompleted, isFalse);
      expect(completed.actualWeightKg, 80);
    });
  });
}
