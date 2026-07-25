import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/active_workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/active_workout_state.dart';
import 'package:gymlog/features/history/screen.dart';
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

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
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

  testWidgets('no recovery banner when nothing is inProgress', (
    tester,
  ) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'shows a recovery banner when a workout is inProgress, and "Continue" '
    'opens it (Stage 4, TS 7.2 step 5)',
    (tester) async {
      final workout = await WorkoutRepositoryImpl(
        db,
      ).createDraft(date: DateTime(2026, 7, 21));
      await WorkoutRepositoryImpl(
        db,
      ).updateWorkout(workout.copyWith(status: WorkoutStatus.inProgress));
      final startedAt = DateTime.now().toUtc();
      await ActiveWorkoutRepositoryImpl(db).upsert(
        ActiveWorkoutState(
          workoutId: workout.id,
          startedAtUtc: startedAt,
          updatedAt: startedAt,
        ),
      );

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(find.textContaining('Workout in progress'), findsOneWidget);

      // Today's own "Продолжить" card for the same inProgress workout also
      // reads "Continue" (Stage 10) -- scope the tap to the banner
      // specifically, since that's what this test is about.
      await tester.tap(
        find.descendant(
          of: find.byType(MaterialBanner),
          matching: find.text('Continue'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsOneWidget);

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
