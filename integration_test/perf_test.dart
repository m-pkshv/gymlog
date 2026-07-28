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
/// Seeds `count` completed workouts with varied names/exercise counts/tags
/// (unlike the other scenarios' identical-shaped rows) so each list tile
/// needs genuinely different text shaping/layout, not the exact same glyphs
/// repeated -- closer to a real user's history than 1000 clones of the same
/// row. Used by the "human-paced" scroll scenarios below, which are
/// specifically checking whether *scrolling through varied, never-before-
/// seen content* (not a single cold-start cost) is what causes an
/// intermittent stutter at slow, non-fling speeds.
Future<void> _seedRealisticHistory(AppDatabase db, {required int count}) async {
  const uuid = Uuid();
  final now = DateTime.now().toUtc().toIso8601String();

  final exercises = await (db.select(db.exercises)..limit(10)).get();
  final tags = await (db.select(db.workoutTags)..limit(8)).get();
  const namePool = [
    null, // falls back to the default "Workout + date" title
    'Push Day A',
    'Leg Day — Heavy Squats and Deadlifts',
    null,
    'Full Body Circuit Training Session',
    'Arms',
    null,
    'Upper Body Strength + Accessories, Back-to-Back',
    'Pull Day',
    null,
  ];

  final workoutCompanions = <WorkoutsCompanion>[];
  final workoutExerciseCompanions = <WorkoutExercisesCompanion>[];
  final setCompanions = <ExerciseSetsCompanion>[];
  final tagLinkCompanions = <WorkoutTagLinksCompanion>[];

  for (var w = 0; w < count; w++) {
    final workoutId = uuid.v4();
    final name = namePool[w % namePool.length];
    workoutCompanions.add(
      WorkoutsCompanion.insert(
        id: workoutId,
        date: DateTime(2024, 1, 1).add(Duration(days: w)).toIso8601String().substring(0, 10),
        name: Value(name),
        status: const Value('completed'),
        actualDurationSec: Value(600 + (w * 37) % 4200),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final exerciseCount = 1 + (w % 5);
    for (var e = 0; e < exerciseCount; e++) {
      final workoutExerciseId = uuid.v4();
      final exercise = exercises[(w + e) % exercises.length];
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

    final tagCount = w % 4; // 0..3 tags, cycling
    for (var t = 0; t < tagCount; t++) {
      tagLinkCompanions.add(
        WorkoutTagLinksCompanion.insert(workoutId: workoutId, tagId: tags[(w + t) % tags.length].id),
      );
    }
  }

  await db.batch((batch) {
    batch.insertAll(db.workouts, workoutCompanions);
    batch.insertAll(db.workoutExercises, workoutExerciseCompanions);
    batch.insertAll(db.exerciseSets, setCompanions);
    batch.insertAll(db.workoutTagLinks, tagLinkCompanions);
  });
}

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

  testWidgets('History: slow, sustained drag over 1000 completed workouts', (tester) async {
    // Owner-reported (2026-07-28): even a *slow* continuous drag (not a
    // fling) over the workout list shows an occasional stutter every few
    // seconds. `fling()` above is a single ballistic gesture that settles
    // in under a second -- it can't reproduce a multi-second, steady,
    // human-paced drag. This uses a raw `TestGesture` with many small
    // `moveBy` steps (one simulated 16 ms frame each) to approximate that.
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_slowdrag_');
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
    await _seedRealisticHistory(db, count: 1000);

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
      final gesture = await tester.startGesture(tester.getCenter(list));
      // ~500 frames * 16 ms == ~8 s of simulated time, 15 px/frame ==
      // ~900 px/s -- a slow, steady drag, not a fling.
      for (var i = 0; i < 500; i++) {
        await gesture.moveBy(const Offset(0, -15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();
    }, reportKey: 'history_slow_drag_1000_workouts');

    printSummary(
      'History slow drag/1000 workouts',
      binding.reportData!['history_slow_drag_1000_workouts'] as Map<String, dynamic>,
    );
  });

  testWidgets('History: repeated short drag-lift cycles over 1000 workouts', (tester) async {
    // The single sustained drag above (`history_slow_drag_1000_workouts`)
    // showed jank only in its first few frames, then nothing for the rest
    // of a ~16 s drag -- that doesn't match "a stutter every few seconds"
    // for a single continuous gesture. A human scrolling "slowly" rarely
    // keeps one finger down for 16 s straight, though -- they drag a
    // short distance, lift, drag again, repeatedly. This simulates that:
    // if *starting* a drag has some fixed cost, repeating it every couple
    // of seconds would reproduce exactly the reported pattern.
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_dragcycles_');
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
    await _seedRealisticHistory(db, count: 1000);

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
      // 10 cycles: touch down, drag a short, controlled distance (not a
      // fling), lift, then a brief pause with finger off the screen --
      // roughly matching how someone actually scrolls "slowly" by hand.
      for (var cycle = 0; cycle < 10; cycle++) {
        final gesture = await tester.startGesture(tester.getCenter(list));
        for (var i = 0; i < 12; i++) {
          await gesture.moveBy(const Offset(0, -20));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        // Finger lifted: let any settle/decay animation finish, plus a
        // beat of "reading the screen" before the next touch-down.
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
      }
    }, reportKey: 'history_drag_cycles_1000_workouts');

    printSummary(
      'History drag-lift cycles/1000 workouts',
      binding.reportData!['history_drag_cycles_1000_workouts'] as Map<String, dynamic>,
    );
  });

  testWidgets('Workout editor: opening screen (push transition)', (tester) async {
    // Owner-reported (2026-07-28): a stutter during the push transition
    // itself -- e.g. right as the editor screen slides in after creating
    // a workout from a template -- not scrolling. 8 exercises x 4 sets is
    // a realistic template size (not the 15-25 used to stress scrolling
    // above); this measures the frames from the moment the tap that opens
    // the editor lands through the transition settling.
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_editor_open_');
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

    final exercises = await (db.select(db.exercises)..limit(8)).get();
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
      for (var s = 0; s < 4; s++) {
        setCompanions.add(
          ExerciseSetsCompanion.insert(
            id: uuid.v4(),
            workoutExerciseId: workoutExerciseId,
            setNumber: s + 1,
            plannedWeightKg: Value(60.0 + e * 2.5),
            plannedReps: Value(5 + (e % 8)),
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

    final tile = find.textContaining('8 exercises');
    expect(tile, findsOneWidget);

    await binding.watchPerformance(() async {
      await tester.tap(tile);
      await tester.pumpAndSettle();
    }, reportKey: 'workout_editor_open_transition');

    printSummary(
      'Workout editor open transition/8 exercises',
      binding.reportData!['workout_editor_open_transition'] as Map<String, dynamic>,
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

  testWidgets('Workout editor: slow scroll revealing new exercise cards', (tester) async {
    // Owner-reported (2026-07-28): scrolling the workout editor *slowly*
    // shows a stutter right as a new exercise card's sets come into view
    // from the bottom -- distinct from the fling scenario above (which
    // settles in under a second and can't show a slow, sustained reveal).
    // 25 exercises x 5 sets gives enough content to slowly scroll through
    // several card boundaries during one measured gesture.
    final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_editor_slowscroll_');
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

    final exercises = await (db.select(db.exercises)..limit(25)).get();
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
            plannedWeightKg: Value(60.0 + e * 2.5),
            plannedReps: Value(5 + (e % 8)),
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
    await tester.tap(find.textContaining('25 exercises'));
    await tester.pumpAndSettle();

    final scrollView = find.byType(CustomScrollView);
    expect(scrollView, findsOneWidget);

    await binding.watchPerformance(() async {
      final gesture = await tester.startGesture(tester.getCenter(scrollView));
      // ~600 frames * 16 ms == ~10 s, 15 px/frame == ~900 px/s -- slow,
      // steady drag, not a fling.
      for (var i = 0; i < 600; i++) {
        await gesture.moveBy(const Offset(0, -15));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();
    }, reportKey: 'workout_editor_slow_scroll_25_exercises');

    printSummary(
      'Workout editor slow scroll/25 exercises',
      binding.reportData!['workout_editor_slow_scroll_25_exercises'] as Map<String, dynamic>,
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
