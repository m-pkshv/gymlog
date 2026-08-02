import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/design_tokens.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/workout_summary/screen.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Only the summary route plus a placeholder History root -- enough to
/// verify the screen itself and the "Готово" -> History navigation
/// (03_TECHNICAL_SPEC.md, 04_UI_UX_SPEC.md S-05), without pulling in the
/// full editor/history harness `workout_editor_flow_test.dart` and
/// `history_flow_test.dart` already cover for the finish-navigates-here
/// wiring.
Widget _appUnderTest(AppDatabase db, {String workoutId = 'w1'}) {
  final router = GoRouter(
    initialLocation: '/workout/$workoutId/summary',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const _HistoryStub()),
      GoRoute(
        path: '/workout/:workoutId/summary',
        builder: (_, state) => WorkoutSummaryScreen(
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

class _HistoryStub extends StatelessWidget {
  const _HistoryStub();

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('History'));
}

/// Same routes as [_appUnderTest], but starts on History -- the caller is
/// expected to `router.push('/workout/$workoutId/summary')` itself *after*
/// the first `pumpAndSettle` (pushing before the router has ever built a
/// widget tree doesn't register History underneath, it just replaces the
/// initial match). That reproduces the real app's stack shape right after
/// the editor's `pushReplacement` (`workout_editor/screen.dart`'s
/// `_changeStatus`), which leaves History (or whatever screen opened the
/// workout) directly underneath. Needed only for the "Done" test below:
/// [_appUnderTest] starts *at* the summary route with nothing underneath,
/// which can't exercise "Done" popping back to something (Stage 10 redesign,
/// owner-reported: "Done" used to hardcode `context.go('/history')`,
/// landing on History regardless of the stack -- now it pops instead).
(Widget, GoRouter) _appUnderTestPushedFromHistory(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const _HistoryStub()),
      GoRoute(
        path: '/workout/:workoutId/summary',
        builder: (_, state) => WorkoutSummaryScreen(
          workoutId: state.pathParameters['workoutId']!,
        ),
      ),
    ],
  );

  final app = ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      theme: buildLightTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  return (app, router);
}

