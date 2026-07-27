import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_template_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/core/widgets/bottom_nav_bar.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/history/template_picker_screen.dart';
import 'package:gymlog/features/today/screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/features/workout_summary/screen.dart';

import 'package:gymlog/app/router.dart';
import 'package:gymlog/main.dart';

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  late drift.AppDatabase db;

  setUp(() {
    db = drift.AppDatabase(NativeDatabase.memory());
    // `appRouter` (app/router.dart) is a module-level singleton `GoRouter` --
    // it's the same instance across every test in this file, so whatever
    // location the previous test's widget tree ended on (e.g. a workout
    // editor for an id that only existed in that test's own `db`) leaks
    // into the next test's fresh `pumpWidget`. Reset it before each test so
    // tests that need to start from a known screen aren't at the mercy of
    // whatever the previous test happened to navigate to.
    appRouter.go('/today');
  });

  tearDown(() async {
    await db.close();
  });

  Widget appUnderTest() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const GymLogApp(),
    );
  }

  testWidgets('GymLogApp shows the Today tab and a 5-item bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavBar), findsOneWidget);
    expect(find.byType(BottomNavBarItem), findsNWidgets(5));
    expect(find.text('Today'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('tapping a bottom nav destination switches tabs', (tester) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'tapping the already-active tab resets its stack to the root (Stage '
    '10, owner-reported)',
    (tester) async {
      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Templates'));
      await tester.pumpAndSettle();
      expect(
        find.text('Measurements'),
        findsNothing,
        reason: 'should be pushed into Templates, off the More root',
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(
        find.text('Measurements'),
        findsOneWidget,
        reason: 'tapping the active tab again should pop back to its root',
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'finishing a workout started from "Сегодня" and tapping "Готово" '
    'returns straight to Today, not History (Stage 10, owner-reported)',
    (tester) async {
      await WorkoutRepositoryImpl(db).createDraft(date: DateTime.now());

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      // Open the editor from the Today tab's own card (not History's).
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Stage 10 redesign: both transitions are now the big primary CTA
      // button, keyed unambiguously (`workout-status-cta`), not a status
      // chip's dropdown menu.
      await tester.tap(find.byKey(const ValueKey('workout-status-cta')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('workout-status-cta')));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutSummaryScreen), findsOneWidget);

      // Owner-reported: "Готово" used to hardcode `context.go('/history')`,
      // so finishing a workout opened from Today always landed on History
      // instead of back on Today -- the same "wrong tab on exit" bug as
      // deleting from the editor's own menu (`workout_editor/screen.dart`'s
      // `_deleteWorkout`) and creating a workout from a template. "Готово"
      // now pops instead (the editor `pushReplacement`d this screen in its
      // own spot in the stack, so popping reveals exactly what was
      // underneath -- Today itself here, not History).
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(HistoryScreen), findsNothing);
      expect(find.byType(WorkoutSummaryScreen), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'creating a workout from a template via "Сегодня", then finishing it, '
    'returns to "Сегодня", not "История" (Stage 10, owner-reported)',
    (tester) async {
      await WorkoutTemplateRepositoryImpl(db).create(name: 'Leg day');

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('From a template'));
      await tester.pumpAndSettle();
      // Owner-reported: `/template-source` used to be nested inside
      // History's own branch, so opening it from Today (`context.go`)
      // switched the active tab to History before the workout editor was
      // ever pushed -- the exact same class of bug as `/workout/:id`
      // before it was moved outside the shell, just one route "later" in
      // the flow. Now a top-level route too (`app/router.dart`'s top
      // comment), reached with `push`, so Today stays the active tab.
      expect(find.byType(HistoryScreen), findsNothing);

      await tester.tap(find.text('Leg day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutEditorScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('workout-status-cta')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('workout-status-cta')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // The picker `pushReplacement`d itself with the editor, which then
      // `pushReplacement`d itself with the summary (`create_workout_from_
      // template_flow.dart`'s `replaceCurrentRoute`) -- all three occupy
      // the same single slot in the stack, right on top of Today, so one
      // pop from "Готово" reveals Today directly.
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(HistoryScreen), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'creating a workout from a template via "Сегодня" and pressing back '
    'before finishing returns straight to "Сегодня", not the (now '
    'pointless) template picker (Stage 10, owner-reported side effect of '
    'the fix above)',
    (tester) async {
      await WorkoutTemplateRepositoryImpl(db).create(name: 'Leg day');

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('From a template'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leg day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(WorkoutEditorScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(WorkoutEditorScreen), findsNothing);
      expect(find.byType(TemplatePickerScreen), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'opening a workout from "Сегодня" and pressing back returns to '
    '"Сегодня", not "История" (Stage 10 redesign, owner-reported)',
    (tester) async {
      await WorkoutRepositoryImpl(db).createDraft(date: DateTime.now());

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);

      // Today (not History, which hides drafts by default, Stage 3) shows
      // the draft's own card straight away.
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsNothing);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // The regression: `/history/workout/:id` used to be nested inside
      // History's own branch, so opening it from any other tab (Today
      // included) forced `StatefulShellRoute` to switch the active tab to
      // History -- "back" then landed on History's root, not wherever the
      // workout was actually opened from.
      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(HistoryScreen), findsNothing);
      final todayTab = tester.widget<BottomNavBarItem>(
        find.widgetWithText(BottomNavBarItem, 'Today'),
      );
      expect(todayTab.selected, isTrue);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the workout editor has no bottom nav bar for any workout status, '
    'shown again after leaving it (Stage 10 redesign, owner-reported)',
    (tester) async {
      await WorkoutRepositoryImpl(db).createDraft(date: DateTime.now());

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavBar), findsOneWidget);

      // Today (not History, which hides drafts by default, Stage 3) shows
      // the draft's own card straight away.
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(
        find.byType(BottomNavBar),
        findsNothing,
        reason:
            '/workout/:id (app/router.dart) is a route outside the tab '
            'shell entirely -- its own Scaffold has no bottom nav to hide, '
            'for every status, not just inProgress',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.byType(BottomNavBar),
        findsOneWidget,
        reason: 'left the editor, back on the tab shell\'s own Scaffold',
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'AppSettings.locale = ru switches the rendered language on the fly '
    '(S-17, Stage 9)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await AppSettingsRepositoryImpl(db).setLocale(AppLocale.ru);

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Сегодня'), findsWidgets);
      expect(find.text('Today'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );
}
