import 'dart:io';

import '../../core/constants.dart';
import '../../domain/models/import_export_operation.dart';
import '../../domain/repositories/body_measurement_repository.dart';
import '../../domain/repositories/exercise_repository.dart';
import '../../domain/repositories/import_export_operation_repository.dart';
import '../../domain/repositories/measurement_type_repository.dart';
import '../../domain/repositories/workout_repository.dart';
import 'export_archive.dart';
import 'export_file_name.dart';
import 'exercises_csv.dart';
import 'manifest.dart';
import 'measurements_csv.dart';
import 'workouts_csv.dart';

/// Runs the full TS 10 export pipeline: bulk-read every repository →
/// generate the three CSVs → assemble the ZIP → write it to disk → journal
/// the attempt (06_DATA_MODEL.md, section 6.13). The single point where
/// Stage 8's other pieces (Steps 1-4) come together.
class ExportService {
  ExportService(
    this._workoutRepository,
    this._bodyMeasurementRepository,
    this._measurementTypeRepository,
    this._exerciseRepository,
    this._operationRepository,
  );

  final WorkoutRepository _workoutRepository;
  final BodyMeasurementRepository _bodyMeasurementRepository;
  final MeasurementTypeRepository _measurementTypeRepository;
  final ExerciseRepository _exerciseRepository;
  final ImportExportOperationRepository _operationRepository;

  /// Writes the finished ZIP into [outputDirectory] and returns its `File`.
  /// [outputDirectory] is the caller's job to resolve (real app code passes
  /// `path_provider`'s temp directory; this class only knows `dart:io`, so
  /// it stays testable without a platform channel).
  ///
  /// Journals the attempt as `success` or `failed` either way (DM 6.13). On
  /// failure this rethrows the original exception after journaling it --
  /// TS 10.1's "сбой... даёт failed без частичного файла наружу" means the
  /// journal must record the failure, not that this service should swallow
  /// the error; the caller's own try/catch (every other screen in this app
  /// logs and shows a snackbar the same way) still sees it.
  Future<File> export({required Directory outputDirectory}) async {
    final operation = await _operationRepository.startExport(
      formatVersion: ExportFormat.formatVersion,
    );
    try {
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

      await _operationRepository.markSuccess(
        operationId: operation.id,
        counts: ImportExportOperationCounts(
          workouts: workouts.length,
          sets: setCount,
          measurements: measurements.length,
          exercises: exercises.length,
        ),
      );
      return file;
    } catch (error) {
      await _operationRepository.markFailed(
        operationId: operation.id,
        errorSummary: error.toString(),
      );
      rethrow;
    }
  }
}
