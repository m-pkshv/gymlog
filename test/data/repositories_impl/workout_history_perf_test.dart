import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/data/seed/seed_runner.dart';
import 'package:gymlog/domain/models/workout_history_filter.dart';
import 'package:uuid/uuid.dart';

/// Stage 10 profiling (03_TECHNICAL_SPEC.md, section 11.6): "кадр < 16 мс на
/// скролле истории из 1000 тренировок". There is no device/emulator in this
/// working environment to trace actual frame times, so this measures the one
/// thing that *is* measurable headlessly and dominates data-loading latency:
/// how long `WorkoutRepository.watchHistory` (the query History's list
/// screen subscribes to, TS 11.6: "запросы истории — с пагинацией") takes to
/// produce its first emission against a file-backed (not in-memory) database
/// seeded with 1000 workouts x 3 exercises x 3 sets each (9000 sets,
/// matching the plan's "1000 workouts" scale). The assertion below is a
/// generous smoke ceiling against catastrophic regressions (e.g. an
/// accidental N+1 query), not a strict SLA — real on-device timing still
/// needs a live profiling pass once hardware is available.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'watchHistory over 1000 workouts (9000 sets) stays well under budget',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('gymlog_perf_test_');
      final dbFile = File('${tempDir.path}/gymlog.sqlite');
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final db = AppDatabase(NativeDatabase(dbFile));
      addTearDown(db.close);
      await SeedRunner(db).run();

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

      final seedStopwatch = Stopwatch()..start();
      await db.batch((batch) {
        batch.insertAll(db.workouts, workoutCompanions);
        batch.insertAll(db.workoutExercises, workoutExerciseCompanions);
        batch.insertAll(db.exerciseSets, setCompanions);
      });
      seedStopwatch.stop();
      // ignore: avoid_print
      print('Seeded 1000 workouts / 3000 exercises / 9000 sets in ${seedStopwatch.elapsedMilliseconds} ms');

      final repository = WorkoutRepositoryImpl(db);
      final queryStopwatch = Stopwatch()..start();
      final history = await repository.watchHistory(filter: emptyWorkoutHistoryFilter).first;
      queryStopwatch.stop();
      // ignore: avoid_print
      print('watchHistory() first emission for 1000 workouts: ${queryStopwatch.elapsedMilliseconds} ms');

      expect(history, hasLength(1000));
      // Generous ceiling: catches an accidental N+1 (which would take
      // seconds/tens of seconds at this scale), not a tight perf budget.
      expect(queryStopwatch.elapsedMilliseconds, lessThan(3000));

      final exerciseRepository = ExerciseRepositoryImpl(db);
      final exerciseQueryStopwatch = Stopwatch()..start();
      final exercises = await exerciseRepository.getAllForExport();
      exerciseQueryStopwatch.stop();
      // ignore: avoid_print
      print('ExerciseRepository.getAllForExport() for the 199-exercise seed: ${exerciseQueryStopwatch.elapsedMilliseconds} ms (${exercises.length} rows)');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
