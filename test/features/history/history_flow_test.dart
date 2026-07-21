import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/date_format.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/history/copy_source_picker_screen.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/history` + `/history/workout/:workoutId` +
/// `/history/copy-source` slice of the real router (S-02; the "Копией"
/// creation menu option and its picker are Stage 3).
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(
        path: '/history',
        builder: (_, _) => const HistoryScreen(),
        routes: [
          GoRoute(
            path: 'copy-source',
            builder: (_, _) => const CopySourcePickerScreen(),
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

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Future<String> _insertCompletedWorkout(
  AppDatabase db, {
  required String id,
  required String date,
  String? name,
  int? actualDurationSec,
  int exerciseCount = 0,
}) async {
  await db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: id,
          date: date,
          name: Value(name),
          status: const Value('completed'),
          actualDurationSec: Value(actualDurationSec),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
  if (exerciseCount > 0) {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: '${id}_ex',
            name: 'Squat',
            exerciseType: ExerciseType.strength.name,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    for (var i = 0; i < exerciseCount; i++) {
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: '${id}_we$i',
              workoutId: id,
              exerciseId: '${id}_ex',
              orderIndex: i,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
    }
  }
  return id;
}

Future<void> _seedTag(
  AppDatabase db, {
  required String id,
  required String name,
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

Future<void> _linkTag(AppDatabase db, {required String workoutId, required String tagId}) {
  return db
      .into(db.workoutTagLinks)
      .insert(
        WorkoutTagLinksCompanion.insert(workoutId: workoutId, tagId: tagId),
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

  testWidgets('shows the empty state when there is no completed workout', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No completed workouts yet'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('a draft workout is not listed', (tester) async {
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

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No completed workouts yet'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a completed workout shows its date, exercise count and duration',
    (tester) async {
      await _insertCompletedWorkout(
        db,
        id: 'w1',
        date: '2026-07-20',
        actualDurationSec: 125 * 60,
        exerciseCount: 2,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Workout 20.07.2026'), findsOneWidget);
      expect(find.textContaining('2 exercises'), findsOneWidget);
      expect(find.textContaining('125 min'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('a named workout shows its name instead of the date fallback', (
    tester,
  ) async {
    await _insertCompletedWorkout(
      db,
      id: 'w1',
      date: '2026-07-20',
      name: 'Leg day',
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('most recent workout is listed first', (tester) async {
    await _insertCompletedWorkout(db, id: 'older', date: '2026-07-01');
    await _insertCompletedWorkout(db, id: 'newer', date: '2026-07-19');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final titles = tester
        .widgetList<Text>(find.textContaining('Workout '))
        .map((t) => t.data)
        .toList();
    expect(titles, ['Workout 19.07.2026', 'Workout 01.07.2026']);

    await _unmountAndFlush(tester);
  });

  testWidgets('tapping a card opens that workout in the editor', (
    tester,
  ) async {
    await _insertCompletedWorkout(
      db,
      id: 'w1',
      date: '2026-07-20',
      name: 'Leg day',
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leg day'));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutEditorScreen), findsOneWidget);
    expect(find.text('No exercises added yet'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  group('"Copy" (Stage 3, S-02, TS 8 section 8)', () {
    testWidgets(
      'copies exercises/order/planned values into a new draft, without '
      'facts or completion marks, and opens it in the editor',
      (tester) async {
        await _insertCompletedWorkout(
          db,
          id: 'w1',
          date: '2026-07-01',
          exerciseCount: 1,
        );
        await db
            .into(db.exerciseSets)
            .insert(
              ExerciseSetsCompanion.insert(
                id: 's1',
                workoutExerciseId: 'w1_we0',
                setNumber: 1,
                isCompleted: const Value(true),
                plannedWeightKg: const Value(60),
                plannedReps: const Value(8),
                actualWeightKg: const Value(60),
                actualReps: const Value(8),
                createdAt: '2026-07-01T00:00:00Z',
                updatedAt: '2026-07-01T00:00:00Z',
              ),
            );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Copy'));
        await tester.pumpAndSettle();

        expect(find.byType(DatePickerDialog), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutEditorScreen), findsOneWidget);
        expect(find.text('Draft'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);

        final workouts = await db.select(db.workouts).get();
        expect(workouts, hasLength(2));
        final copy = workouts.firstWhere((w) => w.id != 'w1');
        expect(copy.status, 'draft');

        final copiedWorkoutExercises = await (db.select(
          db.workoutExercises,
        )..where((we) => we.workoutId.equals(copy.id))).get();
        expect(copiedWorkoutExercises, hasLength(1));

        final copiedSets = await (db.select(
          db.exerciseSets,
        )..where(
          (s) => s.workoutExerciseId.equals(copiedWorkoutExercises.single.id),
        )).get();
        expect(copiedSets.single.plannedWeightKg, 60.0);
        expect(copiedSets.single.plannedReps, 8);
        expect(copiedSets.single.actualWeightKg, isNull);
        expect(copiedSets.single.actualReps, isNull);
        expect(copiedSets.single.isCompleted, isFalse);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('cancelling the date picker copies nothing', (tester) async {
      await _insertCompletedWorkout(db, id: 'w1', date: '2026-07-01');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(await db.select(db.workouts).get(), hasLength(1));

      await _unmountAndFlush(tester);
    });
  });

  group(
    'creation menu (Stage 3, 02_DEVELOPMENT_PLAN.md: "с нуля/из шаблона/копией")',
    () {
      testWidgets(
        'the FAB offers all three creation options, template disabled',
        (tester) async {
          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          expect(find.text('From scratch'), findsOneWidget);
          expect(find.text('From a copy'), findsOneWidget);
          expect(find.text('From a template'), findsOneWidget);
          expect(find.text('Coming soon'), findsOneWidget);

          final templateTile = tester.widget<ListTile>(
            find.widgetWithText(ListTile, 'From a template'),
          );
          expect(templateTile.enabled, isFalse);

          await _unmountAndFlush(tester);
        },
      );

      testWidgets('"From scratch" creates a draft and opens it', (
        tester,
      ) async {
        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.tap(find.text('From scratch'));
        await tester.pumpAndSettle();

        expect(find.byType(WorkoutEditorScreen), findsOneWidget);
        expect(find.text('Draft'), findsOneWidget);

        await _unmountAndFlush(tester);
      });

      testWidgets(
        '"From a copy" opens the source picker; picking a workout copies '
        'it and opens the copy',
        (tester) async {
          await _insertCompletedWorkout(
            db,
            id: 'w1',
            date: '2026-07-01',
            name: 'Leg day',
            exerciseCount: 1,
          );

          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.tap(find.text('From a copy'));
          await tester.pumpAndSettle();

          expect(find.byType(CopySourcePickerScreen), findsOneWidget);
          expect(find.text('Leg day'), findsOneWidget);

          await tester.tap(find.text('Leg day'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();

          expect(find.byType(WorkoutEditorScreen), findsOneWidget);
          expect(find.text('Draft'), findsOneWidget);
          expect(find.text('Squat'), findsOneWidget);

          final workouts = await db.select(db.workouts).get();
          expect(workouts, hasLength(2));

          await _unmountAndFlush(tester);
        },
      );

      testWidgets(
        'the source picker shows an empty state with no completed workouts',
        (tester) async {
          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();
          await tester.tap(find.text('From a copy'));
          await tester.pumpAndSettle();

          expect(
            find.text('No completed workouts to copy from yet'),
            findsOneWidget,
          );

          await _unmountAndFlush(tester);
        },
      );
    },
  );

  group('filters (Stage 3, S-02)', () {
    testWidgets('search narrows the list by name', (tester) async {
      await _insertCompletedWorkout(db, id: 'w1', date: '2026-07-01', name: 'Legs');
      await _insertCompletedWorkout(db, id: 'w2', date: '2026-07-02', name: 'Push');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'leg');
      await tester.pumpAndSettle();

      expect(find.text('Legs'), findsOneWidget);
      expect(find.text('Push'), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'a draft workout is hidden by default but shown once "Draft" is '
      'selected in the status filter',
      (tester) async {
        await db
            .into(db.workouts)
            .insert(
              WorkoutsCompanion.insert(
                id: 'draft1',
                date: '2026-07-20',
                name: const Value('Unfinished'),
                createdAt: '2026-07-19T00:00:00Z',
                updatedAt: '2026-07-19T00:00:00Z',
              ),
            );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.text('Unfinished'), findsNothing);

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Draft'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        expect(find.text('Unfinished'), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('date range narrows the list', (tester) async {
      await _insertCompletedWorkout(db, id: 'w1', date: '2026-06-01', name: 'Too early');
      await _insertCompletedWorkout(db, id: 'w2', date: '2026-07-10', name: 'In range');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.text('From'));
      await tester.pumpAndSettle();
      // Switch the date picker from calendar to text-input mode so the
      // exact date can be typed instead of navigating the calendar grid.
      // Material 3 uses `edit_outlined` (not `edit`) for this toggle.
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(DatePickerDialog),
          matching: find.byType(TextField),
        ),
        '07/01/2026',
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text('In range'), findsOneWidget);
      expect(find.text('Too early'), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'tag filter (OR mode) narrows the list and cards show tag chips',
      (tester) async {
        await _seedTag(db, id: 'legs', name: 'Legs');
        await _seedTag(db, id: 'push', name: 'Push');
        await _insertCompletedWorkout(db, id: 'w1', date: '2026-07-01', name: 'Leg day');
        await _linkTag(db, workoutId: 'w1', tagId: 'legs');
        await _insertCompletedWorkout(db, id: 'w2', date: '2026-07-02', name: 'Rest day');

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(Chip, 'Legs'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Legs'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();

        expect(find.text('Leg day'), findsOneWidget);
        expect(find.text('Rest day'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('"Reset" in the filter sheet clears every criterion', (
      tester,
    ) async {
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'draft1',
              date: '2026-07-20',
              name: const Value('Unfinished'),
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Draft'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Unfinished'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text('Unfinished'), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'tag chips and the filter\'s tags section are hidden when showTags '
      'is off (S-17)',
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
        await _seedTag(db, id: 'legs', name: 'Legs');
        await _insertCompletedWorkout(db, id: 'w1', date: '2026-07-01', name: 'Leg day');
        await _linkTag(db, workoutId: 'w1', tagId: 'legs');

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(Chip, 'Legs'), findsNothing);

        await tester.tap(find.byIcon(Icons.tune));
        await tester.pumpAndSettle();

        expect(find.text('Tags'), findsNothing);

        await _unmountAndFlush(tester);
      },
    );
  });

  group('calendar view (Stage 3, S-02)', () {
    String isoDate(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    testWidgets('toggling to calendar view shows the month grid, toggling back hides it', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('historyCalendarGrid')), findsNothing);

      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('historyCalendarGrid')), findsOneWidget);

      await tester.tap(find.byIcon(Icons.view_list_outlined));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('historyCalendarGrid')), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets('a workout on the selected day (today, by default) is listed below the grid', (
      tester,
    ) async {
      final today = DateTime.now();
      await _insertCompletedWorkout(
        db,
        id: 'w1',
        date: isoDate(today),
        name: 'Leg day',
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsOneWidget);
      expect(find.text('No workouts this day'), findsNothing);

      await _unmountAndFlush(tester);
    });

    testWidgets('tapping a day with no workouts shows the day-empty message', (
      tester,
    ) async {
      final today = DateTime.now();
      await _insertCompletedWorkout(
        db,
        id: 'w1',
        date: isoDate(today),
        name: 'Leg day',
      );
      final otherDay = today.day == 10 ? 11 : 10;

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Leg day'), findsOneWidget);

      await tester.tap(find.text('$otherDay'));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsNothing);
      expect(find.text('No workouts this day'), findsOneWidget);

      await _unmountAndFlush(tester);
    });

    testWidgets('month navigation changes which day-of-month is queried', (
      tester,
    ) async {
      final today = DateTime.now();
      await _insertCompletedWorkout(
        db,
        id: 'w1',
        date: isoDate(today),
        name: 'Leg day',
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Leg day'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('Leg day'), findsNothing);

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();
      expect(find.text('Leg day'), findsOneWidget);

      await _unmountAndFlush(tester);
    });

    testWidgets('the date-range fields are hidden in the filter sheet while in calendar mode', (
      tester,
    ) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.calendar_month_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('From'), findsNothing);
      expect(find.text('To'), findsNothing);
      expect(find.text('Statuses'), findsOneWidget);

      await _unmountAndFlush(tester);
    });
  });

  group('"Delete" + Undo (Stage 3, S-02, DM 10)', () {
    testWidgets(
      'deleting a workout hides it immediately and shows an Undo snackbar',
      (tester) async {
        await _insertCompletedWorkout(
          db,
          id: 'w1',
          date: '2026-07-01',
          name: 'Leg day',
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.more_vert));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Leg day'), findsNothing);
        expect(find.text('Workout deleted'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);

        final workout = await (db.select(
          db.workouts,
        )..where((w) => w.id.equals('w1'))).getSingle();
        expect(workout.isDeleted, isTrue);

        // Let the snackbar's own 5s auto-dismiss timer fire and finish its
        // exit animation before tearing down, or flutter_test flags it as
        // still pending.
        await tester.pump(const Duration(seconds: 6));
        await _unmountAndFlush(tester);
      },
    );

    testWidgets('"Undo" restores the deleted workout', (tester) async {
      await _insertCompletedWorkout(
        db,
        id: 'w1',
        date: '2026-07-01',
        name: 'Leg day',
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Leg day'), findsNothing);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsOneWidget);
      final workout = await (db.select(
        db.workouts,
      )..where((w) => w.id.equals('w1'))).getSingle();
      expect(workout.isDeleted, isFalse);

      await _unmountAndFlush(tester);
    });
  });

  group(
    '★ regression (Stage 3, 02_DEVELOPMENT_PLAN.md: "скопировать прошлую → '
    'перенести дату → провести")',
    () {
      testWidgets(
        'copying a completed workout, moving its date, then running it '
        'through start -> finish leaves the copy completed on the new date '
        'and the source untouched',
        (tester) async {
          await _insertCompletedWorkout(
            db,
            id: 'w1',
            date: '2026-07-01',
            name: 'Leg day',
            exerciseCount: 1,
          );

          await tester.pumpWidget(_appUnderTest(db));
          await tester.pumpAndSettle();

          // "Скопировать прошлую".
          await tester.tap(find.byIcon(Icons.more_vert));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Copy'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('OK')); // accepts today as the copy's date
          await tester.pumpAndSettle();

          expect(find.byType(WorkoutEditorScreen), findsOneWidget);
          expect(find.text('Draft'), findsOneWidget);

          // "Перенести дату".
          await tester.tap(find.text(formatShortDate(DateTime.now())));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.edit_outlined));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.descendant(
              of: find.byType(DatePickerDialog),
              matching: find.byType(TextField),
            ),
            '08/15/2026',
          );
          await tester.tap(find.text('OK'));
          await tester.pumpAndSettle();
          expect(find.text('15.08.2026'), findsOneWidget);

          // "Провести": draft -> inProgress -> completed.
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

          await tester.pageBack();
          await tester.pumpAndSettle();

          // The source is untouched; the copy shows up completed, dated.
          expect(find.text('Leg day'), findsOneWidget);
          final workouts = await db.select(db.workouts).get();
          expect(workouts, hasLength(2));
          final source = workouts.firstWhere((w) => w.id == 'w1');
          expect(source.status, 'completed');
          expect(source.date, '2026-07-01');
          final copy = workouts.firstWhere((w) => w.id != 'w1');
          expect(copy.status, 'completed');
          expect(copy.date, '2026-08-15');

          await _unmountAndFlush(tester);
        },
      );
    },
  );
}
