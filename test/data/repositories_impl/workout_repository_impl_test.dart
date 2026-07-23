import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_tag_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_template_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late WorkoutTagRepositoryImpl tags;
  late WorkoutTemplateRepositoryImpl templates;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    tags = WorkoutTagRepositoryImpl(db);
    templates = WorkoutTemplateRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('createDraft starts a workout in draft status', () async {
    final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));

    expect(workout.status, WorkoutStatus.draft);
    expect(workout.date, DateTime(2026, 7, 19));
  });

  test(
    'getInProgressWorkout finds the single in-progress workout (DM 6.4.1)',
    () async {
      expect(await workouts.getInProgressWorkout(), isNull);

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.updateWorkout(
        draft.copyWith(status: WorkoutStatus.inProgress),
      );

      final inProgress = await workouts.getInProgressWorkout();
      expect(inProgress, isNotNull);
      expect(inProgress!.id, draft.id);
    },
  );

  test(
    'watchInProgressWorkout reflects the workout once one starts, and null '
    'again once it finishes (Stage 4, TS 7.2 step 5)',
    () async {
      final stream = workouts.watchInProgressWorkout();
      final emissions = <String?>[];
      final subscription = stream.listen((w) => emissions.add(w?.id));

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isNull, reason: 'a draft is not inProgress');

      await workouts.updateWorkout(
        draft.copyWith(status: WorkoutStatus.inProgress),
      );
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, draft.id);

      await workouts.updateWorkout(
        draft.copyWith(status: WorkoutStatus.completed),
      );
      await Future<void>.delayed(Duration.zero);
      expect(emissions.last, isNull);

      await subscription.cancel();
    },
  );

  test(
    'the full vertical slice: create, add exercise, add sets, autosave, reopen',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));

      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      expect(workoutExercise.orderIndex, 0);

      final firstSet = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      final secondSet = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      expect(firstSet.setNumber, 1);
      expect(secondSet.setNumber, 2);

      // Autosave: plan then fact, then mark completed (DM 6.7 copy-plan rule).
      final planned = secondSet.copyWith(plannedWeightKg: 100, plannedReps: 5);
      await workouts.updateSet(planned);
      final completed = planned.markCompleted();
      await workouts.updateSet(completed);

      // "Close and reopen": read everything back from the database.
      final details = await workouts.getDetails(workout.id);
      expect(details, isNotNull);
      expect(details!.workout.id, workout.id);
      expect(details.exercises, hasLength(1));

      final exerciseDetails = details.exercises.single;
      expect(exerciseDetails.exercise.name, 'Squat');
      expect(exerciseDetails.sets, hasLength(2));
      expect(exerciseDetails.sets[1].isCompleted, isTrue);
      expect(exerciseDetails.sets[1].actualWeightKg, 100);
      expect(exerciseDetails.sets[1].actualReps, 5);
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
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.addExercise(workoutId: workout.id, exerciseId: exercise.id);

      final canonical = await workouts.getDetails(workout.id);
      expect(canonical!.exercises.single.exercise.name, 'Squat');

      final localized = await workouts.getDetails(workout.id, locale: 'ru');
      expect(localized!.exercises.single.exercise.name, 'Приседания');
    });

    test('falls back to the canonical name when there is no translation for the given locale', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.addExercise(workoutId: workout.id, exerciseId: exercise.id);

      final details = await workouts.getDetails(workout.id, locale: 'ru');

      expect(details!.exercises.single.exercise.name, 'Squat');
    });
  });

  group('watchNextUpcomingWorkout (Stage 9, S-01)', () {
    test('null when there is no draft/planned workout at all', () async {
      expect(
        await workouts.watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19)).first,
        isNull,
      );
    });

    test(
      'picks the closest-dated draft/planned workout on or after notBefore',
      () async {
        final farther = await workouts.createDraft(date: DateTime(2026, 7, 25));
        final closer = await workouts.createDraft(date: DateTime(2026, 7, 20));

        final next = await workouts
            .watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19))
            .first;

        expect(next, isNotNull);
        expect(next!.workout.id, closer.id);
        expect(next.workout.id, isNot(farther.id));
      },
    );

    test('excludes workouts dated before notBefore', () async {
      await workouts.createDraft(date: DateTime(2026, 7, 18));

      final next = await workouts
          .watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19))
          .first;

      expect(next, isNull);
    });

    test(
      'excludes inProgress/completed/skipped/cancelled workouts (only draft/planned qualify)',
      () async {
        final inProgress = await workouts.createDraft(
          date: DateTime(2026, 7, 19),
        );
        await workouts.updateWorkout(
          inProgress.copyWith(status: WorkoutStatus.inProgress),
        );
        final completed = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        await workouts.updateWorkout(
          completed.copyWith(status: WorkoutStatus.completed),
        );
        final planned = await workouts.createDraft(date: DateTime(2026, 7, 21));
        await workouts.updateWorkout(
          planned.copyWith(status: WorkoutStatus.planned),
        );

        final next = await workouts
            .watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19))
            .first;

        expect(next, isNotNull);
        expect(next!.workout.id, planned.id);
      },
    );

    test('reports the exercise count', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.addExercise(workoutId: workout.id, exerciseId: exercise.id);

      final next = await workouts
          .watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19))
          .first;

      expect(next!.exerciseCount, 1);
    });

    test('excludes soft-deleted workouts', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 19));
      await workouts.deleteWorkout(workout.id);

      final next = await workouts
          .watchNextUpcomingWorkout(notBefore: DateTime(2026, 7, 19))
          .first;

      expect(next, isNull);
    });
  });

  test(
    'watchHistory only lists completed workouts, most recent first, with '
    'their exercise count',
    () async {
      final older = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.updateWorkout(
        older.copyWith(status: WorkoutStatus.completed),
      );

      final newer = await workouts.createDraft(date: DateTime(2026, 7, 19));
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      await workouts.addExercise(workoutId: newer.id, exerciseId: exercise.id);
      await workouts.updateWorkout(
        newer.copyWith(status: WorkoutStatus.completed),
      );

      final draft = await workouts.createDraft(date: DateTime(2026, 7, 20));
      // draft stays in draft status - should not show up in history

      final history = await workouts.watchHistory().first;
      expect(history.map((e) => e.workout.id), [newer.id, older.id]);
      expect(history.any((e) => e.workout.id == draft.id), isFalse);

      final newerEntry = history.firstWhere((e) => e.workout.id == newer.id);
      expect(newerEntry.exerciseCount, 1);
      final olderEntry = history.firstWhere((e) => e.workout.id == older.id);
      expect(olderEntry.exerciseCount, 0);
    },
  );

  test('getDetails returns null for an unknown workout', () async {
    expect(await workouts.getDetails('does-not-exist'), isNull);
  });

  test(
    'an old workout still displays an exercise that was archived after '
    '(Stage 2 acceptance criteria and manual check ★: "архивное упражнение '
    'скрыто из выбора, но открывается из старой тренировки")',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );

      await exercises.setArchived(exercise.id, archived: true);

      // Archived: hidden from the catalog picker (S-06/add-exercise).
      expect(await exercises.watchAll().first, isEmpty);

      // But the old workout that already references it still shows it
      // correctly -- getDetails fetches by id, unfiltered by isArchived.
      final details = await workouts.getDetails(workout.id);
      expect(details!.exercises.single.exercise.name, 'Squat');
      expect(details.exercises.single.exercise.isArchived, isTrue);
    },
  );

  group('getExerciseHistory (S-07)', () {
    test(
      'only completed occurrences are returned, most recent date first',
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
        );
        await workouts.updateSet(
          olderSet.copyWith(actualWeightKg: 80, actualReps: 5),
        );
        await workouts.updateWorkout(
          older.copyWith(status: WorkoutStatus.completed),
        );

        final newer = await workouts.createDraft(date: DateTime(2026, 7, 19));
        final newerWe = await workouts.addExercise(
          workoutId: newer.id,
          exerciseId: exercise.id,
        );
        await workouts.addSet(workoutExerciseId: newerWe.id);
        await workouts.updateWorkout(
          newer.copyWith(status: WorkoutStatus.completed),
        );

        // Draft workout with the exercise: not completed, must not show up.
        final draft = await workouts.createDraft(date: DateTime(2026, 7, 20));
        await workouts.addExercise(
          workoutId: draft.id,
          exerciseId: exercise.id,
        );

        final history = await workouts.getExerciseHistory(exercise.id);

        expect(history.map((e) => e.workout.id), [newer.id, older.id]);
        expect(history[1].sets.single.actualWeightKg, 80);
        expect(history[1].sets.single.actualReps, 5);
      },
    );

    test('returns nothing for an exercise never used', () async {
      final exercise = await exercises.create(
        name: 'Unused',
        exerciseType: ExerciseType.reps,
      );

      expect(await workouts.getExerciseHistory(exercise.id), isEmpty);
    });
  });

  group('workout tags (Stage 3, DM 6.3/6.5)', () {
    test('a fresh workout has no tags', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final details = await workouts.getDetails(workout.id);
      expect(details!.tags, isEmpty);
    });

    test('setWorkoutTags assigns tags, reflected in getDetails', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final legs = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
      final push = await tags.create(name: 'Push', colorHex: '#2E9E6B');

      await workouts.setWorkoutTags(
        workoutId: workout.id,
        tagIds: [legs.id, push.id],
      );

      final details = await workouts.getDetails(workout.id);
      expect(details!.tags.map((t) => t.id), containsAll([legs.id, push.id]));
      expect(details.tags, hasLength(2));
    });

    test(
      'setWorkoutTags replaces the previous set, not adds to it',
      () async {
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 20),
        );
        final legs = await tags.create(name: 'Leg day', colorHex: '#4C7BD9');
        final push = await tags.create(name: 'Push', colorHex: '#2E9E6B');

        await workouts.setWorkoutTags(
          workoutId: workout.id,
          tagIds: [legs.id],
        );
        await workouts.setWorkoutTags(
          workoutId: workout.id,
          tagIds: [push.id],
        );

        final details = await workouts.getDetails(workout.id);
        expect(details!.tags.map((t) => t.id), [push.id]);
      },
    );
  });

  group('copyWorkout (Stage 3, S-02, TS 8 section 8)', () {
    test(
      'copies exercises, order, comment and planned values into a new '
      'draft dated by the caller -- actuals, completion and progression '
      'are never copied',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final source = await workouts.createDraft(
          date: DateTime(2026, 7, 1),
        );
        final sourceWe = await workouts.addExercise(
          workoutId: source.id,
          exerciseId: exercise.id,
        );
        final sourceSet = await workouts.addSet(
          workoutExerciseId: sourceWe.id,
        );
        await workouts.updateSet(
          sourceSet.copyWith(
            plannedWeightKg: 60,
            plannedReps: 8,
            actualWeightKg: 62,
            actualReps: 7,
          ),
        );
        await workouts.updateSet(
          (await workouts.getDetails(source.id))!.exercises.single.sets.single
              .markCompleted(),
        );
        await workouts.updateWorkout(
          source.copyWith(status: WorkoutStatus.completed),
        );

        final copy = await workouts.copyWorkout(
          sourceWorkoutId: source.id,
          date: DateTime(2026, 7, 20),
        );

        expect(copy.date, DateTime(2026, 7, 20));
        expect(copy.status, WorkoutStatus.draft);
        expect(copy.id, isNot(source.id));

        final details = await workouts.getDetails(copy.id);
        expect(details!.exercises, hasLength(1));
        final copiedExerciseDetails = details.exercises.single;
        expect(copiedExerciseDetails.exercise.id, exercise.id);
        expect(
          copiedExerciseDetails.workoutExercise.orderIndex,
          sourceWe.orderIndex,
        );
        expect(
          copiedExerciseDetails.workoutExercise.progressionDecision,
          ProgressionDecision.none,
        );

        final copiedSet = copiedExerciseDetails.sets.single;
        expect(copiedSet.plannedWeightKg, 60.0);
        expect(copiedSet.plannedReps, 8);
        expect(copiedSet.actualWeightKg, isNull);
        expect(copiedSet.actualReps, isNull);
        expect(copiedSet.isCompleted, isFalse);

        // The source workout is untouched by the copy.
        final sourceDetails = await workouts.getDetails(source.id);
        expect(sourceDetails!.workout.status, WorkoutStatus.completed);
        expect(sourceDetails.exercises.single.sets.single.isCompleted, isTrue);
      },
    );

    test('throws for an unknown source workout', () {
      expect(
        () => workouts.copyWorkout(
          sourceWorkoutId: 'does-not-exist',
          date: DateTime(2026, 7, 20),
        ),
        throwsArgumentError,
      );
    });
  });

  group('createFromTemplate (Stage 5, TS 8 section 8, DM-1)', () {
    test(
      'copies exercises, order, comment and planned values into a new '
      'draft named after the template',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final template = await templates.create(name: 'Leg day');
        var templateExercise = await templates.addExercise(
          templateId: template.id,
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

        final workout = await workouts.createFromTemplate(
          templateId: template.id,
          date: DateTime(2026, 7, 20),
        );

        expect(workout.date, DateTime(2026, 7, 20));
        expect(workout.status, WorkoutStatus.draft);
        expect(workout.name, 'Leg day');

        final details = await workouts.getDetails(workout.id);
        expect(details!.exercises, hasLength(1));
        final exerciseDetails = details.exercises.single;
        expect(exerciseDetails.exercise.id, exercise.id);
        expect(exerciseDetails.workoutExercise.comment, 'Go heavy');
        expect(
          exerciseDetails.workoutExercise.progressionDecision,
          ProgressionDecision.none,
        );
        expect(exerciseDetails.sets, hasLength(2));
        expect(exerciseDetails.sets[0].plannedWeightKg, 40);
        expect(exerciseDetails.sets[1].plannedWeightKg, 100);
        expect(exerciseDetails.sets[1].plannedReps, 5);
        expect(exerciseDetails.sets[1].isCompleted, isFalse);
        expect(exerciseDetails.sets[1].actualWeightKg, isNull);
      },
    );

    test('throws for an unknown source template', () {
      expect(
        () => workouts.createFromTemplate(
          templateId: 'does-not-exist',
          date: DateTime(2026, 7, 20),
        ),
        throwsArgumentError,
      );
    });
  });

  group('watchHistory filters (Stage 3, S-02)', () {
    test(
      'an empty statuses filter defaults to completed only (owner-confirmed '
      '2026-07-21)',
      () async {
        final draft = await workouts.createDraft(date: DateTime(2026, 7, 1));
        final completed = await workouts.createDraft(
          date: DateTime(2026, 7, 2),
        );
        await workouts.updateWorkout(
          completed.copyWith(status: WorkoutStatus.completed),
        );

        final history = await workouts.watchHistory().first;

        expect(history.map((e) => e.workout.id), [completed.id]);
        expect(history.any((e) => e.workout.id == draft.id), isFalse);
      },
    );

    test(
      'an explicit statuses selection replaces the default, not widens it',
      () async {
        final draft = await workouts.createDraft(date: DateTime(2026, 7, 1));
        final completed = await workouts.createDraft(
          date: DateTime(2026, 7, 2),
        );
        await workouts.updateWorkout(
          completed.copyWith(status: WorkoutStatus.completed),
        );

        final history = await workouts
            .watchHistory(
              filter: (
                query: '',
                dateFrom: null,
                dateTo: null,
                statuses: {WorkoutStatus.draft},
                tagIds: <String>{},
              ),
            )
            .first;

        expect(history.map((e) => e.workout.id), [draft.id]);
        expect(history.any((e) => e.workout.id == completed.id), isFalse);
      },
    );

    test('date range narrows to workouts within [dateFrom, dateTo]', () async {
      final before = await workouts.createDraft(date: DateTime(2026, 6, 30));
      final inRange = await workouts.createDraft(date: DateTime(2026, 7, 10));
      final after = await workouts.createDraft(date: DateTime(2026, 7, 25));
      for (final workout in [before, inRange, after]) {
        await workouts.updateWorkout(
          workout.copyWith(status: WorkoutStatus.completed),
        );
      }

      final history = await workouts
          .watchHistory(
            filter: (
              query: '',
              dateFrom: DateTime(2026, 7, 1),
              dateTo: DateTime(2026, 7, 20),
              statuses: <WorkoutStatus>{},
              tagIds: <String>{},
            ),
          )
          .first;

      expect(history.map((e) => e.workout.id), [inRange.id]);
    });

    test(
      'name search matches case-insensitively, including Cyrillic '
      '(ASSUMPTION(dart-side-text-search))',
      () async {
        final legDay = await workouts.createDraft(date: DateTime(2026, 7, 1));
        await workouts.updateWorkout(
          legDay.copyWith(name: 'Ножки', status: WorkoutStatus.completed),
        );
        final pushDay = await workouts.createDraft(date: DateTime(2026, 7, 2));
        await workouts.updateWorkout(
          pushDay.copyWith(name: 'Грудь', status: WorkoutStatus.completed),
        );

        final history = await workouts
            .watchHistory(
              filter: (
                query: 'нож',
                dateFrom: null,
                dateTo: null,
                statuses: <WorkoutStatus>{},
                tagIds: <String>{},
              ),
            )
            .first;

        expect(history.map((e) => e.workout.id), [legDay.id]);
      },
    );

    test('tag filter matches in OR mode across 2+ tags', () async {
      final legs = await tags.create(name: 'Legs', colorHex: '#4C7BD9');
      final push = await tags.create(name: 'Push', colorHex: '#2E9E6B');
      final pull = await tags.create(name: 'Pull', colorHex: '#D9774C');

      final legWorkout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.setWorkoutTags(workoutId: legWorkout.id, tagIds: [legs.id]);
      await workouts.updateWorkout(
        legWorkout.copyWith(status: WorkoutStatus.completed),
      );

      final pushWorkout = await workouts.createDraft(
        date: DateTime(2026, 7, 2),
      );
      await workouts.setWorkoutTags(
        workoutId: pushWorkout.id,
        tagIds: [push.id],
      );
      await workouts.updateWorkout(
        pushWorkout.copyWith(status: WorkoutStatus.completed),
      );

      final pullWorkout = await workouts.createDraft(
        date: DateTime(2026, 7, 3),
      );
      await workouts.setWorkoutTags(
        workoutId: pullWorkout.id,
        tagIds: [pull.id],
      );
      await workouts.updateWorkout(
        pullWorkout.copyWith(status: WorkoutStatus.completed),
      );

      final history = await workouts
          .watchHistory(
            filter: (
              query: '',
              dateFrom: null,
              dateTo: null,
              statuses: <WorkoutStatus>{},
              tagIds: {legs.id, push.id},
            ),
          )
          .first;

      expect(
        history.map((e) => e.workout.id).toSet(),
        {legWorkout.id, pushWorkout.id},
      );
    });

    test('entries carry their assigned tags for the card chips', () async {
      final legs = await tags.create(name: 'Legs', colorHex: '#4C7BD9');
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.setWorkoutTags(workoutId: workout.id, tagIds: [legs.id]);
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );

      final history = await workouts.watchHistory().first;

      expect(history.single.tags.map((t) => t.id), [legs.id]);
    });
  });

  group('reorderExercises (Stage 3, S-03 drag handle + "⋮ → Вверх/Вниз")', () {
    test(
      'rewrites orderIndex to match the given id order (DM 6.6: no '
      'continuity required)',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
        final first = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final second = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final third = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );

        await workouts.reorderExercises(
          workoutId: workout.id,
          orderedWorkoutExerciseIds: [third.id, first.id, second.id],
        );

        final details = await workouts.getDetails(workout.id);
        expect(
          details!.exercises.map((e) => e.workoutExercise.id),
          [third.id, first.id, second.id],
        );
      },
    );
  });

  group('updateWorkoutExercise (Stage 3, S-03 exercise comment)', () {
    test('persists a comment change', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 20));
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );

      await workouts.updateWorkoutExercise(
        workoutExercise.copyWith(comment: 'Felt strong today'),
      );

      final details = await workouts.getDetails(workout.id);
      expect(
        details!.exercises.single.workoutExercise.comment,
        'Felt strong today',
      );
    });
  });

  group('deleteWorkout / restoreWorkout (Stage 3, S-02, DM 10)', () {
    test(
      'soft-deletes the workout and cascades to its exercises/sets',
      () async {
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(
          date: DateTime(2026, 7, 1),
        );
        await workouts.updateWorkout(
          workout.copyWith(status: WorkoutStatus.completed),
        );
        final workoutExercise = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
        );

        await workouts.deleteWorkout(workout.id);

        expect(await workouts.getDetails(workout.id), isNull);
        final history = await workouts.watchHistory().first;
        expect(history.any((e) => e.workout.id == workout.id), isFalse);

        final workoutRow = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals(workout.id))).getSingle();
        expect(workoutRow.isDeleted, isTrue);
        final workoutExerciseRow = await (db.select(
          db.workoutExercises,
        )..where((we) => we.id.equals(workoutExercise.id))).getSingle();
        expect(workoutExerciseRow.isDeleted, isTrue);
        final setRows = await (db.select(
          db.exerciseSets,
        )..where((s) => s.workoutExerciseId.equals(workoutExercise.id))).get();
        expect(setRows.single.isDeleted, isTrue);
      },
    );

    test('restoreWorkout reverses a delete within the Undo window', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      await workouts.deleteWorkout(workout.id);

      await workouts.restoreWorkout(workout.id);

      final details = await workouts.getDetails(workout.id);
      expect(details, isNotNull);
      expect(details!.exercises, hasLength(1));
      expect(details.exercises.single.sets, hasLength(1));
      final history = await workouts.watchHistory().first;
      expect(history.any((e) => e.workout.id == workout.id), isTrue);
    });
  });

  group('watchPeriodStats (Stage 7, S-09 "Тренировки" card, TS 9)', () {
    Future<void> addCompletedWorkout({
      required DateTime date,
      required ExerciseType exerciseType,
      required List<({bool isCompleted, double? weight, int? reps})> sets,
    }) async {
      final exercise = await exercises.create(
        name: 'Test exercise',
        exerciseType: exerciseType,
      );
      final workout = await workouts.createDraft(date: date);
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      for (final spec in sets) {
        final set = await workouts.addSet(
          workoutExerciseId: workoutExercise.id,
        );
        await workouts.updateSet(
          set.copyWith(
            plannedWeightKg: spec.weight,
            plannedReps: spec.reps,
            isCompleted: spec.isCompleted,
            actualWeightKg: spec.weight,
            actualReps: spec.reps,
          ),
        );
      }
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
    }

    test('an empty period gives zero count and zero tonnage', () async {
      final stats = await workouts
          .watchPeriodStats(from: DateTime(2026, 1, 1), to: DateTime(2026, 1, 31))
          .first;
      expect(stats.workoutCount, 0);
      expect(stats.tonnageKg, 0.0);
    });

    test(
      'counts completed workouts in range and sums tonnage of completed '
      'strength/reps sets',
      () async {
        await addCompletedWorkout(
          date: DateTime(2026, 7, 10),
          exerciseType: ExerciseType.strength,
          sets: [
            (isCompleted: true, weight: 20, reps: 10),
            (isCompleted: true, weight: 100, reps: 5),
            (isCompleted: false, weight: 100, reps: 5),
          ],
        );
        await addCompletedWorkout(
          date: DateTime(2026, 7, 15),
          exerciseType: ExerciseType.reps,
          sets: [(isCompleted: true, weight: null, reps: 20)],
        );

        final stats = await workouts
            .watchPeriodStats(from: DateTime(2026, 7, 1), to: DateTime(2026, 7, 31))
            .first;

        expect(stats.workoutCount, 2);
        // The two completed strength sets contribute: 20*10 + 100*5 = 700.
        // The uncompleted set and the weightless reps set both contribute 0.
        expect(stats.tonnageKg, 700.0);
      },
    );

    test('excludes workouts outside the date range', () async {
      await addCompletedWorkout(
        date: DateTime(2026, 6, 30),
        exerciseType: ExerciseType.strength,
        sets: [(isCompleted: true, weight: 50, reps: 10)],
      );

      final stats = await workouts
          .watchPeriodStats(from: DateTime(2026, 7, 1), to: DateTime(2026, 7, 31))
          .first;
      expect(stats.workoutCount, 0);
      expect(stats.tonnageKg, 0.0);
    });

    test('null from/to means unbounded ("Всё время")', () async {
      await addCompletedWorkout(
        date: DateTime(2000, 1, 1),
        exerciseType: ExerciseType.strength,
        sets: [(isCompleted: true, weight: 50, reps: 10)],
      );

      final stats = await workouts.watchPeriodStats().first;
      expect(stats.workoutCount, 1);
      expect(stats.tonnageKg, 500.0);
    });

    test('a draft workout in range is not counted', () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final draft = await workouts.createDraft(date: DateTime(2026, 7, 10));
      final workoutExercise = await workouts.addExercise(
        workoutId: draft.id,
        exerciseId: exercise.id,
      );
      await workouts.addSet(workoutExerciseId: workoutExercise.id);

      final stats = await workouts
          .watchPeriodStats(from: DateTime(2026, 7, 1), to: DateTime(2026, 7, 31))
          .first;
      expect(stats.workoutCount, 0);
      expect(stats.tonnageKg, 0.0);
    });
  });

  group('getAllForExport (Stage 8, TS 10.1/10.3)', () {
    test('returns every non-deleted status, not just completed', () async {
      final draft = await workouts.createDraft(date: DateTime(2026, 7, 1));
      final planned = await workouts.createDraft(date: DateTime(2026, 7, 2));
      await workouts.updateWorkout(
        planned.copyWith(status: WorkoutStatus.planned),
      );
      final cancelled = await workouts.createDraft(date: DateTime(2026, 7, 3));
      await workouts.updateWorkout(
        cancelled.copyWith(status: WorkoutStatus.cancelled),
      );

      final all = await workouts.getAllForExport();
      expect(
        all.map((d) => d.workout.id).toSet(),
        {draft.id, planned.id, cancelled.id},
      );
    });

    test('excludes soft-deleted workouts', () async {
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      await workouts.deleteWorkout(workout.id);

      final all = await workouts.getAllForExport();
      expect(all, isEmpty);
    });

    test(
      'includes full nested exercise/set/tag detail, excluding soft-deleted '
      'exercises and sets',
      () async {
        final legs = await tags.create(name: 'Legs', colorHex: '#4C7BD9');
        final exercise = await exercises.create(
          name: 'Squat',
          exerciseType: ExerciseType.strength,
        );
        final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
        await workouts.setWorkoutTags(
          workoutId: workout.id,
          tagIds: [legs.id],
        );
        final we = await workouts.addExercise(
          workoutId: workout.id,
          exerciseId: exercise.id,
        );
        final set = await workouts.addSet(
          workoutExerciseId: we.id,
        );
        await workouts.updateSet(
          set.copyWith(isCompleted: true, actualWeightKg: 100, actualReps: 5),
        );

        final all = await workouts.getAllForExport();
        final details = all.single;
        expect(details.tags.map((t) => t.name), ['Legs']);
        expect(details.exercises, hasLength(1));
        expect(details.exercises.single.exercise.name, 'Squat');
        expect(details.exercises.single.sets.single.actualWeightKg, 100);
      },
    );
  });
}
