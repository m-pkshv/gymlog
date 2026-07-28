import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/data/database.dart' hide Exercise;
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/template_editor/screen.dart';
import 'package:gymlog/features/template_editor/widgets/template_exercise_card.dart';
import 'package:gymlog/features/template_editor/widgets/template_set_row.dart';
import 'package:gymlog/features/templates/screen.dart';
import 'package:gymlog/features/workout_editor/add_exercise_screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/features/workout_editor/widgets/comment_field.dart';
import 'package:gymlog/core/widgets/numeric_stepper_field.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/more/templates` + `/workout/:workoutId` slice of the real
/// router (S-12/S-13, Stage 5; the workout route is only reached from
/// "Создать тренировку", TS 8 section 8) -- a self-contained harness rather
/// than pulling in all 5 tabs.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/more/templates',
    routes: [
      GoRoute(
        path: '/more/templates',
        builder: (_, _) => const TemplateListScreen(),
        routes: [
          GoRoute(
            path: ':templateId',
            builder: (_, state) => TemplateEditorScreen(
              templateId: state.pathParameters['templateId']!,
            ),
            routes: [
              GoRoute(
                path: 'add-exercise',
                builder: (_, state) => AddExerciseScreen(
                  addExerciseRoute:
                      '/more/templates/${state.pathParameters['templateId']}/add-exercise',
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
        ],
      ),
      GoRoute(
        path: '/workout/:workoutId',
        builder: (_, state) => WorkoutEditorScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
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

/// Same rationale as the other feature flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// FAB -> create-template dialog -> "Create", ending in the editor.
Future<void> _createTemplateViaFab(WidgetTester tester, {String name = 'Leg day'}) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)),
    name,
  );
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, 'Create'));
  await tester.pumpAndSettle();
}

/// Taps set [setIndex] (0-based, in list order) to expand it, revealing its
/// `NumericStepperField`s -- mirrors `workout_editor_flow_test.dart`'s
/// `_expandSet`.
Future<void> _expandTemplateSet(WidgetTester tester, {int setIndex = 0}) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(TemplateSetRow).at(setIndex),
          matching: find.byType(InkWell),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

