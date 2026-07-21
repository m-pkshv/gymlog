import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/active_workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/models/active_workout_state.dart';
import 'package:gymlog/services/active_workout_timer_service.dart';

void main() {
  group('elapsedSeconds (pure formula, TS 7.1)', () {
    late drift.AppDatabase db;
    late ActiveWorkoutTimerService service;

    setUp(() {
      db = drift.AppDatabase(NativeDatabase.memory());
      service = ActiveWorkoutTimerService(ActiveWorkoutRepositoryImpl(db));
    });

    tearDown(() async {
      await db.close();
    });

    test('not paused: accumulated + (now - startedAtUtc)', () {
      final startedAt = DateTime.utc(2026, 7, 21, 10, 0, 0);
      final now = DateTime.utc(2026, 7, 21, 10, 5, 0);
      final state = ActiveWorkoutState(
        workoutId: 'w1',
        startedAtUtc: startedAt,
        accumulatedActiveSec: 100,
        updatedAt: startedAt,
      );

      expect(service.elapsedSeconds(state, now: now), 100 + 300);
    });

    test('paused: ignores the running segment entirely', () {
      final startedAt = DateTime.utc(2026, 7, 21, 10, 0, 0);
      final now = DateTime.utc(2026, 7, 21, 10, 5, 0);
      final state = ActiveWorkoutState(
        workoutId: 'w1',
        startedAtUtc: startedAt,
        accumulatedActiveSec: 100,
        isPaused: true,
        updatedAt: startedAt,
      );

      expect(service.elapsedSeconds(state, now: now), 100);
    });
  });

  group('against a real database', () {
    late drift.AppDatabase db;
    late ActiveWorkoutRepositoryImpl repository;
    late ActiveWorkoutTimerService service;
    late WorkoutRepositoryImpl workouts;
    late String workoutId;

    setUp(() async {
      db = drift.AppDatabase(NativeDatabase.memory());
      repository = ActiveWorkoutRepositoryImpl(db);
      service = ActiveWorkoutTimerService(repository);
      workouts = WorkoutRepositoryImpl(db);
      workoutId = (await workouts.createDraft(date: DateTime(2026, 7, 21))).id;
    });

    tearDown(() async {
      await db.close();
    });

    test('start creates a fresh, unpaused state at zero accumulated seconds', () async {
      await service.start(workoutId);

      final state = await repository.getByWorkoutId(workoutId);
      expect(state, isNotNull);
      expect(state!.accumulatedActiveSec, 0);
      expect(state.isPaused, isFalse);
      expect(state.pauseStartedAtUtc, isNull);
    });

    test(
      'resumeCompleted seeds accumulatedActiveSec with the prior duration '
      '(owner-confirmed 2026-07-21: time already logged is kept, not reset)',
      () async {
        await service.resumeCompleted(workoutId, priorDurationSec: 2700);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.accumulatedActiveSec, 2700);
        expect(state.isPaused, isFalse);
      },
    );

    test(
      'pause freezes the running segment into accumulatedActiveSec and marks paused',
      () async {
        final startedAt = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
        await repository.upsert(
          ActiveWorkoutState(workoutId: workoutId, startedAtUtc: startedAt, updatedAt: startedAt),
        );

        await service.pause(workoutId);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.isPaused, isTrue);
        expect(state.pauseStartedAtUtc, isNotNull);
        // ~5 minutes (300s) elapsed since startedAtUtc; generous slack for
        // test execution overhead.
        expect(state.accumulatedActiveSec, greaterThanOrEqualTo(299));
        expect(state.accumulatedActiveSec, lessThan(310));
      },
    );

    test('pause is a no-op when already paused', () async {
      final anchor = DateTime.utc(2026, 7, 21, 9);
      await repository.upsert(
        ActiveWorkoutState(
          workoutId: workoutId,
          startedAtUtc: anchor,
          accumulatedActiveSec: 123,
          isPaused: true,
          updatedAt: anchor,
        ),
      );

      await service.pause(workoutId);

      final state = await repository.getByWorkoutId(workoutId);
      expect(state!.accumulatedActiveSec, 123); // untouched
    });

    test('pause is a no-op when there is no active state', () async {
      await service.pause(workoutId);
      expect(await repository.getByWorkoutId(workoutId), isNull);
    });

    test('resume clears isPaused and resets the running-segment anchor', () async {
      final pausedAt = DateTime.utc(2026, 7, 21, 9);
      await repository.upsert(
        ActiveWorkoutState(
          workoutId: workoutId,
          startedAtUtc: pausedAt,
          accumulatedActiveSec: 60,
          isPaused: true,
          pauseStartedAtUtc: pausedAt,
          updatedAt: pausedAt,
        ),
      );

      await service.resume(workoutId);

      final state = await repository.getByWorkoutId(workoutId);
      expect(state!.isPaused, isFalse);
      expect(state.pauseStartedAtUtc, isNull);
      expect(state.accumulatedActiveSec, 60); // preserved, not reset
      // The anchor is reset to (approximately) now, not left at pausedAt.
      expect(
        DateTime.now().toUtc().difference(state.startedAtUtc).inSeconds.abs(),
        lessThan(5),
      );
    });

    test('resume is a no-op when not paused', () async {
      await service.start(workoutId);
      final before = await repository.getByWorkoutId(workoutId);

      await service.resume(workoutId);

      final after = await repository.getByWorkoutId(workoutId);
      expect(after!.startedAtUtc, before!.startedAtUtc);
    });

    test('finish returns the elapsed seconds and removes the row', () async {
      final startedAt = DateTime.utc(2026, 7, 21, 9);
      await repository.upsert(
        ActiveWorkoutState(
          workoutId: workoutId,
          startedAtUtc: startedAt,
          accumulatedActiveSec: 500,
          isPaused: true, // paused, so elapsed == accumulated exactly
          updatedAt: startedAt,
        ),
      );

      final elapsed = await service.finish(workoutId);

      expect(elapsed, 500);
      expect(await repository.getByWorkoutId(workoutId), isNull);
    });

    test('finish returns 0 when there is no active state', () async {
      final elapsed = await service.finish(workoutId);
      expect(elapsed, 0);
    });

    group('rest timer (TS 7.2 step 2)', () {
      test('startRestTimer sets a fresh endsAt/durationSec pair', () async {
        await service.start(workoutId);

        await service.startRestTimer(workoutId, durationSec: 90);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.restTimerDurationSec, 90);
        final remaining = service.remainingRestSeconds(state)!;
        expect(remaining, greaterThan(85));
        expect(remaining, lessThanOrEqualTo(90));
      });

      test('startRestTimer is a no-op when there is no active workout timer', () async {
        await service.startRestTimer(workoutId, durationSec: 90);
        expect(await repository.getByWorkoutId(workoutId), isNull);
      });

      test('adjustRestTimer extends the remaining time by deltaSec', () async {
        final now = DateTime.now().toUtc();
        await repository.upsert(
          ActiveWorkoutState(
            workoutId: workoutId,
            startedAtUtc: now,
            restTimerEndsAtUtc: now.add(const Duration(seconds: 60)),
            restTimerDurationSec: 60,
            updatedAt: now,
          ),
        );

        await service.adjustRestTimer(workoutId, deltaSec: 15);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.restTimerDurationSec, 75);
        expect(
          state.restTimerEndsAtUtc!.difference(now).inSeconds,
          75,
        );
      });

      test('adjustRestTimer shortens the remaining time for a negative deltaSec', () async {
        final now = DateTime.now().toUtc();
        await repository.upsert(
          ActiveWorkoutState(
            workoutId: workoutId,
            startedAtUtc: now,
            restTimerEndsAtUtc: now.add(const Duration(seconds: 60)),
            restTimerDurationSec: 60,
            updatedAt: now,
          ),
        );

        await service.adjustRestTimer(workoutId, deltaSec: -15);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.restTimerDurationSec, 45);
      });

      test('adjustRestTimer is a no-op when no rest timer is running', () async {
        await service.start(workoutId);

        await service.adjustRestTimer(workoutId, deltaSec: 15);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.restTimerEndsAtUtc, isNull);
      });

      test('skipRestTimer clears the rest timer fields', () async {
        final now = DateTime.now().toUtc();
        await repository.upsert(
          ActiveWorkoutState(
            workoutId: workoutId,
            startedAtUtc: now,
            restTimerEndsAtUtc: now.add(const Duration(seconds: 60)),
            restTimerDurationSec: 60,
            updatedAt: now,
          ),
        );

        await service.skipRestTimer(workoutId);

        final state = await repository.getByWorkoutId(workoutId);
        expect(state!.restTimerEndsAtUtc, isNull);
        expect(state.restTimerDurationSec, isNull);
      });

      test('remainingRestSeconds is null when no rest timer is running', () async {
        await service.start(workoutId);
        final state = await repository.getByWorkoutId(workoutId);

        expect(service.remainingRestSeconds(state!), isNull);
      });

      test('remainingRestSeconds is negative once expired (TS 7.1)', () {
        final now = DateTime.utc(2026, 7, 21, 10, 0, 0);
        final state = ActiveWorkoutState(
          workoutId: workoutId,
          startedAtUtc: now,
          restTimerEndsAtUtc: now.subtract(const Duration(seconds: 5)),
          restTimerDurationSec: 60,
          updatedAt: now,
        );

        expect(service.remainingRestSeconds(state, now: now), -5);
      });
    });
  });
}
