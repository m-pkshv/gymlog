import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/exercises/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/exercises',
    routes: [
      GoRoute(path: '/exercises', builder: (_, _) => const ExercisesScreen()),
      GoRoute(
        path: '/exercises/new',
        builder: (_, _) => const CreateExerciseScreen(),
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

/// Drift's query streams schedule a zero-duration `Timer` when their last
/// listener unsubscribes (e.g. when the widget tree is disposed at the end
/// of a test). Unmounting explicitly and pumping once more lets that timer
/// fire before flutter_test's end-of-test pending-timer check runs.
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

  testWidgets('shows the empty state when the catalog has no exercises', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No exercises yet'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('lists an exercise already present in the database', (
    tester,
  ) async {
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

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('No exercises yet'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('Create button is disabled until a name is entered', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final createButtonFinder = find.widgetWithText(FilledButton, 'Create');
    expect(createButtonFinder, findsOneWidget);
    expect(tester.widget<FilledButton>(createButtonFinder).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'Push-Up');
    await tester.pump();

    expect(
      tester.widget<FilledButton>(createButtonFinder).onPressed,
      isNotNull,
    );

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'creating an exercise from the FAB adds it to the list (S-06/S-08)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      expect(find.text('No exercises yet'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Push-Up');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      // Back on the list, showing the newly created exercise.
      expect(find.text('Push-Up'), findsOneWidget);
      expect(find.text('No exercises yet'), findsNothing);

      final exercises = await db.select(db.exercises).get();
      expect(exercises, hasLength(1));
      expect(exercises.single.name, 'Push-Up');
      expect(exercises.single.exerciseType, ExerciseType.strength.name);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'effort metric field only shows for strength exercises (S-08, DM 6.1)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Default type is strength.
      expect(find.text('Effort metric'), findsOneWidget);

      await tester.tap(find.text('Strength'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reps').last);
      await tester.pumpAndSettle();

      expect(find.text('Effort metric'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'a non-YouTube link shows a warning but does not block creating (DM 6.1)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Push-Up');
      await tester.enterText(
        find.widgetWithText(TextField, 'YouTube link'),
        'not a real url',
      );
      await tester.pump();

      expect(find.text("Doesn't look like a YouTube link"), findsOneWidget);
      final createButtonFinder = find.widgetWithText(FilledButton, 'Create');
      expect(
        tester.widget<FilledButton>(createButtonFinder).onPressed,
        isNotNull,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('search narrows the list to matching names (S-06)', (
    tester,
  ) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'bench',
            name: 'Bench Press',
            exerciseType: ExerciseType.strength.name,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
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

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bench');
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a search with no matches shows "No matches found" and a reset action',
    (tester) async {
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

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'nonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No matches found'), findsOneWidget);
      expect(find.text('No exercises yet'), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset filters'));
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('the archived filter reveals an archived exercise (S-06)', (
    tester,
  ) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'squat',
            name: 'Squat',
            exerciseType: ExerciseType.strength.name,
            isArchived: const Value(true),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    expect(find.text('Squat'), findsNothing);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Show archived'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Archived'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('the type filter narrows the list and combines with search', (
    tester,
  ) async {
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
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'run',
            name: 'Run',
            exerciseType: ExerciseType.cardio.name,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cardio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Run'), findsOneWidget);
    expect(find.text('Squat'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('"Reset" in the filter sheet clears the selected filters', (
    tester,
  ) async {
    await db
        .into(db.exercises)
        .insert(
          ExercisesCompanion.insert(
            id: 'squat',
            name: 'Squat',
            exerciseType: ExerciseType.strength.name,
            isArchived: const Value(true),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Show archived'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Squat'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets('selecting a secondary muscle group saves the link (DM 6.1)', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await db
        .into(db.muscleGroups)
        .insert(MuscleGroupsCompanion.insert(id: 'triceps', sortOrder: 4));

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Bench Press');
    await tester.tap(find.widgetWithText(FilterChip, 'Triceps'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    final exercise = await (db.select(
      db.exercises,
    )..where((e) => e.name.equals('Bench Press'))).getSingle();
    final links = await (db.select(
      db.exerciseSecondaryMuscles,
    )..where((s) => s.exerciseId.equals(exercise.id))).get();
    expect(links.map((l) => l.muscleGroupId), ['triceps']);

    await _unmountAndFlush(tester);
  });
}
