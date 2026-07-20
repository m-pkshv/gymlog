import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/domain/repositories/workout_repository.dart';
import 'package:gymlog/services/workout_service.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

Workout _workout({
  String id = 'w1',
  WorkoutStatus status = WorkoutStatus.draft,
  DateTime? startedAt,
  DateTime? finishedAt,
}) {
  final now = DateTime.utc(2026, 7, 19, 12);
  return Workout(
    id: id,
    date: DateTime(2026, 7, 19),
    status: status,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
    startedAt: startedAt,
    finishedAt: finishedAt,
  );
}

void main() {
  late MockWorkoutRepository repository;
  late WorkoutService service;

  setUpAll(() {
    registerFallbackValue(_workout());
  });

  setUp(() {
    repository = MockWorkoutRepository();
    service = WorkoutService(repository);
    when(() => repository.updateWorkout(any())).thenAnswer((_) async {});
  });

  group('isTransitionAllowed (DM 6.4.1, full matrix)', () {
    const allowed = {
      WorkoutStatus.draft: {WorkoutStatus.planned, WorkoutStatus.inProgress},
      WorkoutStatus.planned: {
        WorkoutStatus.inProgress,
        WorkoutStatus.skipped,
        WorkoutStatus.cancelled,
        WorkoutStatus.draft,
      },
      WorkoutStatus.inProgress: {
        WorkoutStatus.completed,
        WorkoutStatus.cancelled,
      },
      WorkoutStatus.completed: {WorkoutStatus.inProgress},
      WorkoutStatus.skipped: {WorkoutStatus.planned},
      WorkoutStatus.cancelled: {WorkoutStatus.planned},
    };

    for (final from in WorkoutStatus.values) {
      for (final to in WorkoutStatus.values) {
        final expectedAllowed = allowed[from]?.contains(to) ?? false;
        test(
          '${from.name} -> ${to.name} is ${expectedAllowed ? 'allowed' : 'forbidden'}',
          () {
            expect(service.isTransitionAllowed(from, to), expectedAllowed);
          },
        );
      }
    }
  });

  group('changeStatus', () {
    test('rejects a transition not on the allowed list', () async {
      final workout = _workout(status: WorkoutStatus.draft);

      final result = await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.completed,
      );

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      verifyNever(() => repository.updateWorkout(any()));
    });

    test('draft -> inProgress sets startedAt and persists', () async {
      when(
        () => repository.getInProgressWorkout(),
      ).thenAnswer((_) async => null);
      final workout = _workout(status: WorkoutStatus.draft);

      final result = await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.inProgress,
      );

      final updated = result.getOrNull();
      expect(updated, isNotNull);
      expect(updated!.status, WorkoutStatus.inProgress);
      expect(updated.startedAt, isNotNull);
      verify(() => repository.updateWorkout(any())).called(1);
    });

    test(
      'rejects starting a second workout while one is already in progress (DM 6.4.1)',
      () async {
        final other = _workout(id: 'other', status: WorkoutStatus.inProgress);
        when(
          () => repository.getInProgressWorkout(),
        ).thenAnswer((_) async => other);
        final workout = _workout(status: WorkoutStatus.draft);

        final result = await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        expect(result.isErr, isTrue);
        verifyNever(() => repository.updateWorkout(any()));
      },
    );

    test(
      'inProgress -> completed sets finishedAt and actualDurationSec',
      () async {
        final startedAt = DateTime.utc(2026, 7, 19, 10);
        final workout = _workout(
          status: WorkoutStatus.inProgress,
          startedAt: startedAt,
        );

        final result = await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.completed,
        );

        final updated = result.getOrNull();
        expect(updated, isNotNull);
        expect(updated!.status, WorkoutStatus.completed);
        expect(updated.finishedAt, isNotNull);
        expect(updated.actualDurationSec, isNotNull);
        expect(updated.actualDurationSec, greaterThan(0));
      },
    );

    test('completed -> inProgress succeeds within the resume window', () async {
      when(
        () => repository.getInProgressWorkout(),
      ).thenAnswer((_) async => null);
      final recentlyFinished = DateTime.now().toUtc().subtract(
        const Duration(hours: 1),
      );
      final workout = _workout(
        status: WorkoutStatus.completed,
        startedAt: recentlyFinished.subtract(const Duration(minutes: 30)),
        finishedAt: recentlyFinished,
      );

      final result = await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.inProgress,
      );

      expect(result.isOk, isTrue);
    });

    test(
      'completed -> inProgress fails once the resume window has passed',
      () async {
        final longAgo = DateTime.now().toUtc().subtract(
          const Duration(hours: 25),
        );
        final workout = _workout(
          status: WorkoutStatus.completed,
          finishedAt: longAgo,
        );

        final result = await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        expect(result.isErr, isTrue);
        verifyNever(() => repository.updateWorkout(any()));
      },
    );
  });

  group('delete (S-02, DM 10)', () {
    test('rejects an inProgress workout without touching storage', () async {
      final workout = _workout(status: WorkoutStatus.inProgress);

      final result = await service.delete(workout);

      expect(result.isErr, isTrue);
      expect(result.errorOrNull(), isA<ValidationError>());
      verifyNever(() => repository.deleteWorkout(any()));
    });

    for (final status in [
      WorkoutStatus.draft,
      WorkoutStatus.planned,
      WorkoutStatus.completed,
      WorkoutStatus.skipped,
      WorkoutStatus.cancelled,
    ]) {
      test('deletes a ${status.name} workout', () async {
        when(() => repository.deleteWorkout(any())).thenAnswer((_) async {});
        final workout = _workout(status: status);

        final result = await service.delete(workout);

        expect(result.isOk, isTrue);
        verify(() => repository.deleteWorkout(workout.id)).called(1);
      });
    }
  });
}