/// Same rationale as the other feature flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Future<void> _seedCompletedWorkout(
  AppDatabase db, {
  String workoutId = 'w1',
  int actualDurationSec = 2712, // 45:12 -- under an hour, easy to assert.
}) async {
  await db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: workoutId,
          date: '2026-07-21',
          status: const Value('completed'),
          actualDurationSec: Value(actualDurationSec),
          createdAt: '2026-07-21T00:00:00Z',
          updatedAt: '2026-07-21T00:00:00Z',
        ),
      );
  await db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: 'squat',
          name: 'Squat',
          exerciseType: ExerciseType.strength.name,
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
  await db
      .into(db.workoutExercises)
      .insert(
        WorkoutExercisesCompanion.insert(
          id: 'we1',
          workoutId: workoutId,
          exerciseId: 'squat',
          orderIndex: 0,
          createdAt: '2026-07-21T00:00:00Z',
          updatedAt: '2026-07-21T00:00:00Z',
        ),
      );
  // Completed -- 40 x 10 = 400 kg of tonnage.
  await db
      .into(db.exerciseSets)
      .insert(
        ExerciseSetsCompanion.insert(
          id: 's1',
          workoutExerciseId: 'we1',
          setNumber: 1,
          isCompleted: const Value(true),
          actualWeightKg: const Value(40),
          actualReps: const Value(10),
          createdAt: '2026-07-21T00:00:00Z',
          updatedAt: '2026-07-21T00:00:00Z',
        ),
      );
  // Completed -- 100 x 5 = 500 kg of tonnage.
  await db
      .into(db.exerciseSets)
      .insert(
        ExerciseSetsCompanion.insert(
          id: 's2',
          workoutExerciseId: 'we1',
          setNumber: 2,
          isCompleted: const Value(true),
          actualWeightKg: const Value(100),
          actualReps: const Value(5),
          createdAt: '2026-07-21T00:00:00Z',
          updatedAt: '2026-07-21T00:00:00Z',
        ),
      );
  // Unmarked -- counted in setCount, excluded from tonnage.
  await db
      .into(db.exerciseSets)
      .insert(
        ExerciseSetsCompanion.insert(
          id: 's3',
          workoutExerciseId: 'we1',
          setNumber: 3,
          createdAt: '2026-07-21T00:00:00Z',
          updatedAt: '2026-07-21T00:00:00Z',
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
    'shows the hero card (title + workout name) and the duration/exercise-'
    'count/set-count stat row (Stage: design/redesign_v2, owner-supplied '
    'mockup -- the middle tile used to be tonnage, replaced with exercise '
    'count per owner follow-up feedback)',
    (tester) async {
      await _seedCompletedWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Workout summary'), findsOneWidget); // AppBar title
      expect(find.text('Workout completed'), findsOneWidget); // hero headline
      expect(find.text('Workout'), findsOneWidget); // unnamed -> default title
      expect(find.text('45:12'), findsOneWidget); // duration
      expect(find.text('1'), findsOneWidget); // exerciseCount (only "Squat")
      expect(find.text('3'), findsOneWidget); // setCount (all 3 sets)
      expect(find.text('900.0 kg'), findsNothing); // tonnage tile is gone

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'shows an "Export as PDF" action in the AppBar (Stage 11) -- not tapped '
    'here since it goes through a real platform channel (printing); '
    'WorkoutPdfService itself is fully covered without any platform '
    'boundary in workout_pdf_service_test.dart',
    (tester) async {
      await _seedCompletedWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Export as PDF'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  group(
    'exercise list (Stage: design/redesign_v2, owner-supplied mockup, '
    'read-only -- editing a progression decision stays in the workout '
    'editor\'s exercise cards)',
    () {
      testWidgets(
        'shows the exercise name and its completed/planned set ratio, with '
        'no progression badge when none was set (the default)',
        (tester) async {
          await _seedCompletedWorkout(db); // 2 of 3 sets completed, s3 not

          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          expect(find.text('Squat — 2/3'), findsOneWidget);
          expect(find.text('↑'), findsNothing);
          expect(find.text('='), findsNothing);
          expect(find.text('↓'), findsNothing);

          await _unmountAndFlush(tester);
        },
      );

      testWidgets(
        'shows the "increase" badge in the success (green) color (Stage: '
        'design/redesign_v2, owner-confirmed -- was the error/red family)',
        (tester) async {
          await _seedCompletedWorkout(db);
          await (db.update(
            db.workoutExercises,
          )..where((row) => row.id.equals('we1'))).write(
            const WorkoutExercisesCompanion(
              progressionDecision: Value('increase'),
            ),
          );

          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          expect(find.text('↑'), findsOneWidget);
          final semantic = Theme.of(
            tester.element(find.text('↑')),
          ).extension<AppSemanticColors>()!;
          final badge = tester.widget<Container>(
            find.ancestor(of: find.text('↑'), matching: find.byType(Container)),
          );
          expect(
            (badge.decoration! as BoxDecoration).color,
            semantic.successContainer,
          );

          await _unmountAndFlush(tester);
        },
      );

      testWidgets(
        'shows the "decrease" badge in the accent (orange) color, not '
        'success/green (Stage: design/redesign_v2, owner-reported)',
        (tester) async {
          await _seedCompletedWorkout(db);
          await (db.update(
            db.workoutExercises,
          )..where((row) => row.id.equals('we1'))).write(
            const WorkoutExercisesCompanion(
              progressionDecision: Value('decrease'),
            ),
          );

          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          final semantic = Theme.of(
            tester.element(find.text('↓')),
          ).extension<AppSemanticColors>()!;
          final badge = tester.widget<Container>(
            find.ancestor(
              of: find.text('↓'),
              matching: find.byType(Container),
            ),
          );
          expect(
            (badge.decoration! as BoxDecoration).color,
            semantic.accentContainer,
          );

          await _unmountAndFlush(tester);
        },
      );
    },
  );

  testWidgets('the comment field autosaves after the debounce', (
    tester,
  ) async {
    await _seedCompletedWorkout(db);

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Felt strong today');
    await tester.pump(const Duration(milliseconds: 200));
    expect((await db.select(db.workouts).get()).single.comment, isNull);

    await tester.pump(const Duration(milliseconds: 400));
    expect(
      (await db.select(db.workouts).get()).single.comment,
      'Felt strong today',
    );

    await _unmountAndFlush(tester);
  });

  group('New records (Stage 7, S-05)', () {
    Future<void> insertRecord(
      AppDatabase db, {
      required String recordType,
      required double value,
      required String workoutId,
      double? keyValue,
    }) {
      return db
          .into(db.personalRecords)
          .insert(
            PersonalRecordsCompanion.insert(
              exerciseId: 'squat',
              recordType: recordType,
              value: value,
              workoutId: workoutId,
              achievedAt: '2026-07-21',
              computedAt: '2026-07-21T00:00:00Z',
              keyValue: Value(keyValue),
            ),
          );
    }

    testWidgets('shows nothing when the exercise has no cached record at all', (
      tester,
    ) async {
      await _seedCompletedWorkout(db);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('New records'), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'shows nothing when the exercise\'s only cached record belongs to a '
      'different (older) workout',
      (tester) async {
        await _seedCompletedWorkout(db);
        // A record's `workoutId` FK must point at a real workout.
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                id: 'some-older-workout',
                date: '2026-06-01',
                status: const Value('completed'),
                createdAt: '2026-06-01T00:00:00Z',
                updatedAt: '2026-06-01T00:00:00Z',
              ),
            );
        await insertRecord(
          db,
          recordType: 'maxWeight',
          value: 90,
          workoutId: 'some-older-workout',
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.text('New records'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'shows a row for a record whose cached workoutId matches this workout',
      (tester) async {
        await _seedCompletedWorkout(db);
        await insertRecord(
          db,
          recordType: 'maxWeight',
          value: 100,
          workoutId: 'w1',
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.text('New records'), findsOneWidget);
        expect(find.text('Max weight'), findsOneWidget);
        expect(find.text('100.0 kg'), findsWidgets); // also the tonnage tile

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('shows the estimated badge for a new 1RM record', (
      tester,
    ) async {
      await _seedCompletedWorkout(db);
      await insertRecord(
        db,
        recordType: 'max1RM',
        value: 116.7,
        workoutId: 'w1',
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('New records'), findsOneWidget);
      expect(find.text('Estimated 1RM'), findsOneWidget);
      expect(find.text('116.7 kg'), findsOneWidget);
      expect(find.text('estimated'), findsOneWidget);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'shows the weight in the subtitle for a new reps-at-weight record',
      (tester) async {
        await _seedCompletedWorkout(db);
        await insertRecord(
          db,
          recordType: 'maxRepsAtWeight',
          value: 12,
          keyValue: 80,
          workoutId: 'w1',
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.text('New records'), findsOneWidget);
        expect(find.textContaining('80.0 kg'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );
  });

  testWidgets(
    '"Done" pops back to whatever was underneath (Stage 10 redesign, '
    'owner-reported: used to hardcode going to History regardless)',
    (tester) async {
      await _seedCompletedWorkout(db);

      final (app, router) = _appUnderTestPushedFromHistory(db);
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('History'), findsOneWidget, reason: 'sanity check');

      router.push('/workout/w1/summary');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.byType(WorkoutSummaryScreen), findsNothing);

      await _unmountAndFlush(tester);
    },
  );
}
