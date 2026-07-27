import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/core/widgets/bottom_nav_bar.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/today/screen.dart';
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
    'finishing a workout started from "Сегодня" and tapping "Готово" leaves '
    'a clean Today root behind, not the stale summary (Stage 10, '
    'owner-reported)',
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

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryScreen), findsOneWidget);

      // The regression: returning to "Сегодня" used to still show the
      // finished workout's summary screen (with its own "Готово" button)
      // instead of the Today root, because the editor/summary had been
      // `push`ed onto Today's own branch Navigator rather than History's.
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.byType(TodayScreen), findsOneWidget);
      expect(find.byType(WorkoutSummaryScreen), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the bottom nav bar is hidden on the active workout\'s own editor '
    'screen, shown again after leaving it (Stage 10, owner-reported)',
    (tester) async {
      await WorkoutRepositoryImpl(db).createDraft(date: DateTime.now());

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      // Today (not History, which hides drafts by default, Stage 3) shows
      // the draft's own card straight away.
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(
        find.byType(BottomNavBar),
        findsOneWidget,
        reason: 'still a draft, not yet inProgress',
      );

      await tester.tap(find.byKey(const ValueKey('workout-status-cta')));
      await tester.pumpAndSettle();

      expect(
        find.byType(BottomNavBar),
        findsNothing,
        reason: 'inProgress now, hidden for more room for the sets list',
      );

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(
        find.byType(BottomNavBar),
        findsOneWidget,
        reason: 'left the active workout\'s screen, nav bar returns',
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