/// Types [text] into the [fieldIndex]-th `NumericStepperField` of set
/// [setIndex] (already expanded via [_expandTemplateSet]) through its
/// tap-to-edit precise-entry dialog -- mirrors
/// `workout_editor_flow_test.dart`'s `_enterStepperValue`.
Future<void> _enterTemplateStepperValue(
  WidgetTester tester, {
  required String text,
  int setIndex = 0,
  int fieldIndex = 0,
}) async {
  final stepper = find
      .descendant(
        of: find.byType(TemplateSetRow).at(setIndex),
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

/// The [index]-th `CommentField`'s underlying `TextField` -- index 0 is the
/// template name field, index 1 the template comment field, both always
/// placed *before* any exercise card in `_EditorBody`'s `Column`, so these
/// two indices stay valid regardless of how many exercise cards (each with
/// its own `CommentField` again, Stage 11, owner-reported) are on screen.
Finder _commentField(int index) =>
    find.descendant(of: find.byType(CommentField).at(index), matching: find.byType(TextField));

/// The [exerciseIndex]-th exercise card's own `CommentField` `TextField`.
Finder _exerciseCommentField(int exerciseIndex) => find.descendant(
  of: find.descendant(
    of: find.byType(TemplateExerciseCard).at(exerciseIndex),
    matching: find.byType(CommentField),
  ),
  matching: find.byType(TextField),
);

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('empty state shows the create action', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No templates yet'), findsOneWidget);
    expect(find.text('Create template'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'the FAB creates a template and opens the editor (TS 8, D-16)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);

      expect(find.byType(TemplateEditorScreen), findsOneWidget);
      final templates = await db.select(db.workoutTemplates).get();
      expect(templates.single.name, 'Leg day');
      expect(templates.single.isArchived, isFalse);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the list shows the template name and exercise count after adding one',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsOneWidget);
      expect(find.text('1 exercise'), findsOneWidget);
      // Stage 10 redesign: rows are wrapped in a Card, matching History/
      // Today/Exercises.
      expect(
        find.ancestor(of: find.text('Leg day'), matching: find.byType(Card)),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'entering a plan value through the stepper dialog commits immediately, '
    'no debounce (Stage 10 redesign of TS 5)',
    (tester) async {
      // Same rationale as the workout editor's identical test: the
      // redesigned stepper commits on dialog-save, there's no partial-
      // keystroke phase to debounce -- replaces the pre-redesign test that
      // exercised the debounce window on a set field's `TextField`, which
      // no longer exists in `TemplateSetRow`.
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      await _expandTemplateSet(tester);
      await _enterTemplateStepperValue(tester, text: '100', fieldIndex: 0);

      final sets = await db.select(db.templateSets).get();
      expect(sets.single.plannedWeightKg, 100);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the duplicate-set button appears only once the last set has a planned '
    'value, and copies it into a new set (Stage 10, owner-reported)',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.content_copy), findsNothing);

      await _expandTemplateSet(tester);
      await _enterTemplateStepperValue(tester, text: '100', fieldIndex: 0);
      await _enterTemplateStepperValue(tester, text: '5', fieldIndex: 1);

      expect(find.byIcon(Icons.content_copy), findsOneWidget);

      await tester.tap(find.byIcon(Icons.content_copy));
      await tester.pumpAndSettle();

      final sets = await db.select(db.templateSets).get()
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      expect(sets, hasLength(2));
      expect(sets[0].plannedWeightKg, 100.0, reason: 'the typed value survived the reload');
      expect(sets[0].plannedReps, 5);
      expect(sets[1].plannedWeightKg, 100.0);
      expect(sets[1].plannedReps, 5);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('editing the template name debounces the write, then autosaves', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await _createTemplateViaFab(tester);

    await tester.enterText(_commentField(0), 'Leg day v2');
    await tester.pump();

    var templates = await db.select(db.workoutTemplates).get();
    expect(templates.single.name, 'Leg day', reason: 'not flushed yet');

    await tester.pump(autosaveDebounce + const Duration(milliseconds: 50));
    templates = await db.select(db.workoutTemplates).get();
    expect(templates.single.name, 'Leg day v2');

    await _unmountAndFlush(tester);
  });

  testWidgets('editing the template comment debounces the write, then autosaves', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await _createTemplateViaFab(tester);

    await tester.enterText(_commentField(1), 'Heavy squats');
    await tester.pump();

    var templates = await db.select(db.workoutTemplates).get();
    expect(templates.single.comment, isNull, reason: 'not flushed yet');

    await tester.pump(autosaveDebounce + const Duration(milliseconds: 50));
    templates = await db.select(db.workoutTemplates).get();
    expect(templates.single.comment, 'Heavy squats');

    await _unmountAndFlush(tester);
  });

  testWidgets(
    "editing an exercise's own comment debounces the write, then autosaves, "
    'independently of the template-level comment (Stage 11, owner-reported: '
    'mirrors the same fix in the workout editor)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.enterText(_exerciseCommentField(0), 'Elbow felt off');
      await tester.pump();

      var templateExercises = await db.select(db.templateExercises).get();
      expect(
        templateExercises.single.comment,
        isNull,
        reason: 'not flushed yet',
      );

      await tester.pump(autosaveDebounce + const Duration(milliseconds: 50));
      templateExercises = await db.select(db.templateExercises).get();
      expect(templateExercises.single.comment, 'Elbow felt off');

      final templates = await db.select(db.workoutTemplates).get();
      expect(templates.single.comment, isNull);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'delete set (Stage 10, owner-reported): the delete icon soft-deletes a '
    'set, renumbers the rest, and "Undo" restores it',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
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
      var sets = await db.select(db.templateSets).get();
      expect(sets, hasLength(2));
      var active = sets.where((s) => !s.isDeleted).toList();
      expect(active, hasLength(1));
      expect(active.single.setNumber, 1, reason: 'renumbered contiguously');

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      sets = await db.select(db.templateSets).get();
      active = sets.where((s) => !s.isDeleted).toList();
      expect(active, hasLength(2));
      final numbers = active.map((s) => s.setNumber).toList()..sort();
      expect(numbers, [1, 2]);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'collapse exercise (Stage 10, owner-reported): tapping the header hides '
    'sets, keeping the name; tapping again expands it',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      expect(find.byType(TemplateSetRow), findsOneWidget);
      expect(find.text('Add set'), findsOneWidget);

      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget, reason: 'name stays visible');
      expect(find.byType(TemplateSetRow), findsNothing);
      expect(find.text('Add set'), findsNothing);

      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(find.byType(TemplateSetRow), findsOneWidget);
      expect(find.text('Add set'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'reorder: "Move up" in the second exercise card swaps it with the first',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await _seedExercise(db, id: 'bench', name: 'Bench Press');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move up'));
      await tester.pumpAndSettle();

      final exercises =
          await (db.select(db.templateExercises)
                ..orderBy([(e) => OrderingTerm.asc(e.orderIndex)]))
              .get();
      expect(exercises.map((e) => e.exerciseId).toList(), ['bench', 'squat']);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"⋮ → Delete exercise" soft-deletes it, hides it from the list, and '
    'shows an Undo snackbar (Stage 10, owner-reported)',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await _seedExercise(db, id: 'bench', name: 'Bench Press');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete exercise'));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsNothing);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Exercise deleted'), findsOneWidget);

      final bench = (await db.select(
        db.templateExercises,
      ).get()).singleWhere((e) => e.exerciseId == 'bench');
      expect(bench.isDeleted, isTrue);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Bench Press'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"⋮ → Edit exercise" opens the full catalog edit form and saves '
    'changes everywhere (Stage 10, owner-reported)',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
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
      final exercise = (await db.select(
        db.exercises,
      ).get()).singleWhere((r) => r.id == 'squat');
      expect(exercise.name, 'Back Squat');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the menu has no "Edit exercise" action for a built-in exercise '
    '(Stage 10, owner-reported)',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat', isBuiltIn: true);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit exercise'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'deleting a template shows an Undo snackbar; "Undo" restores it',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await _createTemplateViaFab(tester);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsNothing);
      expect(find.text('Template deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsOneWidget);
      final templates = await db.select(db.workoutTemplates).get();
      expect(templates.single.isDeleted, isFalse);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('archiving a template hides it from the default list', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await _createTemplateViaFab(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsNothing);
    expect(find.text('No templates yet'), findsOneWidget);
    final templates = await db.select(db.workoutTemplates).get();
    expect(templates.single.isArchived, isTrue);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    '"Create workout" copies the template into a new draft and opens it '
    '(Stage 5, TS 8 section 8, DM-1)',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create workout'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);

      final workouts = await db.select(db.workouts).get();
      expect(workouts.single.name, 'Leg day');
      expect(workouts.single.status, 'draft');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    '"Duplicate" clones the template under a new name and opens the copy '
    '(04_UI_UX_SPEC.md section 5)',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(find.text('Duplicate template'), findsOneWidget);
      final nameField = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      );
      expect(tester.widget<TextField>(nameField).controller!.text, 'Leg day');
      await tester.enterText(nameField, 'Leg day copy');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.byType(TemplateEditorScreen), findsOneWidget);

      final templates = await db.select(db.workoutTemplates).get();
      expect(templates, hasLength(2));
      final copy = templates.firstWhere((t) => t.name == 'Leg day copy');

      final templateExercises = await (db.select(
        db.templateExercises,
      )..where((te) => te.templateId.equals(copy.id))).get();
      expect(templateExercises, hasLength(1));

      // The source template is untouched.
      final original = templates.firstWhere((t) => t.name == 'Leg day');
      expect(original.isDeleted, isFalse);

      await _unmountAndFlush(tester);
    },
  );
}
