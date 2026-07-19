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

    await tester.enterText(find.byType(TextField), 'Push-Up');
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

      await tester.enterText(find.byType(TextField), 'Push-Up');
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
}
