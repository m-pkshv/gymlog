import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/core/date_format.dart';
import 'package:gymlog/core/widgets/completion_toggle.dart';
import 'package:gymlog/core/widgets/numeric_stepper_field.dart';
import 'package:gymlog/data/database.dart' hide Exercise;
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/template_editor/screen.dart';
import 'package:gymlog/features/workout_editor/add_exercise_screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/features/workout_editor/widgets/comment_field.dart';
import 'package:gymlog/features/workout_editor/widgets/exercise_card.dart';
import 'package:gymlog/features/workout_editor/widgets/set_row.dart';
import 'package:gymlog/features/workout_summary/screen.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/l10n/app_localizations.dart';
import 'package:gymlog/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

/// Mirrors the subset of `app/router.dart` the workout editor needs (S-03,
/// Stage 1) — a self-contained harness rather than pulling in all 5 tabs.
/// [notificationService], if supplied, overrides `notificationServiceProvider`
/// (Stage 4, TS 7.3) — only the tests that specifically verify notification
/// orchestration need to pass one; every other test relies on the
/// provider's own safe, try/catch-guarded default.
Widget _appUnderTest(
  AppDatabase db, {
  NotificationService? notificationService,
}) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(
        path: '/workout/:workoutId',
        builder: (_, state) =>
            WorkoutEditorScreen(workoutId: state.pathParameters['workoutId']!),
        routes: [
          GoRoute(
            path: 'summary',
            builder: (_, state) => WorkoutSummaryScreen(
              workoutId: state.pathParameters['workoutId']!,
            ),
          ),
          GoRoute(
            path: 'add-exercise',
            builder: (_, state) => AddExerciseScreen(
              addExerciseRoute:
                  '/workout/${state.pathParameters['workoutId']}/add-exercise',
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const CreateExerciseScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'edit-exercise/:exerciseId',
            builder: (_, state) =>
                CreateExerciseScreen(exercise: state.extra as Exercise),
          ),
        ],
      ),
      GoRoute(
        path: '/more/templates/:templateId',
        builder: (_, state) => TemplateEditorScreen(
          templateId: state.pathParameters['templateId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      if (notificationService != null)
        notificationServiceProvider.overrideWithValue(notificationService),
    ],
    child: MaterialApp.router(
      theme: buildLightTheme(),
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
  bool isBuiltIn = false,
}) {
  return db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: name,
          exerciseType: type.name,
          isBuiltIn: Value(isBuiltIn),
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

/// Mocked at the `NotificationService` level, not the plugin level (Stage
/// 4, TS 7.3) -- the interesting logic under test is the screen's
/// orchestration (when to show the rationale dialog, when to
/// schedule/cancel), not `flutter_local_notifications`' own platform
/// channel dispatch, which needs a real device to verify meaningfully.
class MockNotificationService extends Mock implements NotificationService {}

void _stubNotificationServiceDefaults(
  MockNotificationService service, {
  bool hasRequestedPermission = true,
}) {
  when(
    () => service.hasRequestedPermission(),
  ).thenAnswer((_) async => hasRequestedPermission);
  when(() => service.markPermissionRequested()).thenAnswer((_) async {});
  when(() => service.requestPermission()).thenAnswer((_) async {});
  when(() => service.areNotificationsEnabled()).thenAnswer((_) async => true);
  when(
    () => service.scheduleRestTimerEndNotification(
      title: any(named: 'title'),
      body: any(named: 'body'),
      endsAtUtc: any(named: 'endsAtUtc'),
    ),
  ).thenAnswer((_) async {});
  when(() => service.cancelRestTimerEndNotification()).thenAnswer((_) async {});
}

/// The "⋮" menu icon on the exercise card titled [exerciseName] --
/// identified by ancestry rather than list position, since
/// `find.byIcon(Icons.more_vert).first/.last` is unreliable once cards
/// grow tall enough to need scrolling.
Finder _exerciseCardMenuButton(String exerciseName) => find.descendant(
  of: find.ancestor(of: find.text(exerciseName), matching: find.byType(Card)),
  matching: find.byIcon(Icons.more_vert),
);

/// The redesigned status control's big primary CTA button (Stage 10:
/// replaced the old status chip's dropdown menu) and its "⋮" menu of the
/// *other* transitions (`WorkoutStatusMenu`) plus delete -- both keyed
/// (`screen.dart`) so they're unambiguous regardless of what the CTA's
/// label currently reads.
Finder get _statusCta => find.byKey(const ValueKey('workout-status-cta'));
Finder get _statusMenu => find.byKey(const ValueKey('workout-status-menu'));

/// The secondary "Запланировать" CTA next to [_statusCta] -- only rendered
/// for a draft (Stage 10 redesign, owner-reported: used to be reachable
/// only from the "⋮" menu).
Finder get _secondaryStatusCta =>
    find.byKey(const ValueKey('workout-status-secondary-cta'));

/// Taps set [setIndex] (0-based, in list order) to expand it, revealing its
/// `NumericStepperField`s (Stage 10 redesign: replaced the old always-
/// visible plan/fact `TextField` pair per field). A no-op if it's already
/// expanded is fine for these tests -- each only expands a given set once.
Future<void> _expandSet(WidgetTester tester, {int setIndex = 0}) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(SetRow).at(setIndex),
          matching: find.byType(InkWell),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

/// Types [text] into the [fieldIndex]-th `NumericStepperField` of set
/// [setIndex] (already expanded via [_expandSet]) through its tap-to-edit
/// precise-entry dialog -- the steppers' `+`/`-` alone can't reach an
/// arbitrary value in a test without dozens of taps.
Future<void> _enterStepperValue(
  WidgetTester tester, {
  required String text,
  int setIndex = 0,
  int fieldIndex = 0,
}) async {
  final stepper = find
      .descendant(
        of: find.byType(SetRow).at(setIndex),
        matching: find.byType(NumericStepperField),
      )
      .at(fieldIndex);
  await tester.tap(
    find.descendant(
      of: stepper,
      matching: find.byKey(const ValueKey('numeric-stepper-value')),
    ),
  );
  await tester.pumpAndSettle();
  // Scoped to the dialog -- a bare `find.byType(TextField)` is ambiguous
  // against the screen's own workout-comment field, still in the tree
  // underneath the modal barrier.
  await tester.enterText(
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    ),
    text,
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

/// The workout-level `CommentField`'s underlying `TextField` -- exercise
/// cards have their own `CommentField` too again (Stage 11, owner-
/// reported), always placed *before* the workout's own one in the
/// `CustomScrollView` (each `ExerciseCard`, then "+ Добавить упражнение",
/// then the workout comment last), so `.last` reliably picks the workout
/// one regardless of how many exercises/exercise-comments are on screen.
Finder get _workoutCommentField => find.descendant(
  of: find.byType(CommentField).last,
  matching: find.byType(TextField),
);

/// The [exerciseIndex]-th exercise card's own `CommentField` `TextField`.
Finder _exerciseCommentField(int exerciseIndex) => find.descendant(
  of: find.descendant(
    of: find.byType(ExerciseCard).at(exerciseIndex),
    matching: find.byType(CommentField),
  ),
  matching: find.byType(TextField),
);

/// The rename-workout dialog's `TextField` — scoped to `AlertDialog`, same
/// reasoning as the numeric-stepper dialog above: a bare
/// `find.byType(TextField)` is ambiguous against the screen's own
/// workout-comment field, still in the tree underneath the modal barrier.
Finder get _renameDialogField => find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byType(TextField),
);

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
    'the add-exercise picker has a search field that narrows the catalog '
    '(Stage 10, owner-reported)',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await _seedExercise(db, id: 'bench', name: 'Bench Press');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Bench');
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Squat'), findsNothing);

      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

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
    'the duplicate-set button appears only once the last set has a planned '
    'value, and copies it into a new set (Stage 10, owner-reported)',
    (tester) async {
      // The expanded set row (steppers) pushes the duplicate-set button
      // past a default-sized viewport's fold -- widen it so the tap below
      // lands on it directly instead of an off-screen target.
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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

      expect(find.byIcon(Icons.content_copy), findsNothing);

      // Weight, kg then Reps: the strength exercise's two plan steppers
      // (the workout hasn't started yet, so these edit the *planned*
      // value).
      await _expandSet(tester);
      await _enterStepperValue(tester, text: '100', fieldIndex: 0);
      await _enterStepperValue(tester, text: '5', fieldIndex: 1);

      expect(find.byIcon(Icons.content_copy), findsOneWidget);

      await tester.tap(find.byIcon(Icons.content_copy));
      await tester.pumpAndSettle();

      final sets = await db.select(db.exerciseSets).get()
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      expect(sets, hasLength(2));
      expect(
        sets[0].plannedWeightKg,
        100.0,
        reason: 'the typed value survived the reload',
      );
      expect(sets[0].plannedReps, 5);
      expect(sets[1].plannedWeightKg, 100.0);
      expect(sets[1].plannedReps, 5);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'entering a plan value through the stepper dialog commits immediately, '
    'no debounce (Stage 10 redesign of TS 5)',
    (tester) async {
      // TS 5's debounce/no-data-loss guarantee is about text-field typing;
      // the redesigned stepper commits each discrete tap/dialog-save the
      // moment it happens (there's no partial-keystroke phase to debounce)
      // -- if anything a *stronger* guarantee than before, not a weaker
      // one. This replaces the two pre-redesign tests that specifically
      // exercised the debounce window on a set field's `TextField`, which
      // no longer exists.
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

      await _expandSet(tester);
      await _enterStepperValue(tester, text: '100', fieldIndex: 0);

      // No `pump(autosaveDebounce)` wait at all -- the value is already in
      // the database right after the dialog closes.
      final sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, 100.0);

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

    // Plan weight, then plan reps, while still a draft (the steppers edit
    // *planned* values before the workout starts). The done checkbox only
    // shows up once `inProgress` (Stage 10 redesign: no "done" concept
    // before the workout has actually started) -- DM 6.7's "✓ copies plan
    // into an empty fact" only makes sense at that point anyway.
    await _expandSet(tester);
    await _enterStepperValue(tester, text: '60', fieldIndex: 0);
    await _enterStepperValue(tester, text: '10', fieldIndex: 1);

    await tester.tap(_statusCta);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CompletionToggle).last);
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
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();
      expect(find.text('In progress'), findsOneWidget);

      var workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.inProgress.name);
      expect(workouts.single.startedAt, isNotNull);

      // Status chip -> menu -> "Finish" (inProgress -> completed).
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();
      // TS 7.2 step 6: finishing replaces the editor with the S-05 summary.
      expect(find.byType(WorkoutSummaryScreen), findsOneWidget);

      workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.completed.name);
      await _unmountAndFlush(tester);
    },
  );

  group('finish confirmation for incomplete sets (Stage 4, TS 7.2 step 6)', () {
    testWidgets(
      'shows a confirmation for an incomplete working set; "Cancel" keeps '
      'it inProgress, confirming completes it',
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

        await tester.tap(_statusCta);
        await tester.pumpAndSettle();

        await tester.tap(_statusCta);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Finish workout?'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('In progress'), findsOneWidget);
        expect(
          (await db.select(db.workouts).get()).single.status,
          WorkoutStatus.inProgress.name,
        );

        await tester.tap(_statusCta);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Finish'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutSummaryScreen), findsOneWidget);
        expect(
          (await db.select(db.workouts).get()).single.status,
          WorkoutStatus.completed.name,
        );

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('a completed working set does not trigger the confirmation', (
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

      // The done checkbox only exists once inProgress (Stage 10
      // redesign) -- start first, then mark it done.
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CompletionToggle).last); // mark the set done
      await tester.pumpAndSettle();
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(WorkoutSummaryScreen), findsOneWidget);

      await _unmountAndFlush(tester);
    });
  });

  testWidgets(
    'the workout timer shows Pause while running and Play once paused '
    '(Stage 4, TS 7.1)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsNothing);

      final workoutId = (await db.select(db.workouts).get()).single.id;

      await tester.tap(find.byIcon(Icons.pause_circle_outline));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsNothing);
      var state = await (db.select(
        db.activeWorkoutStates,
      )..where((s) => s.workoutId.equals(workoutId))).getSingle();
      expect(state.isPaused, isTrue);

      await tester.tap(find.byIcon(Icons.play_circle_outline));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
      state = await (db.select(
        db.activeWorkoutStates,
      )..where((s) => s.workoutId.equals(workoutId))).getSingle();
      expect(state.isPaused, isFalse);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('the rest timer starts automatically when a set is marked done, '
      '"+15 s" extends it, and "Skip" clears it (Stage 4, TS 7.2 step 2)', (
    tester,
  ) async {
    // Production seeds this singleton row at app startup (main.dart);
    // this harness doesn't, so it's seeded here directly -- same
    // approach as the "showTags is off" test above.
    await db
        .into(db.appSettingsTable)
        .insert(
          AppSettingsTableCompanion.insert(
            id: 'singleton',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
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

    await tester.tap(_statusCta);
    await tester.pumpAndSettle();

    expect(find.text('REST'), findsNothing);

    await tester.tap(find.byType(CompletionToggle).last);
    await tester.pumpAndSettle();

    // Stage 10 redesign: RestTimerCard's label is uppercased ("REST",
    // DESIGN.md section 1's emphasis treatment for time-sensitive text).
    expect(find.text('REST'), findsOneWidget);
    final workoutId = (await db.select(db.workouts).get()).single.id;
    var state = await (db.select(
      db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId))).getSingle();
    expect(state.restTimerDurationSec, 120); // Q-4 default
    final endsAtBeforeAdjust = state.restTimerEndsAtUtc!;

    await tester.tap(find.byTooltip('+15 s'));
    await tester.pumpAndSettle();
    state = await (db.select(
      db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId))).getSingle();
    // Stage 10, owner-reported: `restTimerDurationSec` (RestTimerCard's
    // fixed fill-speed denominator) no longer grows with "+15 s" -- only
    // the deadline moves, so the bar's current position shifts instead
    // of its future fill speed changing.
    expect(state.restTimerDurationSec, 120);
    expect(
      DateTime.parse(
        state.restTimerEndsAtUtc!,
      ).difference(DateTime.parse(endsAtBeforeAdjust)).inSeconds,
      15,
    );

    // Stage 10 redesign: "Skip" is now an icon-only button (Icons.
    // skip_next), no visible text label.
    await tester.tap(find.byTooltip('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('REST'), findsNothing);
    state = await (db.select(
      db.activeWorkoutStates,
    )..where((s) => s.workoutId.equals(workoutId))).getSingle();
    expect(state.restTimerEndsAtUtc, isNull);

    await _unmountAndFlush(tester);
  });

  group('notifications (Stage 4, TS 7.3)', () {
    late MockNotificationService notificationService;

    setUp(() {
      notificationService = MockNotificationService();
      _stubNotificationServiceDefaults(notificationService);
    });

    Future<void> startWorkoutWithOneSet(WidgetTester tester) async {
      await db
          .into(db.appSettingsTable)
          .insert(
            AppSettingsTableCompanion.insert(
              id: 'singleton',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await _seedExercise(db);
      await tester.pumpWidget(
        _appUnderTest(db, notificationService: notificationService),
      );
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();
    }

    testWidgets(
      'marking a set done schedules the rest-end notification (permission '
      'already requested, no rationale dialog)',
      (tester) async {
        await startWorkoutWithOneSet(tester);

        await tester.tap(find.byType(CompletionToggle).last);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        verify(
          () => notificationService.scheduleRestTimerEndNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            endsAtUtc: any(named: 'endsAtUtc'),
          ),
        ).called(1);
        verifyNever(() => notificationService.requestPermission());

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'shows the rationale dialog on first use; "Allow" requests the OS '
      'permission and still schedules the notification',
      (tester) async {
        notificationService = MockNotificationService();
        _stubNotificationServiceDefaults(
          notificationService,
          hasRequestedPermission: false,
        );
        await startWorkoutWithOneSet(tester);

        await tester.tap(find.byType(CompletionToggle).last);
        await tester.pumpAndSettle();

        expect(find.text('Enable notifications?'), findsOneWidget);
        await tester.tap(find.text('Allow'));
        await tester.pumpAndSettle();

        verify(() => notificationService.markPermissionRequested()).called(1);
        verify(() => notificationService.requestPermission()).called(1);
        verify(
          () => notificationService.scheduleRestTimerEndNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            endsAtUtc: any(named: 'endsAtUtc'),
          ),
        ).called(1);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      '"Not now" on the rationale dialog skips the OS permission prompt but '
      'still schedules the notification',
      (tester) async {
        notificationService = MockNotificationService();
        _stubNotificationServiceDefaults(
          notificationService,
          hasRequestedPermission: false,
        );
        await startWorkoutWithOneSet(tester);

        await tester.tap(find.byType(CompletionToggle).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Not now'));
        await tester.pumpAndSettle();

        verify(() => notificationService.markPermissionRequested()).called(1);
        verifyNever(() => notificationService.requestPermission());
        verify(
          () => notificationService.scheduleRestTimerEndNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
            endsAtUtc: any(named: 'endsAtUtc'),
          ),
        ).called(1);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('"+15 s" reschedules the notification', (tester) async {
      await startWorkoutWithOneSet(tester);
      await tester.tap(find.byType(CompletionToggle).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('+15 s'));
      await tester.pumpAndSettle();

      verify(
        () => notificationService.scheduleRestTimerEndNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
          endsAtUtc: any(named: 'endsAtUtc'),
        ),
      ).called(2); // once on autostart, once on adjust

      await _unmountAndFlush(tester);
    });

    testWidgets('"Skip" cancels the notification', (tester) async {
      await startWorkoutWithOneSet(tester);
      await tester.tap(find.byType(CompletionToggle).last);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Skip'));
      await tester.pumpAndSettle();

      verify(
        () => notificationService.cancelRestTimerEndNotification(),
      ).called(1);

      await _unmountAndFlush(tester);
    });

    testWidgets('finishing the workout cancels any pending notification', (
      tester,
    ) async {
      await startWorkoutWithOneSet(tester);
      await tester.tap(find.byType(CompletionToggle).last);
      await tester.pumpAndSettle();

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      verify(
        () => notificationService.cancelRestTimerEndNotification(),
      ).called(1);

      await _unmountAndFlush(tester);
    });
  });

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
      initialLocation: '/workout/w1',
      routes: [
        GoRoute(
          path: '/workout/:workoutId',
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
          theme: buildLightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    // Stage 10 redesign: the collapsed row shows one combined value
    // ("weight × reps"), not separate per-field text.
    expect(find.text('100.0 × 5'), findsOneWidget);

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

    await tester.tap(_exerciseCardMenuButton('Squat'));
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

      await tester.tap(_exerciseCardMenuButton('Squat'));
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

      await tester.tap(_exerciseCardMenuButton('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy last performance'));
      await tester.pumpAndSettle();

      final sets = await db.select(db.exerciseSets).get();
      final newSet = sets.singleWhere((s) => s.workoutExerciseId != 'past_we');
      expect(newSet.plannedWeightKg, 60.0);
      expect(newSet.plannedReps, 8);
      // Stage 10 redesign: one combined value per row ("weight × reps").
      expect(find.text('60.0 × 8'), findsOneWidget);

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

      await tester.tap(_exerciseCardMenuButton('Squat'));
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

      // Stage 10 redesign, owner-reported: draft -> inProgress ("Start
      // workout") is the big primary CTA, and draft -> planned ("Schedule")
      // is now its own secondary CTA button right next to it, not buried in
      // the "⋮" menu anymore. DM 6.4.1's only draft transitions are exactly
      // these two, so both are excluded from the menu -- nothing is left
      // there but "Delete".
      expect(find.text('Start workout'), findsOneWidget);
      expect(find.text('Schedule'), findsOneWidget);

      await tester.tap(_statusMenu);
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Finish'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Skip'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"⋮ → Create template" saves the editor\'s own workout as a template, '
    'resetting completion, and opens it for review (Stage 10, owner-'
    'reported: any workout -- from a plan or from history -- can be saved '
    'as a template right from the editor, not only from a History card)',
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
      await _expandSet(tester);
      await _enterStepperValue(tester, text: '60', fieldIndex: 0);
      await _enterStepperValue(tester, text: '8', fieldIndex: 1);

      // The "done" checkbox only exists once `inProgress` (Stage 10
      // redesign) -- start the workout so there's something to mark
      // completed and then confirm the template doesn't carry it.
      await tester.tap(_statusCta);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CompletionToggle).last);
      await tester.pumpAndSettle();

      await tester.tap(_statusMenu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create template'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsNothing);
      expect(find.byType(TemplateEditorScreen), findsOneWidget);

      final templates = await db.select(db.workoutTemplates).get();
      expect(templates, hasLength(1));
      final templateExercises = await (db.select(
        db.templateExercises,
      )..where((te) => te.templateId.equals(templates.single.id))).get();
      expect(templateExercises, hasLength(1));
      final templateSets =
          await (db.select(db.templateSets)..where(
                (s) => s.templateExerciseId.equals(templateExercises.single.id),
              ))
              .get();
      expect(templateSets.single.plannedWeightKg, 60.0);
      expect(templateSets.single.plannedReps, 8);

      // The source workout itself is untouched -- still has its completed
      // set, this only ever creates a separate template.
      final sourceWorkouts = await db.select(db.workouts).get();
      expect(sourceWorkouts, hasLength(1));
      final sourceSets = await db.select(db.exerciseSets).get();
      expect(sourceSets.single.isCompleted, isTrue);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'deleting from the editor\'s "⋮" menu shows an Undo snackbar and leaves '
    'the editor (Stage 10, owner-reported: used to hardcode going to '
    'History, regardless of which tab the workout was opened from)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusMenu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsNothing);
      expect(find.byType(HistoryScreen), findsOneWidget);
      expect(find.text('Workout deleted'), findsOneWidget);

      final workouts = await db.select(db.workouts).get();
      expect(workouts.single.isDeleted, isTrue);

      await tester.pump(const Duration(seconds: 6));
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the secondary "Schedule" CTA moves a draft to planned and leaves the '
    'editor (Stage 10, owner-reported: previously stayed on screen)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_secondaryStatusCta);
      await tester.pumpAndSettle();

      // Owner-reported: scheduling is "I'm done with this workout for now",
      // same as finishing -- it should pop back to wherever the editor was
      // opened from (here, History via the FAB), not stay on the editor.
      expect(find.byType(WorkoutEditorScreen), findsNothing);
      expect(find.byType(HistoryScreen), findsOneWidget);

      final workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.planned.name);

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

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      await tester.tap(find.text(formatShortDate(DateTime.now())));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  group('rename workout (Stage 10, owner-reported)', () {
    testWidgets(
      'tapping the AppBar title opens a rename dialog pre-filled with the '
      'current name',
      (tester) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Workout'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Workout name'), findsOneWidget);
        final field = tester.widget<TextField>(_renameDialogField);
        expect(field.controller?.text, '');

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('saving a new name updates the title and persists it', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      final draftId = (await db.select(db.workouts).get()).single.id;

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Workout'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(_renameDialogField, 'Leg day');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Leg day'),
        ),
        findsOneWidget,
      );
      final row = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals(draftId))).getSingle();
      expect(row.name, 'Leg day');

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'clearing the name falls back to the default title and clears it in '
      'the database (DM 6.4)',
      (tester) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        final draftId = (await db.select(db.workouts).get()).single.id;

        // Give it a name first, so there's something to clear.
        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Workout'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(_renameDialogField, 'Leg day');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Leg day'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(_renameDialogField, '   ');
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Workout'),
          ),
          findsOneWidget,
        );
        final row = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals(draftId))).getSingle();
        expect(row.name, isNull);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('renaming works even while inProgress, unlike moving the date '
        '(DM 6.4.1)', (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Workout'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Workout name'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await _unmountAndFlush(tester);
    });

    testWidgets('"Cancel" leaves the name unchanged', (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);
      final draftId = (await db.select(db.workouts).get()).single.id;

      await tester.tap(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Workout'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(_renameDialogField, 'Leg day');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final row = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals(draftId))).getSingle();
      expect(row.name, isNull);

      await _unmountAndFlush(tester);
    });
  });

  group('active-workout conflict dialog (S-03, DM 6.4.1)', () {
    testWidgets(
      'starting a workout while another is inProgress shows the conflict '
      'dialog instead of a generic error',
      (tester) async {
        await _seedActiveWorkout(db);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(_statusCta);
        await tester.pumpAndSettle();

        expect(find.text('A workout is already in progress'), findsOneWidget);
        expect(find.text('Finish it'), findsOneWidget);
        expect(find.text('Cancel it'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('dismissing the dialog leaves both workouts untouched', (
      tester,
    ) async {
      await _seedActiveWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Draft'), findsOneWidget);
      final active = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals('active'))).getSingle();
      expect(active.status, 'inProgress');

      await _unmountAndFlush(tester);
    });

    testWidgets('"Finish it" completes the other workout and starts this one', (
      tester,
    ) async {
      await _seedActiveWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusCta);
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
    });

    testWidgets('"Cancel it" cancels the other workout and starts this one', (
      tester,
    ) async {
      await _seedActiveWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(_statusCta);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel it'));
      await tester.pumpAndSettle();

      expect(find.text('In progress'), findsOneWidget);
      final active = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals('active'))).getSingle();
      expect(active.status, 'cancelled');

      await _unmountAndFlush(tester);
    });
  });

  group('workout tags (Stage 3, S-03, DM 6.3/6.5)', () {
    testWidgets(
      'the tag row shows an icon-only "Add tag" trigger and no chip for an '
      'unassigned tag (Stage 10, owner-reported: icon instead of a labelled '
      'chip)',
      (tester) async {
        await _seedTag(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        expect(find.byTooltip('Add tag'), findsOneWidget);
        expect(find.text('Leg day'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('tapping an existing tag in the picker sheet assigns it', (
      tester,
    ) async {
      await _seedTag(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(find.byTooltip('Add tag'));
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
    });

    testWidgets(
      'the picker sheet has no "Create tag" button and its empty state '
      'points at the management screen (Stage 10, owner-reported: creating '
      'a tag moved to Ещё → Теги)',
      (tester) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byTooltip('Add tag'));
        await tester.pumpAndSettle();

        expect(
          find.text('No tags yet. Add some from More → Tags.'),
          findsOneWidget,
        );
        expect(find.text('Create tag'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'a tag chip in the picker sheet has no delete "x" of its own (Stage '
      '10, owner-reported: it used to be confused with unassigning the tag '
      'from this workout) -- deleting a tag now only happens from Ещё → '
      'Теги',
      (tester) async {
        await _seedTag(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.byTooltip('Add tag'));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.widgetWithText(FilterChip, 'Leg day'),
            matching: find.byIcon(Icons.close),
          ),
          findsNothing,
        );

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('the tag row is hidden entirely when showTags is off (S-17)', (
      tester,
    ) async {
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

      expect(find.byTooltip('Add tag'), findsNothing);

      await _unmountAndFlush(tester);
    });
  });

  group('collapse exercise (Stage 10, owner-reported)', () {
    testWidgets(
      'tapping the header collapses the card to just its name, hiding sets '
      'and the progression controls; tapping again expands it',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat');
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add set'));
        await tester.pumpAndSettle();

        expect(find.byType(SetRow), findsOneWidget);
        expect(find.text('Add set'), findsOneWidget);

        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        expect(
          find.text('Squat'),
          findsOneWidget,
          reason: 'name stays visible',
        );
        expect(find.byType(SetRow), findsNothing);
        expect(find.text('Add set'), findsNothing);

        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        expect(find.byType(SetRow), findsOneWidget);
        expect(find.text('Add set'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'collapsing one card does not affect the "⋮" menu of the same card',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat');
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        expect(_exerciseCardMenuButton('Squat'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );
  });

  group('reorder exercises (Stage 3, S-03 "⋮ → Вверх/Вниз")', () {
    testWidgets(
      '"Move up" in the exercise card menu swaps it with the previous card',
      (tester) async {
        // Both cards (each taller now with the progression segment) must
        // fit without scrolling for `ensureVisible`/tap below to land
        // reliably.
        tester.view.physicalSize = const Size(1080, 5000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

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

        var order = await (db.select(
          db.workoutExercises,
        )..orderBy([(we) => OrderingTerm.asc(we.orderIndex)])).get();
        expect(order.map((we) => we.exerciseId), ['squat', 'bench']);

        // The second card (Bench Press, last -> no "Move down") moves up.
        final benchMenu = _exerciseCardMenuButton('Bench Press');
        await tester.ensureVisible(benchMenu);
        await tester.tap(benchMenu);
        await tester.pumpAndSettle();
        expect(find.text('Move down'), findsNothing);
        await tester.tap(find.text('Move up'));
        await tester.pumpAndSettle();

        order = await (db.select(
          db.workoutExercises,
        )..orderBy([(we) => OrderingTerm.asc(we.orderIndex)])).get();
        expect(order.map((we) => we.exerciseId), ['bench', 'squat']);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('the first card\'s menu has no "Move up" action', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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

      final squatMenu = _exerciseCardMenuButton('Squat');
      await tester.ensureVisible(squatMenu);
      await tester.tap(squatMenu);
      await tester.pumpAndSettle();

      expect(find.text('Move up'), findsNothing);
      expect(find.text('Move down'), findsOneWidget);

      await _unmountAndFlush(tester);
    });
  });

  group('comments (Stage 3, S-03)', () {
    testWidgets(
      'editing the workout comment debounces the write, then autosaves',
      (tester) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.enterText(_workoutCommentField, 'Great session');
        await tester.pump();

        var workouts = await db.select(db.workouts).get();
        expect(workouts.single.comment, isNull, reason: 'not flushed yet');

        await tester.pump(autosaveDebounce + const Duration(milliseconds: 50));
        workouts = await db.select(db.workouts).get();
        expect(workouts.single.comment, 'Great session');

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      "editing an exercise's own comment debounces the write, then "
      'autosaves, independently of the workout-level comment (Stage 11, '
      'owner-reported: per-exercise comments were removed in the Stage 10 '
      'redesign, then asked back)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await _seedExercise(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        await tester.enterText(_exerciseCommentField(0), 'Elbow felt off');
        await tester.pump();

        var workoutExercises = await db.select(db.workoutExercises).get();
        expect(
          workoutExercises.single.comment,
          isNull,
          reason: 'not flushed yet',
        );

        await tester.pump(autosaveDebounce + const Duration(milliseconds: 50));
        workoutExercises = await db.select(db.workoutExercises).get();
        expect(workoutExercises.single.comment, 'Elbow felt off');

        // Untouched -- the exercise comment and the workout comment are
        // separate fields with their own independent debounce timers.
        final workouts = await db.select(db.workouts).get();
        expect(workouts.single.comment, isNull);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('entering a set value while the comment field still has an '
        'un-debounced edit saves that edit immediately and does not scroll '
        'back to the comment field afterwards (Stage 10, owner-reported: '
        'typing a set value used to jump the list back down to the comment)', (
      tester,
    ) async {
      // The exercise card is taller now that it has its own comment field
      // (Stage 11) below the sets table -- the default small test viewport
      // pushes the set's own InkWell (tapped by `_expandSet` below) far
      // enough that `tap()`'s computed offset lands off-screen instead.
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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

      await tester.enterText(_workoutCommentField, 'Felt strong today');
      // A longer, bounded pump (not `pumpAndSettle`, which would risk
      // running past `autosaveDebounce` and flushing the comment on its
      // own, defeating the point of this test) -- just enough for the
      // focus-gained scroll-into-view animation to finish, so the tap
      // below reliably lands on its target instead of a still-animating
      // layer above it.
      await tester.pump(const Duration(milliseconds: 300));
      var workouts = await db.select(db.workouts).get();
      expect(
        workouts.single.comment,
        isNull,
        reason: 'not flushed yet -- the debounce has not elapsed',
      );

      await _expandSet(tester);
      await _enterStepperValue(tester, text: '60', fieldIndex: 0);

      // The comment's own debounce timer never got the chance to fire
      // (no `tester.pump(autosaveDebounce)` above), so this only passes
      // if opening the stepper's precise-entry dialog itself dropped
      // focus from the comment field and flushed it immediately, the
      // same way tapping away from it always has.
      workouts = await db.select(db.workouts).get();
      expect(workouts.single.comment, 'Felt strong today');

      expect(
        tester.testTextInput.isVisible,
        isFalse,
        reason:
            'no field (in particular not the comment field) should be '
            'focused/editing once the precise-entry dialog closes',
      );

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'tapping a stepper\'s "+" button (no dialog involved) also saves an '
      'un-debounced comment edit and hides the keyboard (Stage 10, owner-'
      'reported: the fix had to cover any tap on a set, not just the '
      'precise-entry dialog)',
      (tester) async {
        // Same reasoning as the previous test -- the exercise card's own
        // comment field (Stage 11) makes it taller than the default small
        // test viewport comfortably fits.
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

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
        await _expandSet(tester);

        await tester.enterText(_workoutCommentField, 'Felt strong today');
        // A longer, bounded pump (not `pumpAndSettle`, which would risk
        // running past `autosaveDebounce` and flushing the comment on its
        // own, defeating the point of this test) -- just enough for the
        // focus-gained scroll-into-view animation to finish.
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester.testTextInput.isVisible,
          isTrue,
          reason: 'the comment field is focused and being edited',
        );

        // "Add set" -- an ordinary button on the same exercise card, not a
        // dialog and not a `NumericStepperField` -- proves the fix isn't
        // limited to the precise-entry dialog's own explicit unfocus call.
        // `ensureVisible` first: the focus-triggered scroll above can leave
        // this finder's cached geometry stale relative to the CustomScroll-
        // View's now-shifted position.
        final addSetButton = find.text('Add set');
        await tester.ensureVisible(addSetButton);
        await tester.pump();
        await tester.tap(addSetButton);
        await tester.pump();

        final workouts = await db.select(db.workouts).get();
        expect(workouts.single.comment, 'Felt strong today');
        expect(
          tester.testTextInput.isVisible,
          isFalse,
          reason:
              'tapping elsewhere on the exercise card should have hidden '
              'the keyboard along with the rest of the comment field\'s '
              'focus',
        );

        await _unmountAndFlush(tester);
      },
    );
  });

  group('delete set (Stage 10, owner-reported: replaced the set comment '
      'icon with a way to remove a planned set)', () {
    testWidgets(
      'tapping the delete icon on a set soft-deletes it, renumbers the '
      'remaining ones, and shows an Undo snackbar',
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
        await tester.tap(find.text('Add set'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Delete set').first);
        await tester.pumpAndSettle();

        expect(find.text('Set deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        final sets = await db.select(db.exerciseSets).get();
        expect(sets, hasLength(2));
        final active = sets.where((s) => !s.isDeleted).toList();
        expect(active, hasLength(1));
        expect(active.single.setNumber, 1, reason: 'renumbered contiguously');

        await tester.pump(const Duration(seconds: 6));
        await _unmountAndFlush(tester);
      },
    );

    testWidgets('"Undo" restores the deleted set with the original numbering', (
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
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete set').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      final sets = await db.select(db.exerciseSets).get();
      expect(sets.where((s) => !s.isDeleted), hasLength(2));
      final numbers = sets.map((s) => s.setNumber).toList()..sort();
      expect(numbers, [1, 2]);

      await _unmountAndFlush(tester);
    });
  });

  group('delete exercise (Stage 10, owner-reported: no way to remove an '
      'exercise from a workout)', () {
    testWidgets(
      '"⋮ → Delete exercise" soft-deletes it, hides it from the list, and '
      'shows an Undo snackbar',
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

        final benchMenu = _exerciseCardMenuButton('Bench Press');
        await tester.ensureVisible(benchMenu);
        await tester.tap(benchMenu);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete exercise'));
        await tester.pumpAndSettle();

        expect(find.text('Bench Press'), findsNothing);
        expect(find.text('Squat'), findsOneWidget);
        expect(find.text('Exercise deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        final rows = await db.select(db.workoutExercises).get();
        final bench = rows.singleWhere((r) => r.exerciseId == 'bench');
        expect(bench.isDeleted, isTrue);

        await tester.pump(const Duration(seconds: 6));
        await _unmountAndFlush(tester);
      },
    );

    testWidgets('"Undo" restores the deleted exercise', (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createDraftViaFab(tester);

      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      final squatMenu = _exerciseCardMenuButton('Squat');
      await tester.ensureVisible(squatMenu);
      await tester.tap(squatMenu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsNothing);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);
      final rows = await db.select(db.workoutExercises).get();
      expect(rows.single.isDeleted, isFalse);

      await _unmountAndFlush(tester);
    });
  });

  group('edit exercise (Stage 10, owner-reported: a plain rename wasn\'t '
      'enough -- the owner wanted the same full catalog edit form, without '
      'leaving the workout)', () {
    testWidgets(
      '"⋮ → Edit exercise" opens the full catalog edit form and saves '
      'changes everywhere',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat');
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        final menu = _exerciseCardMenuButton('Squat');
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit exercise'));
        await tester.pumpAndSettle();

        expect(find.byType(CreateExerciseScreen), findsOneWidget);

        await tester.enterText(
          find
              .descendant(
                of: find.byType(CreateExerciseScreen),
                matching: find.byType(TextField),
              )
              .first,
          'Back Squat',
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save'));
        await tester.pumpAndSettle();

        expect(find.byType(CreateExerciseScreen), findsNothing);
        expect(find.text('Back Squat'), findsOneWidget);
        final exercise = (await db.select(db.exercises).get()).singleWhere(
          (r) => r.id == 'squat',
        );
        expect(exercise.name, 'Back Squat');

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'the menu has no "Edit exercise" action for a built-in exercise',
      (tester) async {
        await _seedExercise(db, id: 'squat', name: 'Squat', isBuiltIn: true);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);

        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        final menu = _exerciseCardMenuButton('Squat');
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();

        expect(find.text('Edit exercise'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );
  });

  group('progression decision + stagnation hint (Stage 3, D-7, TS 9.4)', () {
    testWidgets(
      'selecting a progression decision segment persists it immediately, '
      'no debounce',
      (tester) async {
        await _seedExercise(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('↑'));
        await tester.pumpAndSettle();

        final workoutExercises = await db.select(db.workoutExercises).get();
        expect(workoutExercises.single.progressionDecision, 'increase');

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'the stagnation hint is hidden when there is no completed history yet',
      (tester) async {
        await _seedExercise(db);
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        await _createDraftViaFab(tester);
        await tester.tap(find.text('Add exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();

        expect(find.textContaining('without growth'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'the stagnation hint appears after finishing a workout that did not '
      'improve on the last completed occurrence',
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
        await tester.tap(find.text('Add set'));
        await tester.pumpAndSettle();

        await tester.tap(_statusCta); // draft -> inProgress
        await tester.pumpAndSettle();

        // Same weight/reps as the past occurrence (60 kg x 8) -- no growth.
        // Now that the workout is inProgress, the steppers edit the
        // *actual* value (Stage 10 redesign).
        await _expandSet(tester);
        await _enterStepperValue(tester, text: '60', fieldIndex: 0);
        await _enterStepperValue(tester, text: '8', fieldIndex: 1);

        await tester.tap(_statusCta); // attempt inProgress -> completed
        await tester.pumpAndSettle();
        // The set's actual values were entered directly without ticking
        // "✓", so it's still unmarked -- Stage 4's finish-with-incomplete-
        // sets confirmation (TS 7.2 step 6) is expected here.
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Finish'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 workout without growth'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );
  });

  testWidgets(
    'the exercise card shows the translated name when the app locale is Russian (DM 12)',
    (tester) async {
      await _seedExercise(db);
      await db
          .into(db.exerciseL10n)
          .insert(
            ExerciseL10nCompanion.insert(
              exerciseId: 'squat',
              locale: 'ru',
              name: 'Приседания',
            ),
          );
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await AppSettingsRepositoryImpl(db).setLocale(AppLocale.ru);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createDraftViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Приседания'));
      await tester.pumpAndSettle();

      expect(find.text('Приседания'), findsOneWidget);
      expect(find.text('Squat'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );
}
