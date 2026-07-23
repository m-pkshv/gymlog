import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_template_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late WorkoutTemplateRepositoryImpl templates;
  late ExerciseRepositoryImpl exercises;
  late WorkoutRepositoryImpl workouts;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    templates = WorkoutTemplateRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    workouts = WorkoutRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('create starts a template with no exercises yet', () async {
    final template = await templates.create(name: 'Leg day', comment: 'Heavy');

    expect(template.name, 'Leg day');
    expect(template.comment, 'Heavy');
    expect(template.isArchived, isFalse);

    final details = await templates.getDetails(template.id);
    expect(details, isNotNull);
    expect(details!.exercises, isEmpty);
  });

  test(
    'the full vertical slice: create, add exercise, add sets, autosave, reopen',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final template = await templates.create(name: 'Leg day');

      final templateExercise = await templates.addExercise(
        templateId: template.id,
        exerciseId: exercise.id,
      );
      expect(templateExercise.orderIndex, 0);

      final firstSet = await templates.addSet(
        templateExerciseId: templateExercise.id,
      );
      final secondSet = await templates.addSet(
        templateExerciseId: templateExercise.id,
      );
      expect(firstSet.setNumber, 1);
      expect(secondSet.setNumber, 2);

      final planned = secondSet.copyWith(plannedWeightKg: 100, plannedReps: 5);
      await templates.updateTemplateSet(planned);

      final details = await templates.getDetails(template.id);
      expect(details, isNotNull);
      expect(details!.exercises, hasLength(1));

      final exerciseDetails = details.exercises.single;
      expect(exerciseDetails.exercise.name, 'Squat');
      expect(exerciseDetails.sets, hasLength(2));
      expect(exerciseDetails.sets[1].plannedWeightKg, 100);
      expect(exerciseDetails.sets[1].plannedReps, 5);
    },
  );

  group('getDetails locale (Stage 10, DM 12)', () {
    test('resolves the embedded exercise name against ExerciseL10n when a locale is given', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await db
          .into(db.exerciseL10n)
          .insert(
            ExerciseL10nCompanion.insert(
              exerciseId: exercise.id,
              locale: 'ru',
              name: 'Приседания',
            ),
          );
      final template = await templates.create(name: 'Leg day');
      await templates.addExercise(templateId: template.id, exerciseId: exercise.id);

      final canonical = await templates.getDetails(template.id);
      expect(canonical!.exercises.single.exercise.name, 'Squat');

      final localized = await templates.getDetails(template.id, locale: 'ru');
      expect(localized!.exercises.single.exercise.name, 'Приседания');
    });
  });

  test('watchAll excludes archived templates by default, includes on request', () async {
    final active = await templates.create(name: 'Active');
    final archived = await templates.create(name: 'Archived');
    await templates.update(archived.copyWith(isArchived: true));

    final defaultList = await templates.watchAll().first;
    expect(defaultList.map((t) => t.id), [active.id]);

    final fullList = await templates.watchAll(includeArchived: true).first;
    expect(fullList.map((t) => t.id), containsAll([active.id, archived.id]));
  });

  test('update persists name/comment/archived changes', () async {
    final template = await templates.create(name: 'Leg day');

    await templates.update(
      template.copyWith(name: 'Leg day v2', comment: 'Updated', isArchived: true),
    );

    final details = await templates.getDetails(template.id);
    expect(details!.template.name, 'Leg day v2');
    expect(details.template.comment, 'Updated');
    expect(details.template.isArchived, isTrue);
  });

  test('reorderExercises rewrites orderIndex to match the given order', () async {
    final exercise = await exercises.create(
      name: 'Squat',
      exerciseType: ExerciseType.strength,
    );
    final template = await templates.create(name: 'Leg day');
    final first = await templates.addExercise(
      templateId: template.id,
      exerciseId: exercise.id,
    );
    final second = await templates.addExercise(
      templateId: template.id,
      exerciseId: exercise.id,
    );

    await templates.reorderExercises(
      templateId: template.id,
      orderedTemplateExerciseIds: [second.id, first.id],
    );

    final details = await templates.getDetails(template.id);
    expect(
      details!.exercises.map((e) => e.templateExercise.id).toList(),
      [second.id, first.id],
    );
  });

  test(
    'createFromWorkout copies exercises/order/comment and planned set '
    'values, but never facts or the workout comment '
    '(TS 8 section 8)',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      await workouts.updateWorkout(
        workout.copyWith(comment: 'Great session'),
      );
      var workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      workoutExercise = workoutExercise.copyWith(comment: 'Go heavy');
      await workouts.updateWorkoutExercise(workoutExercise);

      final first = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      await workouts.updateSet(
        first.copyWith(plannedWeightKg: 40, plannedReps: 10),
      );
      final second = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      await workouts.updateSet(
        second
            .copyWith(plannedWeightKg: 100, plannedReps: 5)
            .markCompleted()
            .copyWith(actualWeightKg: 105, actualReps: 4),
      );

      final template = await templates.createFromWorkout(
        workoutId: workout.id,
        name: 'Leg day',
      );

      expect(template.comment, isNull, reason: 'workout comment not copied');
      final details = await templates.getDetails(template.id);
      expect(details!.exercises, hasLength(1));
      final exerciseDetails = details.exercises.single;
      expect(exerciseDetails.templateExercise.comment, 'Go heavy');
      expect(exerciseDetails.sets, hasLength(2));
      expect(exerciseDetails.sets[0].plannedWeightKg, 40);
      expect(exerciseDetails.sets[1].plannedWeightKg, 100);
      expect(exerciseDetails.sets[1].plannedReps, 5);

      // The source workout itself is untouched.
      final sourceDetails = await workouts.getDetails(workout.id);
      expect(sourceDetails!.exercises.single.sets[1].actualWeightKg, 105);
    },
  );

  test('createFromWorkout throws for a non-existent workout', () async {
    expect(
      () => templates.createFromWorkout(workoutId: 'missing', name: 'Leg day'),
      throwsArgumentError,
    );
  });

  test(
    'duplicate clones exercises, order, comments and all planned set '
    'values under a new name, never archived '
    '(04_UI_UX_SPEC.md section 5)',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final source = await templates.create(
        name: 'Leg day',
        comment: 'Heavy',
      );
      await templates.update(source.copyWith(isArchived: true));
      var templateExercise = await templates.addExercise(
        templateId: source.id,
        exerciseId: exercise.id,
      );
      templateExercise = templateExercise.copyWith(comment: 'Go heavy');
      await templates.updateTemplateExercise(templateExercise);

      final first = await templates.addSet(
        templateExerciseId: templateExercise.id,
      );
      await templates.updateTemplateSet(
        first.copyWith(plannedWeightKg: 40, plannedReps: 10),
      );
      final second = await templates.addSet(
        templateExerciseId: templateExercise.id,
      );
      await templates.updateTemplateSet(
        second.copyWith(plannedWeightKg: 100, plannedReps: 5),
      );

      final copy = await templates.duplicate(
        templateId: source.id,
        name: 'Leg day copy',
      );

      expect(copy.id, isNot(source.id));
      expect(copy.name, 'Leg day copy');
      expect(copy.comment, 'Heavy');
      expect(copy.isArchived, isFalse, reason: 'a duplicate starts active');

      final details = await templates.getDetails(copy.id);
      expect(details!.exercises, hasLength(1));
      final exerciseDetails = details.exercises.single;
      expect(exerciseDetails.exercise.id, exercise.id);
      expect(exerciseDetails.templateExercise.comment, 'Go heavy');
      expect(exerciseDetails.sets, hasLength(2));
      expect(exerciseDetails.sets[0].plannedWeightKg, 40);
      expect(exerciseDetails.sets[1].plannedWeightKg, 100);
      expect(exerciseDetails.sets[1].plannedReps, 5);

      // The source template is untouched.
      final sourceDetails = await templates.getDetails(source.id);
      expect(sourceDetails!.exercises.single.sets, hasLength(2));
    },
  );

  test('duplicate throws for a non-existent template', () async {
    expect(
      () => templates.duplicate(templateId: 'missing', name: 'Leg day copy'),
      throwsArgumentError,
    );
  });

  test(
    'deleteTemplate cascades to its exercises/sets and restoreTemplate '
    'reverses it (D-19 Undo window)',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final template = await templates.create(name: 'Leg day');
      final templateExercise = await templates.addExercise(
        templateId: template.id,
        exerciseId: exercise.id,
      );
      await templates.addSet(templateExerciseId: templateExercise.id);

      await templates.deleteTemplate(template.id);
      expect(await templates.getDetails(template.id), isNull);
      expect(await templates.watchAll(includeArchived: true).first, isEmpty);

      await templates.restoreTemplate(template.id);
      final details = await templates.getDetails(template.id);
      expect(details, isNotNull);
      expect(details!.exercises, hasLength(1));
      expect(details.exercises.single.sets, hasLength(1));
    },
  );
}
