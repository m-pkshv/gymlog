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
}
