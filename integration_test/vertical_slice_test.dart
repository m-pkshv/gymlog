import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/seed/seed_runner.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/main.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end run of the Stage 1 vertical slice (02_DEVELOPMENT_PLAN.md,
/// Stage 1 acceptance criteria) through the real `GymLogApp` widget tree —
/// same router, same screens, same providers as the shipped app. Only the
/// database is swapped for an in-memory one (still seeded exactly like
/// `main()` does) so the run is hermetic and repeatable instead of
/// depending on whatever is already on the test device.
///
/// Scenario: create a workout -> add an exercise (both an existing catalog
/// one and a newly-created one) -> add sets -> autosave -> "done" copies
/// plan into fact (DM 6.7) -> start -> finish -> the workout shows up in
/// History with the right exercise count.
/// Locates a sets-table number field by its `Semantics` label (S-03: each
/// `SetNumberField` is wrapped in `Semantics(label: '<field> Plan|Fact')`).
/// More robust than a `TextField` index, which is one typo away from
/// silently hitting the wrong plan/fact cell.
Finder _numberField(String semanticLabel) {
  return find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == semanticLabel,
    ),
    matching: find.byType(TextField),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('vertical slice: create, edit, finish, see in history', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await SeedRunner(db).run();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const GymLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Today -> History.
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('No completed workouts yet'), findsOneWidget);

    // FAB creates a draft and opens the editor (S-03).
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('No exercises added yet'), findsOneWidget);

    // Add an existing catalog exercise (seeded by SeedRunner, DM 12).
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Back Squat'));
    await tester.pumpAndSettle();
    expect(find.text('Barbell Back Squat'), findsOneWidget);

    // Create a new exercise from inside the editor and confirm it's added
    // immediately (Stage 1 manual check ★, 02_DEVELOPMENT_PLAN.md).
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Overhead Press');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Overhead Press'), findsOneWidget);

    // Add a set to Barbell Back Squat, fill plan, mark done -> facts copied
    // (DM 6.7). Fields are located by their semantic label rather than
    // TextField index -- with two plan/fact pairs per set, an index is one
    // typo away from silently writing into the wrong field.
    await tester.tap(find.text('Add set').first);
    await tester.pumpAndSettle();
    await tester.enterText(_numberField('Weight, kg Plan'), '80');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.enterText(_numberField('Reps Plan'), '5');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    // Start -> Finish (draft -> inProgress -> completed, workout_service),
    // via the status chip's menu (S-03, DM 6.4.1).
    await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(find.text('In progress'), findsOneWidget);

    await tester.tap(find.byType(PopupMenuButton<WorkoutStatus>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);

    // Back to History: the finished workout is listed with both exercises
    // counted.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('No completed workouts yet'), findsNothing);
    expect(find.textContaining('2 exercises'), findsOneWidget);

    // Reopen it from the list: the data entered earlier is still there
    // (S-03/DM 6.4.1 "close and reopen" scenario).
    await tester.tap(find.textContaining('2 exercises'));
    await tester.pumpAndSettle();
    expect(find.text('Barbell Back Squat'), findsOneWidget);
    // Plan and fact both show 80.0 kg / 5 reps -- "done" copied plan into
    // the empty fact fields (DM 6.7), and that survived the close+reopen.
    expect(find.text('80.0'), findsNWidgets(2));
    expect(find.text('5'), findsNWidgets(2));
  });
}
