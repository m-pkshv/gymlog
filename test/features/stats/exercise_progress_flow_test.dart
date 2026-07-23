import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' hide PersonalRecord;
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/personal_record_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/personal_record.dart';
import 'package:gymlog/features/stats/exercise_progress_picker_screen.dart';
import 'package:gymlog/features/stats/exercise_progress_screen.dart';
import 'package:gymlog/features/stats/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/stats` + `/stats/exercise-search` + `/stats/exercise/:id`
/// slice of the real router (Stage 7, S-09/S-10). `/history/workout/:id` is
/// stubbed with a bare marker screen -- this test only cares that tapping a
/// record navigates to the right workout id, not about the editor itself.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/stats',
    routes: [
      GoRoute(
        path: '/stats',
        builder: (_, _) => const StatsScreen(),
        routes: [
          GoRoute(
            path: 'exercise-search',
            builder: (_, _) => const ExerciseProgressPickerScreen(),
          ),
          GoRoute(
            path: 'exercise/:exerciseId',
            builder: (_, state) => ExerciseProgressScreen(
              exerciseId: state.pathParameters['exerciseId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/history/workout/:workoutId',
        builder: (_, state) =>
            Scaffold(body: Text('workout-${state.pathParameters['workoutId']}')),
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

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'the entry card opens the picker; picking an exercise with no records '
    'shows the empty state',
    (tester) async {
      // The entry card is the 5th card in the Stats ListView, below the
      // default test viewport (Stage 2 finding, reused for the Workouts
      // card in the previous step).
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await ExerciseRepositoryImpl(
        db,
      ).create(name: 'Squat', exerciseType: ExerciseType.strength);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Choose exercise'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseProgressPickerScreen), findsOneWidget);

      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();

      expect(find.byType(ExerciseProgressScreen), findsOneWidget);
      expect(find.text('Squat'), findsWidgets); // AppBar title
      expect(find.text('No records yet'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'a long exercise name in the AppBar title ellipsizes instead of '
    'overflowing (UX 12: exercise names have no length limit, DM 6.1)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final longName = 'A' * 200;
      await ExerciseRepositoryImpl(
        db,
      ).create(name: longName, exerciseType: ExerciseType.strength);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose exercise'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(longName));
      await tester.pumpAndSettle();

      final titleText = tester.widget<Text>(
        find
            .descendant(of: find.byType(AppBar), matching: find.byType(Text))
            .first,
      );
      expect(titleText.maxLines, 1);
      expect(titleText.overflow, TextOverflow.ellipsis);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('searching the picker narrows the list', (tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await ExerciseRepositoryImpl(
      db,
    ).create(name: 'Squat', exerciseType: ExerciseType.strength);
    await ExerciseRepositoryImpl(
      db,
    ).create(name: 'Bench Press', exerciseType: ExerciseType.strength);

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose exercise'));
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'squ');
    await tester.pumpAndSettle();

    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Bench Press'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'shows the general records list (with the estimated badge on 1RM) and '
    'the reps-at-weight table, both linking to their workout',
    (tester) async {
      // Three chart cards now render above the records list/table --
      // enough content that the default test viewport would cull it
      // (Stage 2 finding: a plain `ListView(children: ...)` only builds
      // widgets within the viewport).
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final exercises = ExerciseRepositoryImpl(db);
      final workouts = WorkoutRepositoryImpl(db);
      final records = PersonalRecordRepositoryImpl(db);

      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final weightWorkout = await workouts.createDraft(
        date: DateTime(2026, 7, 1),
      );
      final oneRmWorkout = await workouts.createDraft(
        date: DateTime(2026, 7, 10),
      );
      final repsWorkout = await workouts.createDraft(
        date: DateTime(2026, 7, 15),
      );

      await records.replaceForExercise(exercise.id, [
        PersonalRecord(
          exerciseId: exercise.id,
          recordType: RecordType.maxWeight,
          value: 100,
          workoutId: weightWorkout.id,
          achievedAt: DateTime(2026, 7, 1),
          computedAt: DateTime(2026, 7, 1),
        ),
        PersonalRecord(
          exerciseId: exercise.id,
          recordType: RecordType.max1RM,
          value: 116.7,
          workoutId: oneRmWorkout.id,
          achievedAt: DateTime(2026, 7, 10),
          computedAt: DateTime(2026, 7, 10),
        ),
        PersonalRecord(
          exerciseId: exercise.id,
          recordType: RecordType.maxRepsAtWeight,
          keyValue: 80,
          value: 12,
          workoutId: repsWorkout.id,
          achievedAt: DateTime(2026, 7, 15),
          computedAt: DateTime(2026, 7, 15),
        ),
      ]);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      // Navigate straight in via the router (skip the search flow -- already
      // covered above).
      final context = tester.element(find.byType(StatsScreen));
      GoRouter.of(context).push('/stats/exercise/${exercise.id}');
      await tester.pumpAndSettle();

      // "Max weight"/"Estimated 1RM" each appear twice now: once as a chart
      // title (the workouts above are drafts, never completed, so the
      // charts themselves render empty) and once as the records-list row.
      expect(find.text('Max weight'), findsNWidgets(2));
      expect(find.text('100.0 kg'), findsOneWidget);
      expect(find.text('Estimated 1RM'), findsNWidgets(2));
      expect(find.text('116.7 kg'), findsOneWidget);
      expect(find.text('estimated'), findsNWidgets(2));
      expect(find.text('Reps at weight'), findsOneWidget);
      expect(find.text('80.0 kg'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Max weight'));
      await tester.pumpAndSettle();
      expect(find.text('workout-${weightWorkout.id}'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  group('progress charts (Stage 7 Step 6, TS 9)', () {
    Future<void> addCompletedWorkout(
      AppDatabase db, {
      required String exerciseId,
      required DateTime date,
      required double weight,
      required int reps,
    }) async {
      final workouts = WorkoutRepositoryImpl(db);
      final workout = await workouts.createDraft(date: date);
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exerciseId,
      );
      final set = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
      );
      await workouts.updateSet(
        set.copyWith(isCompleted: true, actualWeightKg: weight, actualReps: reps),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
    }

    testWidgets(
      'a strength exercise with no history shows all 3 charts empty',
      (tester) async {
        final exercise = await ExerciseRepositoryImpl(
          db,
        ).create(name: 'Squat', exerciseType: ExerciseType.strength);

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(StatsScreen));
        GoRouter.of(context).push('/stats/exercise/${exercise.id}');
        await tester.pumpAndSettle();

        expect(find.text('Max weight'), findsOneWidget);
        expect(find.text('Estimated 1RM'), findsOneWidget);
        expect(find.text('Workout tonnage'), findsOneWidget);
        expect(find.text('No entries in this period'), findsNWidgets(3));

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'a completed workout in the default Month period shows up on the '
      'max weight chart; switching to All reveals an older one',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final exercise = await ExerciseRepositoryImpl(
          db,
        ).create(name: 'Squat', exerciseType: ExerciseType.strength);
        await addCompletedWorkout(
          db,
          exerciseId: exercise.id,
          date: DateTime.now().subtract(const Duration(days: 200)),
          weight: 80,
          reps: 5,
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(StatsScreen));
        GoRouter.of(context).push('/stats/exercise/${exercise.id}');
        await tester.pumpAndSettle();

        final maxWeightCard = find.ancestor(
          of: find.text('Max weight'),
          matching: find.byType(Card),
        );
        expect(
          find.descendant(
            of: maxWeightCard,
            matching: find.text('No entries in this period'),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: maxWeightCard,
            matching: find.widgetWithText(ChoiceChip, 'All'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: maxWeightCard,
            matching: find.text('No entries in this period'),
          ),
          findsNothing,
        );

        await _unmountAndFlush(tester);
      },
    );

    testWidgets('a cardio exercise shows the 3 cardio charts, not the strength ones', (
      tester,
    ) async {
      final exercise = await ExerciseRepositoryImpl(
        db,
      ).create(name: 'Run', exerciseType: ExerciseType.cardio);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(StatsScreen));
      GoRouter.of(context).push('/stats/exercise/${exercise.id}');
      await tester.pumpAndSettle();

      expect(find.text('Max distance'), findsOneWidget);
      expect(find.text('Best pace'), findsOneWidget);
      expect(find.text('Longest duration'), findsOneWidget);
      expect(find.text('Max weight'), findsNothing);

      await _unmountAndFlush(tester);
    });
  });
}
