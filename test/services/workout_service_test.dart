import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/app_error.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/domain/models/workout.dart';
import 'package:gymlog/domain/models/workout_details.dart';
import 'package:gymlog/domain/models/workout_exercise.dart';
import 'package:gymlog/domain/repositories/workout_repository.dart';
import 'package:gymlog/services/active_workout_timer_service.dart';
import 'package:gymlog/services/progression_service.dart';
import 'package:gymlog/services/records_service.dart';
import 'package:gymlog/services/workout_service.dart';
import 'package:mocktail/mocktail.dart';

class MockWorkoutRepository extends Mock implements WorkoutRepository {}

class MockProgressionService extends Mock implements ProgressionService {}

class MockRecordsService extends Mock implements RecordsService {}

class MockActiveWorkoutTimerService extends Mock
    implements ActiveWorkoutTimerService {}

/// A `WorkoutDetails` fixture with one entry per id in [exerciseIds], no
/// sets -- enough for `WorkoutService`'s recompute-trigger wiring, which
/// only reads the exercise ids involved.
WorkoutDetails _detailsWith(String workoutId, List<String> exerciseIds) {
  final now = DateTime.utc(2026, 7, 19, 12);
  return WorkoutDetails(
    workout: Workout(
      id: workoutId,
      date: DateTime(2026, 7, 19),
      status: WorkoutStatus.completed,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    ),
    exercises: [
      for (final exerciseId in exerciseIds)
        WorkoutExerciseDetails(
          workoutExercise: WorkoutExercise(
            id: '${workoutId}_$exerciseId',
            workoutId: workoutId,
            exerciseId: exerciseId,
            orderIndex: 0,
            progressionDecision: ProgressionDecision.none,
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
          ),
          exercise: Exercise(
            id: exerciseId,
            name: exerciseId,
            exerciseType: ExerciseType.strength,
            effortMetric: EffortMetric.none,
            isBuiltIn: false,
            isArchived: false,
            secondaryMuscleGroupIds: const [],
            createdAt: now,
            updatedAt: now,
            isDeleted: false,
          ),
          sets: const [],
        ),
    ],
  );
}

Workout _workout({
  String id = 'w1',
  WorkoutStatus status = WorkoutStatus.draft,
  DateTime? startedAt,
  DateTime? finishedAt,
  int? actualDurationSec,
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
    actualDurationSec: actualDurationSec,
  );
}

