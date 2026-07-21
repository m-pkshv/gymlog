import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/import_export_operation_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/measurement_type_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/services/export/export_service.dart';

void main() {
  late AppDatabase db;
  late ExportService service;
  late WorkoutRepositoryImpl workouts;
  late ExerciseRepositoryImpl exercises;
  late BodyMeasurementRepositoryImpl measurements;
  late MeasurementTypeRepositoryImpl types;
  late ImportExportOperationRepositoryImpl operations;
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    measurements = BodyMeasurementRepositoryImpl(db);
    types = MeasurementTypeRepositoryImpl(db);
    operations = ImportExportOperationRepositoryImpl(db);
    service = ExportService(
      workouts,
      measurements,
      types,
      exercises,
      operations,
    );
    tempDir = Directory.systemTemp.createTempSync('gymlog_export_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'writes a ZIP with all 4 entries and journals success with correct counts',
    () async {
      final exercise = await exercises.create(
        name: 'Squat',
        exerciseType: ExerciseType.strength,
      );
      final workout = await workouts.createDraft(date: DateTime(2026, 7, 1));
      final workoutExercise = await workouts.addExercise(
        workoutId: workout.id,
        exerciseId: exercise.id,
      );
      final set = await workouts.addSet(
        workoutExerciseId: workoutExercise.id,
        isWarmup: false,
      );
      await workouts.updateSet(
        set.copyWith(isCompleted: true, actualWeightKg: 100, actualReps: 5),
      );
      await workouts.updateWorkout(
        workout.copyWith(status: WorkoutStatus.completed),
      );

      final typeId = (await types.create(
        nameCustom: 'Neck',
        unitKind: MeasurementUnitKind.length,
      )).id;
      await measurements.create(
        measurementTypeId: typeId,
        date: DateTime(2026, 7, 1),
        valueMetric: 38,
      );

      final file = await service.export(outputDirectory: tempDir);

      expect(file.existsSync(), isTrue);
      expect(file.path, startsWith(tempDir.path));
      expect(file.path, endsWith('.zip'));

      final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
      expect(archive.length, 4);
      expect(archive.findFile('manifest.json'), isNotNull);
      expect(archive.findFile('workouts.csv'), isNotNull);
      expect(archive.findFile('measurements.csv'), isNotNull);
      expect(archive.findFile('exercises.csv'), isNotNull);

      final journal = await operations.watchAll().first;
      expect(journal, hasLength(1));
      final entry = journal.single;
      expect(entry.status, ImportExportOperationStatus.success);
      expect(entry.itemCounts!.workouts, 1);
      expect(entry.itemCounts!.sets, 1);
      expect(entry.itemCounts!.measurements, 1);
      expect(entry.itemCounts!.exercises, 1);
    },
  );

  test(
    'an empty database still produces a valid archive and journals success '
    'with zero counts',
    () async {
      final file = await service.export(outputDirectory: tempDir);
      expect(file.existsSync(), isTrue);

      final journal = await operations.watchAll().first;
      final entry = journal.single;
      expect(entry.status, ImportExportOperationStatus.success);
      expect(entry.itemCounts!.workouts, 0);
      expect(entry.itemCounts!.sets, 0);
      expect(entry.itemCounts!.measurements, 0);
      expect(entry.itemCounts!.exercises, 0);
    },
  );

  test(
    'a write failure journals "failed" with an error summary and rethrows '
    '(TS 10.1: no partial file, but the failure must be recorded)',
    () async {
      final brokenDirectory = Directory(
        '${tempDir.path}${Platform.pathSeparator}does_not_exist'
        '${Platform.pathSeparator}nested',
      );

      await expectLater(
        service.export(outputDirectory: brokenDirectory),
        throwsA(anything),
      );

      final journal = await operations.watchAll().first;
      final entry = journal.single;
      expect(entry.status, ImportExportOperationStatus.failed);
      expect(entry.errorSummary, isNotNull);
      expect(entry.errorSummary, isNotEmpty);
    },
  );
}
