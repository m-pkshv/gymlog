import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/history` + `/history/workout/:workoutId` slice of the real
/// router (S-02, Stage 1 minimum: list + tap-to-open, no filters yet).
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/history',
    routes: [
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
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
}
