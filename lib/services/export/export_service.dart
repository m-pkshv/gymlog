import 'dart:io';

import '../../core/constants.dart';
import '../../domain/repositories/body_measurement_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/measurement_type_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import 'export_archive.dart';
import 'export_file_name.dart';
import 'exercises_csv.dart';
import 'manifest.dart';
import 'measurements_csv.dart';
import 'workouts_csv.dart';

/// Runs the full TS 10 export pipeline: bulk-read every repository →
/// generate the three CSVs → assemble the ZIP → write it to disk. The
/// single point where Stage 8's other pieces (Steps 1-4) come together.
/// Used to also journal each attempt (06_DATA_MODEL.md, former section
/// 6.13) -- removed in Stage 11 (owner-reported: no user-facing value, and
/// the caller's own try/catch already surfaces failures via a snackbar).
class ExportService {
  ExportService(
    this._workoutRepository,
    this._bodyMeasurementRepository,
    this._measurementTypeRepository,
    this._exerciseRepository,
  );

  final WorkoutRepository _workoutRepository;
  final BodyMeasurementRepository _bodyMeasurementRepository;
  final MeasurementTypeRepository _measurementTypeRepository;
  final ExerciseRepository _exerciseRepository;

  /// Writes the finished ZIP into [outputDirectory] and returns its `File`.
  /// [outputDirectory] is the caller's job to resolve (real app code passes
  /// `path_provider`'s temp directory; this class only knows `dart:io`, so
  /// it stays testable without a platform channel). Any failure propagates
  /// to the caller unchanged; the caller's own try/catch (every screen in
  /// this app logs and shows a snackbar the same way) handles it.
  Future<File> export({required Directory outputDirectory}) async {
    final workouts = await _workoutRepository.getAllForExport();
    final measurements = await _bodyMeasurementRepository.getAllForExport();
    final types = await _measurementTypeRepository.getAll();
    final exercises = await _exerciseRepository.getAllForExport();
    final typesById = {for (final type in types) type.id: type};

    var setCount = 0;
    for (final details in workouts) {
      for (final exerciseDetails in details.exercises) {
        setCount += exerciseDetails.sets.length;
      }
    }

    final now = DateTime.now().toUtc();
    final zipBytes = buildExportArchive(
      manifest: ExportManifest(
        formatVersion: ExportFormat.formatVersion,
        appVersion: ExportFormat.appVersion,
        exportedAtUtc: now,
        workoutCount: workouts.length,
        setCount: setCount,
        measurementCount: measurements.length,
        exerciseCount: exercises.length,
      ),
      workoutsCsv: buildWorkoutsCsv(workouts),
      measurementsCsv: buildMeasurementsCsv(measurements, typesById),
      exercisesCsv: buildExercisesCsv(exercises),
    );

    final file = File(
      '${outputDirectory.path}${Platform.pathSeparator}${exportZipFileName(now)}',
    );
    await file.writeAsBytes(zipBytes, flush: true);
    return file;
  }
}
