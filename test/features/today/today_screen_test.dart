import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/history/copy_source_picker_screen.dart';
import 'package:gymlog/features/history/template_picker_screen.dart';
import 'package:gymlog/features/today/screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/today` + `/history/workout/:workoutId` +
/// `/history/copy-source` + `/history/template-source` slice of the real
/// router (S-01, Stage 9) -- the same destinations the quick actions and
/// the upcoming/continue cards push to.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/today',
    routes: [
      GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
      GoRoute(
        path: '/history/workout/:workoutId',
        builder: (_, state) => WorkoutEditorScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
      GoRoute(
        path: '/history/copy-source',
        builder: (_, _) => const CopySourcePickerScreen(),
      ),
      GoRoute(
        path: '/history/template-source',
        builder: (_, _) => const TemplatePickerScreen(),
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

/// Same rationale as the other flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

// Always in the future relative to whenever this suite actually runs, so
// `nextUpcomingWorkoutProvider`'s real `DateTime.now()` boundary never
// makes the test flaky around a real day-of-run edge case.
final _farFutureDate = DateTime(2099, 1, 1);

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl workouts;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'shows the empty state and quick actions when there is nothing '
    'upcoming or active',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('No workout planned today'), findsOneWidget);
      expect(find.text('From scratch'), findsOneWidget);
      expect(find.text('From a template'), findsOneWidget);
      expect(find.text('From a copy'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'shows the upcoming-workout card for the nearest draft/planned workout',
    (tester) async {
      await workouts.createDraft(date: _farFutureDate);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Start'), findsOneWidget);
      expect(find.textContaining('0 exercises'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('tapping "Start" starts the workout and opens the editor', (
    tester,
  ) async {
    final draft = await workouts.createDraft(date: _farFutureDate);

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutEditorScreen), findsOneWidget);
    final row = await (db.select(
      db.workouts,
    )..where((w) => w.id.equals(draft.id))).getSingle();
    expect(row.status, 'inProgress');

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'tapping the upcoming card body opens the editor without starting it',
    (tester) async {
      final draft = await workouts.createDraft(date: _farFutureDate);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsOneWidget);
      final row = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals(draft.id))).getSingle();
      expect(row.status, 'draft');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'shows the "Continue" card, not the upcoming card, when a workout is '
    'inProgress (DM 6.4.1)',
    (tester) async {
      final draft = await workouts.createDraft(date: _farFutureDate);
      await workouts.updateWorkout(
        draft.copyWith(status: WorkoutStatus.inProgress),
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Start'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('tapping "Continue" opens the active workout in the editor', (
    tester,
  ) async {
    final draft = await workouts.createDraft(date: _farFutureDate);
    await workouts.updateWorkout(
      draft.copyWith(status: WorkoutStatus.inProgress),
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutEditorScreen), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    '"From scratch" creates a draft dated today and opens it',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('From scratch'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsOneWidget);
      final rows = await db.select(db.workouts).get();
      expect(rows, hasLength(1));
      expect(rows.single.status, 'draft');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('"From template" opens the template picker', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('From a template'));
    await tester.pumpAndSettle();

    expect(find.byType(TemplatePickerScreen), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('"Copy last" opens the copy-source picker', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('From a copy'));
    await tester.pumpAndSettle();

    expect(find.byType(CopySourcePickerScreen), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