void main() {
  late MockWorkoutRepository repository;
  late MockProgressionService progressionService;
  late MockRecordsService recordsService;
  late MockActiveWorkoutTimerService activeWorkoutTimerService;
  late WorkoutService service;

  setUpAll(() {
    registerFallbackValue(_workout());
  });

  setUp(() {
    repository = MockWorkoutRepository();
    progressionService = MockProgressionService();
    recordsService = MockRecordsService();
    activeWorkoutTimerService = MockActiveWorkoutTimerService();
    service = WorkoutService(
      repository,
      progressionService,
      recordsService,
      activeWorkoutTimerService,
    );
    when(() => repository.updateWorkout(any())).thenAnswer((_) async {});
    // No workout has exercises to recompute unless a test says otherwise.
    when(() => repository.getDetails(any())).thenAnswer((_) async => null);
    when(() => progressionService.recompute(any())).thenAnswer((_) async {});
    when(() => recordsService.recompute(any())).thenAnswer((_) async {});
    when(() => activeWorkoutTimerService.start(any())).thenAnswer((_) async {});
    when(
      () => activeWorkoutTimerService.resumeCompleted(
        any(),
        priorDurationSec: any(named: 'priorDurationSec'),
      ),
    ).thenAnswer((_) async {});
    // Default stub for tests that don't care about the exact elapsed value
    // -- the anchor-based calculation itself is unit-tested in
    // active_workout_timer_service_test.dart, not here.
    when(
      () => activeWorkoutTimerService.finish(any()),
    ).thenAnswer((_) async => 3600);
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
      'draft -> inProgress starts a fresh workout timer (TS 7.1), not a '
      'resume',
      () async {
        when(
          () => repository.getInProgressWorkout(),
        ).thenAnswer((_) async => null);
        final workout = _workout(status: WorkoutStatus.draft);

        await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        verify(() => activeWorkoutTimerService.start(workout.id)).called(1);
        verifyNever(
          () => activeWorkoutTimerService.resumeCompleted(
            any(),
            priorDurationSec: any(named: 'priorDurationSec'),
          ),
        );
      },
    );

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
        // TS 7.1: actualDurationSec comes from the workout timer (mocked to
        // return 3600 by default in setUp), not a naive finishedAt-startedAt
        // diff -- that's what makes paused stretches excluded.
        expect(updated.actualDurationSec, 3600);
        verify(() => activeWorkoutTimerService.finish(workout.id)).called(1);
      },
    );

    test(
      'inProgress -> cancelled cleans up the timer but does not set '
      'actualDurationSec',
      () async {
        final workout = _workout(status: WorkoutStatus.inProgress);

        final result = await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.cancelled,
        );

        final updated = result.getOrNull();
        expect(updated, isNotNull);
        expect(updated!.actualDurationSec, isNull);
        verify(() => activeWorkoutTimerService.finish(workout.id)).called(1);
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
        actualDurationSec: 1800,
      );

      final result = await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.inProgress,
      );

      expect(result.isOk, isTrue);
      verify(
        () => activeWorkoutTimerService.resumeCompleted(
          workout.id,
          priorDurationSec: 1800,
        ),
      ).called(1);
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

  group('progression/records recompute triggers (D-7/D-8, DM 6.10/6.11, TS 9.4/9)', () {
    test('completing a workout recomputes every exercise in it', () async {
      when(
        () => repository.getDetails('w1'),
      ).thenAnswer((_) async => _detailsWith('w1', ['squat', 'bench']));
      final workout = _workout(
        id: 'w1',
        status: WorkoutStatus.inProgress,
        startedAt: DateTime.utc(2026, 7, 19, 11),
      );

      await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.completed,
      );

      verify(() => progressionService.recompute('squat')).called(1);
      verify(() => progressionService.recompute('bench')).called(1);
      verify(() => recordsService.recompute('squat')).called(1);
      verify(() => recordsService.recompute('bench')).called(1);
    });

    test('resuming a completed workout also recomputes', () async {
      when(
        () => repository.getDetails('w1'),
      ).thenAnswer((_) async => _detailsWith('w1', ['squat']));
      when(
        () => repository.getInProgressWorkout(),
      ).thenAnswer((_) async => null);
      final workout = _workout(
        id: 'w1',
        status: WorkoutStatus.completed,
        finishedAt: DateTime.now().toUtc(),
      );

      await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.inProgress,
      );

      verify(() => progressionService.recompute('squat')).called(1);
      verify(() => recordsService.recompute('squat')).called(1);
    });

    test('a transition that is neither finishing nor resuming does not '
        'recompute', () async {
      final workout = _workout(status: WorkoutStatus.draft);

      await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.planned,
      );

      verifyNever(() => progressionService.recompute(any()));
      verifyNever(() => recordsService.recompute(any()));
      verifyNever(() => repository.getDetails(any()));
    });

    test('deleting a completed workout recomputes its exercises', () async {
      when(
        () => repository.getDetails('w1'),
      ).thenAnswer((_) async => _detailsWith('w1', ['squat']));
      when(() => repository.deleteWorkout(any())).thenAnswer((_) async {});
      final workout = _workout(id: 'w1', status: WorkoutStatus.completed);

      await service.delete(workout);

      verify(() => progressionService.recompute('squat')).called(1);
      verify(() => recordsService.recompute('squat')).called(1);
    });

    test('deleting a non-completed workout does not recompute', () async {
      when(() => repository.deleteWorkout(any())).thenAnswer((_) async {});
      final workout = _workout(status: WorkoutStatus.draft);

      await service.delete(workout);

      verifyNever(() => progressionService.recompute(any()));
      verifyNever(() => recordsService.recompute(any()));
      verifyNever(() => repository.getDetails(any()));
    });

    test('restoring a completed workout recomputes its exercises', () async {
      when(
        () => repository.restoreWorkout(any()),
      ).thenAnswer((_) async {});
      when(
        () => repository.getDetails('w1'),
      ).thenAnswer((_) async => _detailsWith('w1', ['squat']));

      await service.restore('w1');

      verify(() => progressionService.recompute('squat')).called(1);
      verify(() => recordsService.recompute('squat')).called(1);
    });

    test('restoring a workout that is still a draft does not recompute', () async {
      when(() => repository.restoreWorkout(any())).thenAnswer((_) async {});
      final draftDetails = _detailsWith('w1', ['squat']);
      when(() => repository.getDetails('w1')).thenAnswer(
        (_) async => WorkoutDetails(
          workout: draftDetails.workout.copyWith(status: WorkoutStatus.draft),
          exercises: draftDetails.exercises,
        ),
      );

      await service.restore('w1');

      verifyNever(() => progressionService.recompute(any()));
      verifyNever(() => recordsService.recompute(any()));
    });
  });
}
