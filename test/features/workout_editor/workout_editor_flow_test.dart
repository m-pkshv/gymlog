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
import 'package:gymlog/features/history/screen.dart';
import 'package:gymlog/features/workout_editor/add_exercise_screen.dart';
import 'package:gymlog/features/workout_editor/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the subset of `app/router.dart` the workout editor needs (S-03,
/// Stage 1) — a self-contained harness rather than pulling in all 5 tabs.
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
        routes: [
          GoRoute(
            path: 'add-exercise',
            builder: (_, state) => AddExerciseScreen(
              workoutId: state.pathParameters['workoutId']!,
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

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
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
    'the FAB on History creates a draft and opens the editor (S-03 entry)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Start workout'), findsOneWidget);
      expect(find.text('No exercises added yet'), findsOneWidget);

      final workouts = await db.select(db.workouts).get();
      expect(workouts, hasLength(1));
      expect(workouts.single.status, WorkoutStatus.draft.name);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('picking an existing exercise adds it to the workout', (
    tester,
  ) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('No exercises added yet'), findsNothing);

    final workoutExercises = await db.select(db.workoutExercises).get();
    expect(workoutExercises, hasLength(1));

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'creating a new exercise from the editor adds it immediately (Stage 1 ★)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      expect(find.text('No exercises yet'), findsOneWidget);

      // The picker's own FAB opens the create form (S-08).
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Push-Up');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      // Back on the editor, with the new exercise already added.
      expect(find.text('Push-Up'), findsOneWidget);
      expect(find.text('No exercises added yet'), findsNothing);

      final exercises = await db.select(db.exercises).get();
      expect(exercises.single.name, 'Push-Up');
      final workoutExercises = await db.select(db.workoutExercises).get();
      expect(workoutExercises, hasLength(1));

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('add set creates a working set row', (tester) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add set'));
    await tester.pumpAndSettle();

    final sets = await db.select(db.exerciseSets).get();
    expect(sets, hasLength(1));
    expect(sets.single.setNumber, 1);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'editing a plan field debounces the write, then autosaves (TS 5)',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      // Weight, kg: first plan field of a strength exercise.
      await tester.enterText(find.byType(TextField).first, '100');
      await tester.pump();

      var sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, isNull, reason: 'not flushed yet');

      // Just under the debounce window: still unwritten.
      await tester.pump(autosaveDebounce - const Duration(milliseconds: 50));
      sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, isNull);

      // Past the debounce window: the value lands in the database.
      await tester.pump(const Duration(milliseconds: 100));
      sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, 100.0);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'losing focus flushes immediately, without waiting for the debounce',
    (tester) async {
      await _seedExercise(db);
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '80');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final sets = await db.select(db.exerciseSets).get();
      expect(sets.single.plannedWeightKg, 80.0);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('checking "done" copies plan into empty facts (DM 6.7)', (
    tester,
  ) async {
    await _seedExercise(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Squat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add set'));
    await tester.pumpAndSettle();

    // Plan weight, then plan reps (the two TextFields of a strength row).
    await tester.enterText(find.byType(TextField).at(0), '60');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.enterText(find.byType(TextField).at(2), '10');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    final sets = await db.select(db.exerciseSets).get();
    expect(sets.single.isCompleted, isTrue);
    expect(sets.single.actualWeightKg, 60.0);
    expect(sets.single.actualReps, 10);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'Start then Finish moves the workout draft -> inProgress -> completed',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start workout'));
      await tester.pumpAndSettle();
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('Finish'), findsOneWidget);

      var workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.inProgress.name);
      expect(workouts.single.startedAt, isNotNull);

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Finish'), findsNothing);

      workouts = await db.select(db.workouts).get();
      expect(workouts.single.status, WorkoutStatus.completed.name);
      expect(workouts.single.finishedAt, isNotNull);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('reopening the editor shows previously saved data', (
    tester,
  ) async {
    await _seedExercise(db);
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
    await db
        .into(db.workoutExercises)
        .insert(
          WorkoutExercisesCompanion.insert(
            id: 'we1',
            workoutId: 'w1',
            exerciseId: 'squat',
            orderIndex: 0,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    await db
        .into(db.exerciseSets)
        .insert(
          ExerciseSetsCompanion.insert(
            id: 's1',
            workoutExerciseId: 'we1',
            setNumber: 1,
            plannedWeightKg: const Value(100),
            plannedReps: const Value(5),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    final router = GoRouter(
      initialLocation: '/history/workout/w1',
      routes: [
        GoRoute(
          path: '/history/workout/:workoutId',
          builder: (_, state) => WorkoutEditorScreen(
            workoutId: state.pathParameters['workoutId']!,
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await _unmountAndFlush(tester);
  });
}
