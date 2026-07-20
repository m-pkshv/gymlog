import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/logger.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/workout_editor/controller.dart';
import 'package:gymlog/services/workout_service.dart';

/// Controller-level tests for the autosave guarantee (03_TECHNICAL_SPEC.md,
/// section 5), exercised directly against a real in-memory database rather
/// than through the full widget tree -- `WorkoutEditorScreen`'s
/// `didChangeAppLifecycleState` is a one-line pass-through to
/// [WorkoutEditorController.flushAll], so this is exactly what fires when
/// the OS is about to reclaim a backgrounded process.
void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late WorkoutService service;
  late AppLogger logger;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    service = WorkoutService(workouts);
    logger = AppLogger();
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'flushAll writes a pending debounced edit immediately -- the '
    'kill-process guarantee behind AppLifecycleState.paused',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
        isWarmup: false,
      );

      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        logger,
      );
      addTearDown(controller.dispose);
      // Let the constructor's initial load complete.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      controller.editSet(
        set.id,
        (current) => current.copyWith(plannedWeightKg: 55),
      );

      var stored = await workouts.getDetails(workout.id);
      expect(
        stored!.exercises.single.sets.single.plannedWeightKg,
        isNull,
        reason: 'debounce has not fired yet',
      );

      // What the screen calls from didChangeAppLifecycleState(paused).
      await controller.flushAll();

      stored = await workouts.getDetails(workout.id);
      expect(stored!.exercises.single.sets.single.plannedWeightKg, 55.0);
    },
  );

  test('dispose() flushes any still-pending debounced edit on screen exit', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );
    final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
    final workoutExercise = await workouts.addExercise(
      workoutId: workout.id,
      exerciseId: exercise.id,
    );
    final set = await workouts.addSet(
      workoutExerciseId: workoutExercise.id,
      isWarmup: false,
    );

    final controller = WorkoutEditorController(
      workout.id,
      workouts,
      service,
      logger,
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));

    controller.editSet(
      set.id,
      (current) => current.copyWith(plannedWeightKg: 33),
    );
    controller.dispose();
    // dispose() fires the write and forgets it (the notifier is gone by
    // the time it lands); give it a moment to actually land.
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final stored = await workouts.getDetails(workout.id);
    expect(stored!.exercises.single.sets.single.plannedWeightKg, 33.0);
  });

  group('copyLastPerformance (S-03, TS 8 section 8)', () {
    test('returns false when the exercise has no completed history', () async {
      final exercise = await exercises.create(
        name: 'Bench Press',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );

      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final copied = await controller.copyLastPerformance(workoutExercise.id);

      expect(copied, isFalse);
    });

    test(
      'copies actuals into planned matched by set order, appends missing '
      'sets, and leaves extra current sets untouched',
      () async {
        final exercise = await exercises.create(
          name: 'Bench Press',
          exerciseType: ExerciseType.strength,
        );

        // A past, completed occurrence with 3 logged sets.
        final pastWorkout = await workouts.createDraft(
          date: DateTime(2026, 7, 10),
        );
        final pastWorkoutExercise = await workouts.addExercise(
          workoutId: pastWorkout.id,
          exerciseId: exercise.id,
        );
        const pastValues = [(60.0, 8), (65.0, 6), (70.0, 4)];
        for (final (weight, reps) in pastValues) {
          final set = await workouts.addSet(
            workoutExerciseId: pastWorkoutExercise.id,
            isWarmup: false,
          );
          await workouts.updateSet(
            set.copyWith(actualWeightKg: weight, actualReps: reps),
          );
        }
        await (db.update(
          db.workouts,
        )..where((w) => w.id.equals(pastWorkout.id))).write(
          WorkoutsCompanion(status: Value(WorkoutStatus.completed.name)),
        );

        // Today's workout: only 2 sets already added (fewer than history),
        // plus one extra set that history has nothing to say about.
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final workoutExercise = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set1 = await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
          isWarmup: false,
        );
        final set2 = await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
          isWarmup: false,
        );

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final copied = await controller.copyLastPerformance(
          workoutExercise.id,
        );
        expect(copied, isTrue);

        final stored = await workouts.getDetails(workout.id);
        final sets = stored!.exercises.single.sets
          ..sort((a, b) => a.setNumber.compareTo(b.setNumber));

        expect(sets, hasLength(3), reason: 'the missing 3rd set was appended');
        expect(sets[0].id, set1.id);
        expect(sets[0].plannedWeightKg, 60.0);
        expect(sets[0].plannedReps, 8);
        expect(sets[1].id, set2.id);
        expect(sets[1].plannedWeightKg, 65.0);
        expect(sets[1].plannedReps, 6);
        expect(sets[2].plannedWeightKg, 70.0);
        expect(sets[2].plannedReps, 4);
        expect(
          sets.every((s) => s.actualWeightKg == null),
          isTrue,
          reason: 'only planned values are set, never actuals',
        );
      },
    );

    test(
      'leaves an extra current set untouched when history has fewer sets',
      () async {
        final exercise = await exercises.create(
          name: 'Bench Press',
          exerciseType: ExerciseType.strength,
        );

        final pastWorkout = await workouts.createDraft(
          date: DateTime(2026, 7, 10),
        );
        final pastWorkoutExercise = await workouts.addExercise(
          workoutId: pastWorkout.id,
          exerciseId: exercise.id,
        );
        final pastSet = await workouts.addSet(
          workoutExerciseId: pastWorkoutExercise.id,
          isWarmup: false,
        );
        await workouts.updateSet(
          pastSet.copyWith(actualWeightKg: 50.0, actualReps: 10),
        );
        await (db.update(
          db.workouts,
        )..where((w) => w.id.equals(pastWorkout.id))).write(
          WorkoutsCompanion(status: Value(WorkoutStatus.completed.name)),
        );

        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final workoutExercise = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set1 = await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
          isWarmup: false,
        );
        final set2 = await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
          isWarmup: false,
        );
        await workouts.updateSet(set2.copyWith(plannedWeightKg: 99.0));

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.copyLastPerformance(workoutExercise.id);

        final stored = await workouts.getDetails(workout.id);
        final sets = stored!.exercises.single.sets
          ..sort((a, b) => a.setNumber.compareTo(b.setNumber));

        expect(sets, hasLength(2), reason: 'no set was added or removed');
        expect(sets[0].id, set1.id);
        expect(sets[0].plannedWeightKg, 50.0);
        expect(
          sets[1].plannedWeightKg,
          99.0,
          reason: 'the extra current set is left exactly as it was',
        );
      },
    );
  });

  group('changeStatus (S-03, DM 6.4.1 full status menu)', () {
    test('applies any allowed transition, not just start/finish', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // draft -> planned ("Запланировать") isn't reachable via start()/
      // finish() in the old Stage 1 UI -- exercising it here locks in that
      // the controller now delegates the full DM 6.4.1 table.
      final result = await controller.changeStatus(WorkoutStatus.planned);

      expect(result.isOk, isTrue);
      final stored = await workouts.getDetails(workout.id);
      expect(stored!.workout.status, WorkoutStatus.planned);
    });

    test('rejects a transition workout_service doesn\'t allow', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // draft -> completed is not on WorkoutService.allowedTransitions.
      final result = await controller.changeStatus(WorkoutStatus.completed);

      expect(result.isErr, isTrue);
      final stored = await workouts.getDetails(workout.id);
      expect(stored!.workout.status, WorkoutStatus.draft);
    });
  });

  group('moveDate (S-03, DM 6.4.1: allowed in any status but inProgress)', () {
    test('updates the workout date and local state', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 10));
      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.moveDate(DateTime(2026, 7, 25));

      expect(
        controller.state.value!.workout.date,
        DateTime(2026, 7, 25),
        reason: 'local state updates immediately, no reload needed',
      );
      final stored = await workouts.getDetails(workout.id);
      expect(stored!.workout.date, DateTime(2026, 7, 25));
    });
  });
}
