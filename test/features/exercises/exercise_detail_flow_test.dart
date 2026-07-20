import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' hide Exercise;
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/exercises/exercise_detail_screen.dart';
import 'package:gymlog/features/exercises/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/exercises',
    routes: [
      GoRoute(path: '/exercises', builder: (_, _) => const ExercisesScreen()),
      GoRoute(
        path: '/exercises/:exerciseId',
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['exerciseId']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (_, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: CreateExerciseScreen(exercise: state.extra as Exercise),
            ),
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

Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Future<String> _insertExercise(
  AppDatabase db, {
  required String id,
  required String name,
  bool isBuiltIn = false,
  ExerciseType type = ExerciseType.strength,
}) async {
  await db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: name,
          exerciseType: type.name,
          isBuiltIn: Value(isBuiltIn),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
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

  testWidgets('shows name, type and an empty history (S-07)', (
    tester,
  ) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Squat'), findsWidgets);
    expect(find.text('Strength'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(
      find.text('No completed workouts with this exercise yet'),
      findsOneWidget,
    );

    await _unmountAndFlush(tester);
  });

  testWidgets('history tab lists a completed occurrence', (tester) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
    await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: 'w1',
            date: '2026-07-20',
            status: const Value('completed'),
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
            actualWeightKg: const Value(80),
            actualReps: const Value(5),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('20.07.2026'), findsOneWidget);
    expect(find.textContaining('80.0 kg'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('archiving updates the badge and menu label', (tester) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    final exercise = await (db.select(
      db.exercises,
    )..where((e) => e.id.equals('squat'))).getSingle();
    expect(exercise.isArchived, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Unarchive'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('a built-in exercise has no Delete action', (tester) async {
    await _insertExercise(
      db,
      id: 'squat',
      name: 'Barbell Squat',
      isBuiltIn: true,
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a used user-created exercise has no Delete action either',
    (tester) async {
      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
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

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'deleting an unused user-created exercise removes it and pops back',
    (tester) async {
      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this exercise?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await (db.select(db.exercises)).get(), isEmpty);
      expect(find.text('No exercises yet'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('a built-in exercise has no Edit action', (tester) async {
    await _insertExercise(
      db,
      id: 'squat',
      name: 'Barbell Squat',
      isBuiltIn: true,
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'editing a user-created exercise pre-fills the form and saves changes',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit exercise'), findsOneWidget);
      final nameField = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(nameField.controller!.text, 'Barbell Squat');

      await tester.enterText(find.byType(TextField).first, 'Front Squat');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Front Squat'), findsWidgets);
      final exercise = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('squat'))).getSingle();
      expect(exercise.name, 'Front Squat');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the type dropdown is locked once a set has been logged (DM 6.1)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
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
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(
        find.text("Can't be changed: this exercise already has logged sets"),
        findsOneWidget,
      );
      final dropdown = tester.widget<DropdownButtonFormField<ExerciseType>>(
        find.byType(DropdownButtonFormField<ExerciseType>),
      );
      expect(dropdown.onChanged, isNull);

      await _unmountAndFlush(tester);
    },
  );
}
