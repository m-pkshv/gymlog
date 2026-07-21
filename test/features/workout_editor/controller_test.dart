import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/logger.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/active_workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/personal_record_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/progression_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_tag_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/repositories/app_settings_repository.dart';
import 'package:gymlog/features/workout_editor/controller.dart';
import 'package:gymlog/services/active_workout_timer_service.dart';
import 'package:gymlog/services/progression_service.dart';
import 'package:gymlog/services/records_service.dart';
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
  late ProgressionService progressionService;
  late RecordsService recordsService;
  late ActiveWorkoutTimerService activeWorkoutTimerService;
  late AppSettingsRepository appSettingsRepository;
  late WorkoutService service;
  late AppLogger logger;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    progressionService = ProgressionService(
      workouts,
      exercises,
      ProgressionRepositoryImpl(db),
    );
    recordsService = RecordsService(
      workouts,
      exercises,
      PersonalRecordRepositoryImpl(db),
    );
    activeWorkoutTimerService = ActiveWorkoutTimerService(
      ActiveWorkoutRepositoryImpl(db),
    );
    appSettingsRepository = AppSettingsRepositoryImpl(db);
    await appSettingsRepository.ensureInitialized();
    service = WorkoutService(
      workouts,
      progressionService,
      recordsService,
      activeWorkoutTimerService,
    );
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
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
      progressionService,
      recordsService,
      activeWorkoutTimerService,
      appSettingsRepository,
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
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
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
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
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
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

    test(
      'preserves already-assigned tags in local state (regression: '
      'moveDate used to drop them from WorkoutDetails.tags)',
      () async {
        final tags = WorkoutTagRepositoryImpl(db);
        final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 10),
        );
        await workouts.setWorkoutTags(workoutId: workout.id, tagIds: [tag.id]);
        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.moveDate(DateTime(2026, 7, 25));

        expect(controller.state.value!.tags.map((t) => t.id), [tag.id]);
      },
    );
  });

  group('setTags (S-03, DM 6.3/6.5)', () {
    test('assigns tags and reloads local state', () async {
      final tags = WorkoutTagRepositoryImpl(db);
      final tag = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.setTags([tag.id]);

      expect(controller.state.value!.tags.map((t) => t.id), [tag.id]);
      final stored = await workouts.getDetails(workout.id);
      expect(stored!.tags.map((t) => t.id), [tag.id]);
    });
  });

  group(
    'reorderExercises / moveExercise (S-03, drag handle + "⋮ → Вверх/Вниз")',
    () {
      Future<(WorkoutEditorController, List<String>)> seedThreeExercises(
        AppDatabase db,
      ) async {
        final exercises = ExerciseRepositoryImpl(db);
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final ids = <String>[];
        for (var i = 0; i < 3; i++) {
          final we = await workouts.addExercise(
            workoutId: workout.id,
            exerciseId: exercise.id,
          );
          ids.add(we.id);
        }
        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return (controller, ids);
      }

      test(
        'reorderExercises updates local state immediately and persists',
        () async {
          final (controller, ids) = await seedThreeExercises(db);
          addTearDown(controller.dispose);

          final newOrder = [ids[2], ids[0], ids[1]];
          await controller.reorderExercises(newOrder);

          expect(
            controller.state.value!.exercises
                .map((e) => e.workoutExercise.id),
            newOrder,
            reason: 'local state updates immediately, no reload needed',
          );
          final stored = await workouts.getDetails(controller.state.value!.workout.id);
          expect(
            stored!.exercises.map((e) => e.workoutExercise.id),
            newOrder,
          );
        },
      );

      test('moveExercise(up: true) swaps with the previous exercise', () async {
        final (controller, ids) = await seedThreeExercises(db);
        addTearDown(controller.dispose);

        await controller.moveExercise(ids[1], up: true);

        expect(
          controller.state.value!.exercises.map((e) => e.workoutExercise.id),
          [ids[1], ids[0], ids[2]],
        );
      });

      test('moveExercise(up: false) swaps with the next exercise', () async {
        final (controller, ids) = await seedThreeExercises(db);
        addTearDown(controller.dispose);

        await controller.moveExercise(ids[1], up: false);

        expect(
          controller.state.value!.exercises.map((e) => e.workoutExercise.id),
          [ids[0], ids[2], ids[1]],
        );
      });

      test('moveExercise is a no-op at the top of the list', () async {
        final (controller, ids) = await seedThreeExercises(db);
        addTearDown(controller.dispose);

        await controller.moveExercise(ids[0], up: true);

        expect(
          controller.state.value!.exercises.map((e) => e.workoutExercise.id),
          ids,
        );
      });

      test('moveExercise is a no-op at the bottom of the list', () async {
        final (controller, ids) = await seedThreeExercises(db);
        addTearDown(controller.dispose);

        await controller.moveExercise(ids[2], up: false);

        expect(
          controller.state.value!.exercises.map((e) => e.workoutExercise.id),
          ids,
        );
      });
    },
  );

  group('comments (Stage 3, S-03)', () {
    test(
      'editWorkoutComment debounces the write, flushWorkoutComment writes '
      'immediately',
      () async {
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        controller.editWorkoutComment('Great session');
        expect(controller.state.value!.workout.comment, 'Great session');
        var stored = await workouts.getDetails(workout.id);
        expect(stored!.workout.comment, isNull, reason: 'not flushed yet');

        await controller.flushWorkoutComment();
        stored = await workouts.getDetails(workout.id);
        expect(stored!.workout.comment, 'Great session');
      },
    );

    test(
      'editExerciseComment debounces the write, flushExerciseComment '
      'writes immediately',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final workoutExercise = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        controller.editExerciseComment(workoutExercise.id, 'Felt heavy');
        expect(
          controller.state.value!.exercises.single.workoutExercise.comment,
          'Felt heavy',
        );
        var stored = await workouts.getDetails(workout.id);
        expect(
          stored!.exercises.single.workoutExercise.comment,
          isNull,
          reason: 'not flushed yet',
        );

        await controller.flushExerciseComment(workoutExercise.id);
        stored = await workouts.getDetails(workout.id);
        expect(stored!.exercises.single.workoutExercise.comment, 'Felt heavy');
      },
    );

    test('flushAll flushes pending workout and exercise comments', () async {
      final exercise = await exercises.create(
        name: 'Squat',
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      controller.editWorkoutComment('Workout note');
      controller.editExerciseComment(workoutExercise.id, 'Exercise note');
      await controller.flushAll();

      final stored = await workouts.getDetails(workout.id);
      expect(stored!.workout.comment, 'Workout note');
      expect(stored.exercises.single.workoutExercise.comment, 'Exercise note');
    });

    test(
      'dispose() flushes pending workout and exercise comments',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final workoutExercise = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        controller.editWorkoutComment('Workout note');
        controller.editExerciseComment(workoutExercise.id, 'Exercise note');
        controller.dispose();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final stored = await workouts.getDetails(workout.id);
        expect(stored!.workout.comment, 'Workout note');
        expect(
          stored.exercises.single.workoutExercise.comment,
          'Exercise note',
        );
      },
    );
  });

  group('setProgressionDecision (S-03, DM 6.11)', () {
    test('persists the decision immediately, no debounce', () async {
      final exercise = await exercises.create(
        name: 'Squat',
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
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.setProgressionDecision(
        workoutExercise.id,
        ProgressionDecision.increase,
      );

      expect(
        controller.state.value!.exercises.single.workoutExercise
            .progressionDecision,
        ProgressionDecision.increase,
      );
      final stored = await workouts.getDetails(workout.id);
      expect(
        stored!.exercises.single.workoutExercise.progressionDecision,
        ProgressionDecision.increase,
      );
    });
  });

  group('_recomputeIfCompleted (D-7, DM 6.10/6.11)', () {
    test(
      'flushing a set edit on an already-completed workout recomputes '
      'the stagnation counter',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final older = await workouts.createDraft(date: DateTime(2026, 7, 1));
        final olderWe = await workouts.addExercise(
          workoutId: older.id,
          exerciseId: exercise.id,
        );
        final olderSet = await workouts.addSet(
          workoutExerciseId: olderWe.id,
          isWarmup: false,
        );
        await workouts.updateSet(
          olderSet.copyWith(
            isCompleted: true,
            actualWeightKg: 60,
            actualReps: 8,
          ),
        );
        await workouts.updateWorkout(
          older.copyWith(status: WorkoutStatus.completed),
        );

        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 8),
        );
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,
          isWarmup: false,
        );
        await workouts.updateSet(
          set.copyWith(isCompleted: true, actualWeightKg: 60, actualReps: 8),
        );
        await workouts.updateWorkout(
          workout.copyWith(status: WorkoutStatus.completed),
        );
        // Both occurrences identical so far -> stagnationCount would be 1
        // once computed; but nothing has triggered a compute yet.

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Editing this completed workout's set (a heavier weight) is a
        // DM 6.10/6.11 trigger -- flushSet should recompute afterward.
        controller.editSet(
          set.id,
          (s) => s.copyWith(actualWeightKg: 65),
        );
        await controller.flushSet(set.id);

        final state = await ProgressionRepositoryImpl(
          db,
        ).watchState(exercise.id).first;
        expect(state, isNotNull, reason: 'recompute should have run');
        expect(state!.stagnationCount, 0, reason: '65kg > 60kg is growth');
      },
    );

    test('editing a set on a draft workout does not recompute', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final we = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(
        workoutExerciseId: we.id,
        isWarmup: false,
      );
      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      controller.editSet(set.id, (s) => s.copyWith(actualWeightKg: 60));
      await controller.flushSet(set.id);

      final state = await ProgressionRepositoryImpl(
        db,
      ).watchState(exercise.id).first;
      expect(state, isNull, reason: 'draft workouts are not completed yet');
    });
  });

  group('rest timer auto-start (Stage 4, TS 7.2 step 2)', () {
    test(
      'marking a set done starts the rest timer using the AppSettings default',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(date: DateTime(2026, 7, 21));
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,
          isWarmup: false,
        );
        await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.setCompleted(set.id, value: true);

        final activeState = await ActiveWorkoutRepositoryImpl(
          db,
        ).getByWorkoutId(workout.id);
        expect(activeState!.restTimerEndsAtUtc, isNotNull);
        expect(activeState.restTimerDurationSec, 120); // Q-4 default
      },
    );

    test('unchecking a set does not start the rest timer', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 21));
      final we = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(
        workoutExerciseId: we.id,
        isWarmup: false,
      );
      await service.changeStatus(
        workout: workout,
        newStatus: WorkoutStatus.inProgress,
      );

      final controller = WorkoutEditorController(
        workout.id,
        workouts,
        service,
        progressionService,
        recordsService,
        activeWorkoutTimerService,
        appSettingsRepository,
        logger,
      );
      addTearDown(controller.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await controller.setCompleted(set.id, value: false);

      final activeState = await ActiveWorkoutRepositoryImpl(
        db,
      ).getByWorkoutId(workout.id);
      expect(activeState!.restTimerEndsAtUtc, isNull);
    });

    test(
      'does not start the rest timer when AppSettings.restTimerAutoStart is off',
      () async {
        await (db.update(
          db.appSettingsTable,
        )..where((t) => t.id.equals('singleton'))).write(
          AppSettingsTableCompanion(restTimerAutoStart: Value(false)),
        );
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(date: DateTime(2026, 7, 21));
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,
          isWarmup: false,
        );
        await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await controller.setCompleted(set.id, value: true);

        final activeState = await ActiveWorkoutRepositoryImpl(
          db,
        ).getByWorkoutId(workout.id);
        expect(activeState!.restTimerEndsAtUtc, isNull);
      },
    );

    test(
      'adjustRestTimer/skipRestTimer delegate to ActiveWorkoutTimerService',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(date: DateTime(2026, 7, 21));
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,
          isWarmup: false,
        );
        await service.changeStatus(
          workout: workout,
          newStatus: WorkoutStatus.inProgress,
        );

        final controller = WorkoutEditorController(
          workout.id,
          workouts,
          service,
          progressionService,
          recordsService,
          activeWorkoutTimerService,
          appSettingsRepository,
          logger,
        );
        addTearDown(controller.dispose);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await controller.setCompleted(set.id, value: true);

        final repository = ActiveWorkoutRepositoryImpl(db);
        final before = await repository.getByWorkoutId(workout.id);
        expect(before!.restTimerDurationSec, 120);

        await controller.adjustRestTimer(15);
        final afterAdjust = await repository.getByWorkoutId(workout.id);
        expect(afterAdjust!.restTimerDurationSec, 135);

        await controller.skipRestTimer();
        final afterSkip = await repository.getByWorkoutId(workout.id);
        expect(afterSkip!.restTimerEndsAtUtc, isNull);
      },
    );
  });
}
