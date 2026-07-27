import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/app/router.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/seed/seed_runner.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

/// Stage 10 profiling (03_TECHNICAL_SPEC.md, section 11.6): "кадр < 16 мс на
/// скролле истории из 1000 тренировок". Unlike the headless
/// `test/data/repositories_impl/workout_history_perf_test.dart` (which only
/// measures query latency, not actual frame rendering), this runs the real
/// `GymLogApp` widget tree on a connected device/emulator and uses
/// `IntegrationTestWidgetsFlutterBinding.watchPerformance` to capture real
/// per-frame build/rasterizer durations from the engine (works with
/// Impeller, unlike `adb shell dumpsys gfxinfo` which only sees the host
/// Activity, not what Flutter draws into its own surface — see Stage 10/
/// Step 3's notes on why that tool doesn't work here).
///
/// Run with (profile mode is required for representative numbers — debug
/// mode timings are dominated by JIT/assert overhead):
///   flutter test integration_test/perf_test.dart -d DEVICE_ID --profile
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  void printSummary(String label, Map<String, dynamic> summary) {
    // ignore: avoid_print
    print(
      '[$label] frames=${summary['frame_count']} '
      'avg_build=${summary['average_frame_build_time_millis']}ms '
      'p90_build=${summary['90th_percentile_frame_build_time_millis']}ms '
      'p99_build=${summary['99th_percentile_frame_build_time_millis']}ms '
      'worst_build=${summary['worst_frame_build_time_millis']}ms '
      'missed_build_budget=${summary['missed_frame_build_budget_count']} '
      'avg_raster=${summary['average_frame_rasterizer_time_millis']}ms '
      'p90_raster=${summary['90th_percentile_frame_rasterizer_time_millis']}ms '
      'p99_raster=${summary['99th_percentile_frame_rasterizer_time_millis']}ms '
      'worst_raster=${summary['worst_frame_rasterizer_time_millis']}ms '
      'missed_raster_budget=${summary['missed_frame_rasterizer_budget_count']}',
    );
  }

  testWidgets('History: scrolling 1000 completed workouts', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_history_');
    final dbFile = File('${tempDir.path}/gymlog.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);
    await SeedRunner(db).run();
    final settingsRepository = AppSettingsRepositoryImpl(db);
    await settingsRepository.ensureInitialized();
    // Locale-independent: the device this runs on may have any system
    // locale, but the text finders below need a fixed, known language.
    await settingsRepository.setLocale(AppLocale.en);

    final exercise = await (db.select(db.exercises)..limit(1)).getSingle();
    const uuid = Uuid();
    final now = DateTime.now().toUtc().toIso8601String();

    final workoutCompanions = <WorkoutsCompanion>[];
    final workoutExerciseCompanions = <WorkoutExercisesCompanion>[];
    final setCompanions = <ExerciseSetsCompanion>[];

    for (var w = 0; w < 1000; w++) {
      final workoutId = uuid.v4();
      workoutCompanions.add(
        WorkoutsCompanion.insert(
          id: workoutId,
          date: DateTime(2024, 1, 1).add(Duration(days: w)).toIso8601String().substring(0, 10),
          status: const Value('completed'),
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (var e = 0; e < 3; e++) {
        final workoutExerciseId = uuid.v4();
        workoutExerciseCompanions.add(
          WorkoutExercisesCompanion.insert(
            id: workoutExerciseId,
            workoutId: workoutId,
            exerciseId: exercise.id,
            orderIndex: e,
            createdAt: now,
            updatedAt: now,
          ),
        );
        for (var s = 0; s < 3; s++) {
          setCompanions.add(
            ExerciseSetsCompanion.insert(
              id: uuid.v4(),
              workoutExerciseId: workoutExerciseId,
              setNumber: s + 1,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }
    }

    await db.batch((batch) {
      batch.insertAll(db.workouts, workoutCompanions);
      batch.insertAll(db.workoutExercises, workoutExerciseCompanions);
      batch.insertAll(db.exerciseSets, setCompanions);
    });

    // `appRouter` is a module-level singleton (lib/app/router.dart), so its
    // navigation state otherwise leaks across the testWidgets in this file
    // (each one calls pumpWidget on a fresh widget tree, but they all share
    // the same GoRouter instance) -- the same class of issue already fixed
    // in test/widget_test.dart's setUp (Stage 10).
    appRouter.go('/today');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const GymLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    final list = find.byType(ListView);
    expect(list, findsOneWidget);

    await binding.watchPerformance(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(list, const Offset(0, -2000), 3000);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'history_scroll_1000_workouts');

    printSummary(
      'History/1000 workouts',
      binding.reportData!['history_scroll_1000_workouts'] as Map<String, dynamic>,
    );
  });

  testWidgets('Workout editor: scrolling a workout with 15 exercises', (tester) async {
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_editor_');
    final dbFile = File('${tempDir.path}/gymlog.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);
    await SeedRunner(db).run();
    final settingsRepository = AppSettingsRepositoryImpl(db);
    await settingsRepository.ensureInitialized();
    // Locale-independent: the device this runs on may have any system
    // locale, but the text finders below need a fixed, known language.
    await settingsRepository.setLocale(AppLocale.en);

    final exercises = await (db.select(db.exercises)..limit(15)).get();
    const uuid = Uuid();
    final now = DateTime.now().toUtc().toIso8601String();
    final workoutId = uuid.v4();

    final workoutExerciseCompanions = <WorkoutExercisesCompanion>[];
    final setCompanions = <ExerciseSetsCompanion>[];

    for (var e = 0; e < exercises.length; e++) {
      final workoutExerciseId = uuid.v4();
      workoutExerciseCompanions.add(
        WorkoutExercisesCompanion.insert(
          id: workoutExerciseId,
          workoutId: workoutId,
          exerciseId: exercises[e].id,
          orderIndex: e,
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (var s = 0; s < 5; s++) {
        setCompanions.add(
          ExerciseSetsCompanion.insert(
            id: uuid.v4(),
            workoutExerciseId: workoutExerciseId,
            setNumber: s + 1,
            plannedWeightKg: const Value(80),
            plannedReps: const Value(8),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    await db.batch((batch) {
      batch.insert(
        db.workouts,
        WorkoutsCompanion.insert(
          id: workoutId,
          date: '2024-01-01',
          status: const Value('completed'),
          createdAt: now,
          updatedAt: now,
        ),
      );
      batch.insertAll(db.workoutExercises, workoutExerciseCompanions);
      batch.insertAll(db.exerciseSets, setCompanions);
    });

    // `appRouter` is a module-level singleton (lib/app/router.dart), so its
    // navigation state otherwise leaks across the testWidgets in this file
    // (each one calls pumpWidget on a fresh widget tree, but they all share
    // the same GoRouter instance) -- the same class of issue already fixed
    // in test/widget_test.dart's setUp (Stage 10).
    appRouter.go('/today');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const GymLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('15 exercises'));
    await tester.pumpAndSettle();

    final scrollView = find.byType(CustomScrollView);
    expect(scrollView, findsOneWidget);

    await binding.watchPerformance(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(scrollView, const Offset(0, -2000), 3000);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'workout_editor_scroll_15_exercises');

    printSummary(
      'Workout editor/15 exercises',
      binding.reportData!['workout_editor_scroll_15_exercises'] as Map<String, dynamic>,
    );
  });

  testWidgets('Workout editor: scrolling an in-progress workout (timer ticking)', (
    tester,
  ) async {
    // Unlike the scenario above (a `completed` workout), this seeds the
    // workout as `inProgress` with a live `ActiveWorkoutState` row so the
    // screen's once-a-second `_ActiveWorkoutTicker` (screen.dart) is
    // actually running while scrolling -- the owner reported jank
    // specifically while scrolling the exercise list of an active workout,
    // a scenario the `completed`-workout test above never exercised.
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_active_editor_');
    final dbFile = File('${tempDir.path}/gymlog.sqlite');
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final db = AppDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);
    await SeedRunner(db).run();
    final settingsRepository = AppSettingsRepositoryImpl(db);
    await settingsRepository.ensureInitialized();
    await settingsRepository.setLocale(AppLocale.en);

    final exercises = await (db.select(db.exercises)..limit(15)).get();
    const uuid = Uuid();
    final now = DateTime.now().toUtc();
    final nowIso = now.toIso8601String();
    final workoutId = uuid.v4();

    final workoutExerciseCompanions = <WorkoutExercisesCompanion>[];
    final setCompanions = <ExerciseSetsCompanion>[];

    for (var e = 0; e < exercises.length; e++) {
      final workoutExerciseId = uuid.v4();
      workoutExerciseCompanions.add(
        WorkoutExercisesCompanion.insert(
          id: workoutExerciseId,
          workoutId: workoutId,
          exerciseId: exercises[e].id,
          orderIndex: e,
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      for (var s = 0; s < 5; s++) {
        setCompanions.add(
          ExerciseSetsCompanion.insert(
            id: uuid.v4(),
            workoutExerciseId: workoutExerciseId,
            setNumber: s + 1,
            plannedWeightKg: const Value(80),
            plannedReps: const Value(8),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
        );
      }
    }

    await db.batch((batch) {
      batch.insert(
        db.workouts,
        WorkoutsCompanion.insert(
          id: workoutId,
          date: nowIso.substring(0, 10),
          status: const Value('inProgress'),
          startedAt: Value(nowIso),
          createdAt: nowIso,
          updatedAt: nowIso,
        ),
      );
      batch.insertAll(db.workoutExercises, workoutExerciseCompanions);
      batch.insertAll(db.exerciseSets, setCompanions);
      batch.insert(
        db.activeWorkoutStates,
        ActiveWorkoutStatesCompanion.insert(
          workoutId: workoutId,
          startedAtUtc: now.subtract(const Duration(minutes: 5)).toIso8601String(),
          updatedAt: nowIso,
        ),
      );
    });

    appRouter.go('/today');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const GymLogApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final scrollView = find.byType(CustomScrollView);
    expect(scrollView, findsOneWidget);

    await binding.watchPerformance(() async {
      for (var i = 0; i < 6; i++) {
        await tester.fling(scrollView, const Offset(0, -2000), 3000);
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'active_workout_editor_scroll');

    printSummary(
      'Active workout editor/15 exercises',
      binding.reportData!['active_workout_editor_scroll'] as Map<String, dynamic>,
    );
  });
}
