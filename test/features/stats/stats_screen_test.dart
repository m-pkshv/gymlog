import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/measurements/widgets/measurement_chart.dart';
import 'package:gymlog/features/stats/screen.dart';
import 'package:gymlog/features/stats/widgets/workout_stats_card.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StatsScreen(),
    ),
  );
}

Future<void> _seedType(
  AppDatabase db, {
  required String id,
  required String unitKind,
  int sortOrder = 0,
}) {
  return db
      .into(db.measurementTypes)
      .insert(
        MeasurementTypesCompanion.insert(
          id: id,
          unitKind: unitKind,
          isBuiltIn: true,
          sortOrder: sortOrder,
        ),
      );
}

/// Same rationale as the other feature flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await _seedType(db, id: 'body_weight', unitKind: 'mass', sortOrder: 0);
    await _seedType(db, id: 'body_fat', unitKind: 'percent', sortOrder: 1);
    await _seedType(db, id: 'neck', unitKind: 'length', sortOrder: 2);
    await _seedType(db, id: 'waist', unitKind: 'length', sortOrder: 3);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('the Weight card shows an empty state with no entries', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Body weight'), findsOneWidget);
    expect(find.text('No entries in this period'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('the Weight card defaults to the Month period', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final monthChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Month').first,
    );
    expect(monthChip.selected, isTrue);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'switching the period reveals an entry the default Month period '
    'excludes',
    (tester) async {
      await BodyMeasurementRepositoryImpl(db).create(
        measurementTypeId: 'body_weight',
        date: DateTime.now().subtract(const Duration(days: 200)),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      // Scoped to the Weight card specifically -- S-09 has several
      // independent period selectors on screen, each with its own "All".
      // The body only ever draws a chart (no per-point value text), so the
      // observable signal is the empty-state text vs. a rendered chart.
      final weightCard = find.ancestor(
        of: find.text('Body weight'),
        matching: find.byType(Card),
      );
      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: weightCard, matching: find.byType(MeasurementChart)),
        findsNothing,
      );

      await tester.tap(
        find.descendant(
          of: weightCard,
          matching: find.widgetWithText(ChoiceChip, 'All'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: weightCard, matching: find.byType(MeasurementChart)),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'picking a Custom date range via the range-picker\'s input mode filters '
    'to just that range (02_DEVELOPMENT_PLAN.md Stage 7 acceptance '
    'criterion: "пользовательский диапазон фильтрует корректно")',
    (tester) async {
      // Far in the past relative to "now" -- excluded by every preset
      // (including "All" would include it, but "Month" excludes it, which
      // is enough to prove the Custom range -- not some other preset --
      // is what made the entry visible).
      await BodyMeasurementRepositoryImpl(db).create(
        measurementTypeId: 'body_weight',
        date: DateTime(2020, 1, 18),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      final weightCard = find.ancestor(
        of: find.text('Body weight'),
        matching: find.byType(Card),
      );
      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: weightCard,
          matching: find.widgetWithText(ChoiceChip, 'Custom'),
        ),
      );
      await tester.pumpAndSettle();

      // The range picker opens in calendar mode by default; switch to
      // input mode (the M3 entry-mode toggle) to type exact dates instead
      // of navigating a calendar grid to the year 2020.
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(0), '01/15/2020');
      await tester.enterText(find.byType(TextField).at(1), '01/20/2020');
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final customChip = tester.widget<ChoiceChip>(
        find.descendant(
          of: weightCard,
          matching: find.widgetWithText(ChoiceChip, 'Custom'),
        ),
      );
      expect(customChip.selected, isTrue);
      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: weightCard, matching: find.byType(MeasurementChart)),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('the Measurements card lets you pick among girth types', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Measurements'), findsOneWidget);
    // Defaults to the first candidate by sortOrder (neck).
    expect(find.text('Neck'), findsWidgets);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waist').last);
    await tester.pumpAndSettle();

    expect(find.text('Waist'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  group('WorkoutStatsCard (Stage 7, S-09 "Тренировки" card)', () {
    Future<void> addCompletedWorkout(
      AppDatabase db, {
      required DateTime date,
      required double weight,
      required int reps,
    }) async {
      final exercises = ExerciseRepositoryImpl(db);
      final workouts = WorkoutRepositoryImpl(db);
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: date);
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
        isWarmup: false,
      );
      await workouts.updateSet(
        set.copyWith(
          isCompleted: true,
          actualWeightKg: weight,
          actualReps: reps,
        ),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );
    }

    testWidgets('shows an empty state with no completed workouts', (
      tester,
    ) async {
      // The Workouts card is the 4th card in the ListView, below the
      // default test viewport -- ListView only builds visible children
      // even when given a plain `children:` list (Stage 2 finding).
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      final card = find.byType(WorkoutStatsCard);
      expect(
        find.descendant(
          of: card,
          matching: find.text('No entries in this period'),
        ),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'shows count, frequency, and tonnage for a completed workout in the '
      'default Month period',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await addCompletedWorkout(
          db,
          date: DateTime.now(),
          weight: 100,
          reps: 5,
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        final card = find.byType(WorkoutStatsCard);
        expect(find.descendant(of: card, matching: find.text('1')), findsOneWidget);
        expect(
          find.descendant(of: card, matching: find.text('500.0 kg')),
          findsOneWidget,
        );
        // 1 workout / (30/7 weeks) rounds to 0.2 -- exercising the
        // TS 9 "1 знак" formatting, not the exact value.
        expect(
          find.descendant(of: card, matching: find.text('0.2 / wk')),
          findsOneWidget,
        );

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'switching to the All period reveals a workout outside the default '
      'Month range',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await addCompletedWorkout(
          db,
          date: DateTime.now().subtract(const Duration(days: 200)),
          weight: 50,
          reps: 10,
        );

        await tester.pumpWidget(_appUnderTest(db));
        await tester.pumpAndSettle();

        final card = find.byType(WorkoutStatsCard);
        expect(
          find.descendant(
            of: card,
            matching: find.text('No entries in this period'),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: card,
            matching: find.widgetWithText(ChoiceChip, 'All'),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: card,
            matching: find.text('No entries in this period'),
          ),
          findsNothing,
        );
        expect(find.descendant(of: card, matching: find.text('1')), findsOneWidget);
        // The "All" preset has no defined length, so frequency is hidden
        // entirely rather than guessed (owner-confirmed 2026-07-21).
        expect(
          find.descendant(
            of: card,
            matching: find.textContaining('/ wk'),
          ),
          findsNothing,
        );

        await _unmountAndFlush(tester);
      },
    );
  });
}
