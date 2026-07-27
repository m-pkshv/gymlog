import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/workout.dart';

Workout _workout({String? name, String? comment}) {
  final now = DateTime.utc(2026, 7, 27);
  return Workout(
    id: 'w1',
    date: DateTime.utc(2026, 7, 27),
    status: WorkoutStatus.draft,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
    name: name,
    comment: comment,
  );
}

void main() {
  group('copyWith', () {
    test('omitting name keeps its current value', () {
      final workout = _workout(name: 'Leg day');
      final updated = workout.copyWith(status: WorkoutStatus.planned);

      expect(updated.name, 'Leg day');
    });

    test(
      'explicitly passing null clears name (rename dialog cleared, '
      'Stage 10, owner-reported)',
      () {
        final workout = _workout(name: 'Leg day');
        final updated = workout.copyWith(name: null);

        expect(updated.name, isNull);
      },
    );

    test('passing a new name overwrites the old one', () {
      final workout = _workout(name: 'Leg day');
      final updated = workout.copyWith(name: 'Push day');

      expect(updated.name, 'Push day');
    });

    test('explicitly passing null clears comment the same way', () {
      final workout = _workout(comment: 'Felt strong');
      final updated = workout.copyWith(comment: null);

      expect(updated.comment, isNull);
    });
  });
}
