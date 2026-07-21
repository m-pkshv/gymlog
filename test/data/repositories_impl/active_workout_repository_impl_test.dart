import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/active_workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/models/active_workout_state.dart';

void main() {
  late drift.AppDatabase db;
  late ActiveWorkoutRepositoryImpl repository;
  late WorkoutRepositoryImpl workouts;
  late String workoutId;

  setUp(() async {
    db = drift.AppDatabase(NativeDatabase.memory());
    repository = ActiveWorkoutRepositoryImpl(db);
    workouts = WorkoutRepositoryImpl(db);
    workoutId = (await workouts.createDraft(date: DateTime(2026, 7, 21))).id;
  });

  tearDown(() async {
    await db.close();
  });

  test('getByWorkoutId returns null when there is no row (DM 6.14)', () async {
    expect(await repository.getByWorkoutId(workoutId), isNull);
  });

  test('upsert then getByWorkoutId round-trips all fields', () async {
    final now = DateTime.utc(2026, 7, 21, 10);
    final pauseStart = DateTime.utc(2026, 7, 21, 10, 5);
    final restEnds = DateTime.utc(2026, 7, 21, 10, 6, 30);
    await repository.upsert(
      ActiveWorkoutState(
        workoutId: workoutId,
        startedAtUtc: now,
        accumulatedActiveSec: 42,
        isPaused: true,
        pauseStartedAtUtc: pauseStart,
        restTimerEndsAtUtc: restEnds,
        restTimerDurationSec: 90,
        updatedAt: now,
      ),
    );

    final state = await repository.getByWorkoutId(workoutId);
    expect(state, isNotNull);
    expect(state!.startedAtUtc, now);
    expect(state.accumulatedActiveSec, 42);
    expect(state.isPaused, isTrue);
    expect(state.pauseStartedAtUtc, pauseStart);
    expect(state.restTimerEndsAtUtc, restEnds);
    expect(state.restTimerDurationSec, 90);
  });

  test('upsert on an existing row overwrites it in place (single row per workout)', () async {
    final first = DateTime.utc(2026, 7, 21, 10);
    await repository.upsert(
      ActiveWorkoutState(workoutId: workoutId, startedAtUtc: first, updatedAt: first),
    );
    final second = DateTime.utc(2026, 7, 21, 11);
    await repository.upsert(
      ActiveWorkoutState(
        workoutId: workoutId,
        startedAtUtc: second,
        accumulatedActiveSec: 300,
        updatedAt: second,
      ),
    );

    final state = await repository.getByWorkoutId(workoutId);
    expect(state!.startedAtUtc, second);
    expect(state.accumulatedActiveSec, 300);
  });

  test('watch emits the current row and updates after upsert', () async {
    expect(await repository.watch(workoutId).first, isNull);

    final now = DateTime.utc(2026, 7, 21, 10);
    await repository.upsert(
      ActiveWorkoutState(workoutId: workoutId, startedAtUtc: now, updatedAt: now),
    );

    final emitted = await repository.watch(workoutId).first;
    expect(emitted, isNotNull);
    expect(emitted!.workoutId, workoutId);
  });

  test('delete removes the row', () async {
    final now = DateTime.utc(2026, 7, 21, 10);
    await repository.upsert(
      ActiveWorkoutState(workoutId: workoutId, startedAtUtc: now, updatedAt: now),
    );

    await repository.delete(workoutId);

    expect(await repository.getByWorkoutId(workoutId), isNull);
  });
}
