import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/exercise_repository_impl.dart';
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
  late Directory tempDir;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    workouts = WorkoutRepositoryImpl(db);
    exercises = ExerciseRepositoryImpl(db);
    measurements = BodyMeasurementRepositoryImpl(db);
    types = MeasurementTypeRepositoryImpl(db);
    service = ExportService(workouts, measurements, types, exercises);
    tempDir = Directory.systemTemp.createTempSync('gymlog_export_test_');
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test(
    'writes a ZIP with all 4 entries',
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
    },
  );

  test('an empty database still produces a valid archive', () async {
    final file = await service.export(outputDirectory: tempDir);
    expect(file.existsSync(), isTrue);

    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    expect(archive.length, 4);
  });

  test(
    'a write failure rethrows (TS 10.1: no partial file left behind)',
    () async {
      final brokenDirectory = Directory(
        '${tempDir.path}${Platform.pathSeparator}does_not_exist'
        '${Platform.pathSeparator}nested',
      );

      await expectLater(
        service.export(outputDirectory: brokenDirectory),
        throwsA(anything),
      );
    },
  );
}
