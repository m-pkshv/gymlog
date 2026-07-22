import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/template_editor/screen.dart';
import 'package:gymlog/features/templates/screen.dart';
import 'package:gymlog/features/workout_editor/add_exercise_screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/features/workout_editor/widgets/comment_field.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/more/templates` + `/history/workout/:workoutId` slice of
/// the real router (S-12/S-13, Stage 5; the workout route is only reached
/// from "Создать тренировку", TS 8 section 8) -- a self-contained harness
/// rather than pulling in all 5 tabs.
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
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/history/workout/:workoutId',
        builder: (_, state) => WorkoutEditorScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
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

/// The [index]-th `CommentField`'s underlying `TextField` -- index 0 is the
/// template name field, index 1 the template comment field, 2+ each
/// exercise card's comment field in list order (same convention as
/// `workout_editor_flow_test.dart`).
Finder _commentField(int index) =>
    find.descendant(of: find.byType(CommentField).at(index), matching: find.byType(TextField));

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

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'adding a set and editing its planned fields autosaves after the debounce',
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

      final planFields = find.descendant(
        of: find.byType(Row),
        matching: find.byType(TextField),
      );
      await tester.enterText(planFields.first, '100');
      await tester.pump(const Duration(milliseconds: 200));

      var sets = await db.select(db.templateSets).get();
      expect(sets.single.plannedWeightKg, isNull, reason: 'still debouncing');

      await tester.pump(const Duration(milliseconds: 400));
      sets = await db.select(db.templateSets).get();
      expect(sets.single.plannedWeightKg, 100);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('the warmup checkbox writes immediately, no debounce', (
    tester,
  ) async {
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

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    final sets = await db.select(db.templateSets).get();
    expect(sets.single.isWarmup, isTrue);

    await _unmountAndFlush(tester);
  });

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
    'the drag handle has an accessible label, not just an icon (UX 11)',
    (tester) async {
      await _seedExercise(db, id: 'squat', name: 'Squat');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await _createTemplateViaFab(tester);
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Drag to reorder',
        ),
        findsOneWidget,
      );

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
