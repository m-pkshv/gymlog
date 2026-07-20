import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/core/date_format.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/workout_editor/add_exercise_screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the subset of `app/router.dart` the workout editor needs (S-03,
/// Stage 1) — a self-contained harness rather than pulling in all 5 tabs.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(
        path: '/history/workout/:workoutId',
        builder: (_, state) => WorkoutEditorScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
        routes: [
          GoRoute(
            path: 'add-exercise',
            builder: (_, state) => AddExerciseScreen(
              workoutId: state.pathParameters['workoutId']!,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const CreateExerciseScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Future<void> _seedExercise(
  AppDatabase db, {
  String id = 'squat',
  String name = 'Squat',
  ExerciseType type = ExerciseType.strength,
}) {
  return db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: name,
          exerciseType: type.name,
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
}

Future<void> _seedTag(
  AppDatabase db, {
  String id = 'tag1',
  String name = 'Leg day',
  String colorHex = '#4C7BD9',
}) {
  return db
      .into(db.workoutTags)
      .insert(
        WorkoutTagsCompanion.insert(
          id: id,
          name: name,
          colorHex: Value(colorHex),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
}

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// Stage 3 turned History's FAB into a "с нуля/из шаблона/копией" creation
/// menu (`_openNewWorkoutMenu`); most tests here only care about ending up
/// with a fresh draft, so this does the "From scratch" tap for them.
Future<void> _createDraftViaFab(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.tap(find.text('From scratch'));
  await tester.pumpAndSettle();
}

/// An already-inProgress workout, distinct from whatever the test creates
/// through the FAB — the "another workout is already active" conflict
/// dialog tests' fixture (S-03, DM 6.4.1).
Future<void> _seedActiveWorkout(AppDatabase db, {String id = 'active'}) {
  return db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: id,
          date: '2026-07-15',
          status: const Value('inProgress'),
          startedAt: const Value('2026-07-15T10:00:00Z'),
          createdAt: '2026-07-15T10:00:00Z',
          updatedAt: '2026-07-15T10:00:00Z',
        ),
      );
}

/// A completed workout from 2026-07-10 with one logged set of the seeded
/// 'squat' exercise (actual: 60 kg × 8) — the "Прошлые результаты"/
/// "Копировать показатели прошлого выполнения" tests' fixture (S-03, TS 8).
Future<void> _seedPastCompletedOccurrence(AppDatabase db) async {
  await db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: 'past',
          date: '2026-07-10',
          status: const Value('completed'),
          createdAt: '2026-07-10T00:00:00Z',
          updatedAt: '2026-07-10T00:00:00Z',
        ),
      );
  await db
      .into(db.workoutExercises)
      .insert(
        WorkoutExercisesCompanion.insert(
          id: 'past_we',
          workoutId: 'past',
          exerciseId: 'squat',
          orderIndex: 0,
          createdAt: '2026-07-10T00:00:00Z',
          updatedAt: '2026-07-10T00:00:00Z',
        ),
      );
  await db
      .into(db.exerciseSets)
      .insert(
        ExerciseSetsCompanion.insert(
          id: 'past_s1',
          workoutExerciseId: 'past_we',
          setNumber: 1,
          actualWeightKg: const Value(60),
          actualReps: const Value(8),
          createdAt: '2026-07-10T00:00:00Z',
          updatedAt: '2026-07-10T00:00:00Z',
        ),
      );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'the FAB on History creates a draft and opens the editor (S-03 entry)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createDraftViaFab(tester);

      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('No exercises added yet'), findsOneWidget);

      final workouts = await db.select(db.workouts).get();
      expect(workouts, hasLength(1));
      expect(workouts.single.status, WorkoutStatus.draft.name);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('picking an existing exercise adds it to the workout', (
    tester,
  ) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await _createDraftViaFab(tester);

    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('No exercises added yet'), findsNothing);

    final workoutExercises = await db.select(db.workoutExercises).get();
    expect(workoutExercises, hasLength(1));

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'creating a new exercise from the editor adds it immediately (Stage 1 ★)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createDraftViaFab(tester);

      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      expect(find.text('No exercises yet'), findsOneWidget);

      // The picker's own FAB opens the create form (S-08) directly -- it
      // isn't History's FAB, so it doesn't go through the creation menu.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Push-Up');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      // Back on the editor, with the new exercise already added.
      expect(find.text('Push-Up'), findsOneWidget);
      expect(find.text('No exercises added yet'), findsNothing);

      final exercises = await db.select(db.exercises).get();
      expect(exercises.single.name, 'Push-Up');
      final workoutExercises = await db.select(db.workoutExercises).get();
      expect(workoutExercises, hasLength(1));

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('add set creates a working set row', (tester) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await _createDraftViaFab(tester);
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add set'));
    await tester.pumpAndSettle();

    final sets = await db.select(db.exerciseSets).get();
    expect(sets, hasLength(1));
    expect(sets.single.setNumber, 1);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'editing a plan field debounces the write, then autosaves (TS 5)',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      // Weight, kg: first plan field of a strength exercise.
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();

      var sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, isNull, reason: 'not flushed yet');

      // Just under the debounce window: still unwritten.
      await tester.pump(autosaveDebounce - const Duration(milliseconds: 50));
      sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, isNull);

      // Past the debounce window: the value lands in the database.
      await tester.pump(const Duration(milliseconds: 100));
      sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, 100.0);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'losing focus flushes immediately, without waiting for the debounce',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '80');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, 80.0);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('checking "done" copies plan into empty facts (DM 6.7)', (
    tester,
  ) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await _createDraftViaFab(tester);
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add set'));
    await tester.pumpAndSettle();

    // Plan weight, then plan reps (the two TextFields of a strength row).
    await tester.enterText(find.byType(TextField).at(0), '60');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    final sets = await db.select(db.exerciseSets).get();
    expect(sets.single.isCompleted, isTrue);
    expect(sets.single.actualWeightKg, 60.0);
    expect(sets.single.actualReps, 10);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'Start then Finish moves the workout draft -> inProgress -> completed',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      // Status chip -> menu -> "Start workout" (draft -> inProgress).
      await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();
      expect(find.text('In progress'), findsOneWidget);

      var workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.inProgress.name);
      expect(workouts.single.startedAt, isNotNull);

      // Status chip -> menu -> "Finish" (inProgress -> completed).
      await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);

      workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.completed.name);
      expect(workouts.single.finishedAt, isNotNull);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('reopening the editor shows previously saved data', (
    tester,
  ) async {
    await _seedExercise(db);
    await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: 'w1',
            date: '2026-07-20',
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    await db
        .into(db.workoutExercises)
        .insert(
          WorkoutExercisesCompanion.insert(
            id: 'we1',
            workoutId: 'w1',
            exerciseId: 'squat',
            orderIndex: 0,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    await db
        .into(db.exerciseSets)
        .insert(
          ExerciseSetsCompanion.insert(
            id: 's1',
            workoutExerciseId: 'we1',
            setNumber: 1,
            plannedWeightKg: const Value(100),
            plannedReps: const Value(5),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    final router = GoRouter(
      initialLocation: '/history/workout/w1',
      routes: [
        GoRoute(
          path: '/history/workout/:workoutId',
          builder: (_, state) => WorkoutEditorScreen(
            workoutId: state.pathParameters['workoutId']!,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('"Past results" shows the last completed occurrence (S-03)', (
    tester,
  ) async {
    await _seedExercise(db);
    await _seedPastCompletedOccurrence(db);

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await _createDraftViaFab(tester);
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Past results'));
    await tester.pumpAndSettle();

    expect(find.text('10.07.2026'), findsOneWidget);
    expect(find.textContaining('60.0 kg'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    '"Past results" shows an empty state when there is no history yet',
    (tester) async {
      await _seedExercise(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Past results'));
      await tester.pumpAndSettle();

      expect(
        find.text('No completed occurrences of this exercise yet'),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"Copy last performance" fills planned values from the last completed '
    'occurrence (TS 8)',
    (tester) async {
      await _seedExercise(db);
      await _seedPastCompletedOccurrence(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy last performance'));
      await tester.pumpAndSettle();

      final sets = await db.select(db.exerciseSets).get();
      final newSet = sets.singleWhere((s) => s.workoutExerciseId != 'past_we');
      expect(newSet.plannedWeightKg, 60.0);
      expect(newSet.plannedReps, 8);
      expect(find.text('60.0'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"Copy last performance" tells the user when there is nothing to copy',
    (tester) async {
      await _seedExercise(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy last performance'));
      await tester.pumpAndSettle();

      expect(find.text('No past results to copy yet'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the status menu only offers the transitions allowed from draft (DM 6.4.1)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
      await tester.pumpAndSettle();

      // draft -> {planned, inProgress} only (WorkoutService.allowedTransitions).
      expect(find.text('Schedule'), findsOneWidget);
      expect(find.text('Start workout'), findsOneWidget);
      expect(find.text('Finish'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Skip'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'tapping the date opens a date picker, movable except while inProgress '
    '(DM 6.4.1)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(find.text(formatShortDate(DateTime.now())));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Dismiss without picking a new day -- the picker opening at all is
      // the thing under test; `moveDate` itself is covered at the
      // controller level (controller_test.dart) against a real database.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the date is not tappable while the workout is inProgress (DM 6.4.1)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();

      await tester.tap(find.text(formatShortDate(DateTime.now())));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  group('active-workout conflict dialog (S-03, DM 6.4.1)', () {
    testWidgets(
      'starting a workout while another is inProgress shows the conflict '
      'dialog instead of a generic error',
      (tester) async {
        await _seedActiveWorkout(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start workout'));
        await tester.pumpAndSettle();

        expect(find.text('A workout is already in progress'), findsOneWidget);
        expect(find.text('Finish it'), findsOneWidget);
        expect(find.text('Cancel it'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'dismissing the dialog leaves both workouts untouched',
      (tester) async {
        await _seedActiveWorkout(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Draft'), findsOneWidget);
        final active = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals('active'))).getSingle();
        expect(active.status, 'inProgress');

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      '"Finish it" completes the other workout and starts this one',
      (tester) async {
        await _seedActiveWorkout(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Finish it'));
        await tester.pumpAndSettle();

        expect(find.text('In progress'), findsOneWidget);
        final active = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals('active'))).getSingle();
        expect(active.status, 'completed');
        expect(active.finishedAt, isNotNull);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      '"Cancel it" cancels the other workout and starts this one',
      (tester) async {
        await _seedActiveWorkout(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Start workout'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel it'));
        await tester.pumpAndSettle();

        expect(find.text('In progress'), findsOneWidget);
        final active = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals('active'))).getSingle();
        expect(active.status, 'cancelled');

        await _unmountAndFlush(tester);
      },
    );
  });

  group('workout tags (Stage 3, S-03, DM 6.3/6.5)', () {
    testWidgets(
      'the tag row shows an "Add tag" action and no chip for an unassigned '
      'tag',
      (tester) async {
        await _seedTag(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        expect(find.text('Add tag'), findsOneWidget);
        expect(find.text('Leg day'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'tapping an existing tag in the picker sheet assigns it',
      (tester) async {
        await _seedTag(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add tag'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(FilterChip, 'Leg day'));
        await tester.pumpAndSettle();

        final links = await db.select(db.workoutTagLinks).get();
        expect(links, hasLength(1));
        expect(links.single.tagId, 'tag1');
        final chip = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, 'Leg day'),
        );
        expect(chip.selected, isTrue);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'creating a new tag from the picker sheet assigns it immediately',
      (tester) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add tag'));
        await tester.pumpAndSettle();
        expect(find.text('No tags yet'), findsOneWidget);

        await tester.tap(find.text('Create tag'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Push');
        await tester.pump();
        await tester.tap(find.widgetWithText(FilledButton, 'Create'));
        await tester.pumpAndSettle();

        final tags = await db.select(db.workoutTags).get();
        expect(tags.single.name, 'Push');
        final links = await db.select(db.workoutTagLinks).get();
        expect(links.single.tagId, tags.single.id);
        expect(find.widgetWithText(FilterChip, 'Push'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'the tag row is hidden entirely when showTags is off (S-17)',
      (tester) async {
        await db
            .into(db.appSettingsTable)
            .insert(
              AppSettingsTableCompanion.insert(
                id: 'singleton',
                showTags: const Value(false),
                updatedAt: '2026-07-19T00:00:00Z',
              ),
            );
        await _seedTag(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        expect(find.text('Add tag'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );
  });

  group('reorder exercises (Stage 3, S-03 drag handle + "⋮ → Вверх/Вниз")', () {
    testWidgets(
      '"Move up" in the exercise card menu swaps it with the previous card',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat');
        await _seedExercise(db, id: 'bench', name: 'Bench Press');
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();

        var order =
            await (db.select(db.workoutExercises)
                  ..orderBy([(we) => OrderingTerm.asc(we.orderIndex)]))
                .get();
        expect(order.map((we) => we.exerciseId), ['squat', 'bench']);

        // The second card (Bench Press, last -> no "Move down") moves up.
        await tester.tap(find.byIcon(Icons.more_vert).last);
        await tester.pumpAndSettle();
        expect(find.text('Move down'), findsNothing);
        await tester.tap(find.text('Move up'));
        await tester.pumpAndSettle();

        order = await (db.select(db.workoutExercises)
              ..orderBy([(we) => OrderingTerm.asc(we.orderIndex)]))
            .get();
        expect(order.map((we) => we.exerciseId), ['bench', 'squat']);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'the first card\'s menu has no "Move up" action',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat');
        await _seedExercise(db, id: 'bench', name: 'Bench Press');
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bench Press'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert).first);
        await tester.pumpAndSettle();

        expect(find.text('Move up'), findsNothing);
        expect(find.text('Move down'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );
  });
}
