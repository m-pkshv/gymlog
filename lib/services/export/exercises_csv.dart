import '../../domain/models/exercise.dart';
import 'csv_format.dart';

const exercisesCsvHeader = [
  'exercise_id',
  'name',
  'type',
  'is_built_in',
  'is_archived',
  'primary_muscle',
  'secondary_muscles',
  'equipment',
  'description',
  'youtube_url',
];

/// `exercises.csv` (03_TECHNICAL_SPEC.md, section 10.5). `primary_muscle`/
/// `equipment` are the raw reference-data ids (e.g. `chest`, `barbell`),
/// not localized labels -- same locale-independence principle as
/// `measurements.csv`'s `type` slug (TS 10.1). [exercises] must already be
/// the full, already-filtered set to export (non-deleted; archived
/// exercises ARE included, TS 10.1 -- "история на них ссылается") -- this
/// function only formats and sorts, it never queries the database. Row
/// order (by id) isn't mandated by TS 10.5; this is a deterministic
/// default, not a format requirement.
String buildExercisesCsv(List<Exercise> exercises) {
  final sorted = [...exercises]..sort((a, b) => a.id.compareTo(b.id));

  final buffer = StringBuffer()..write(csvRow(exercisesCsvHeader));
  for (final exercise in sorted) {
    buffer.write(
      csvRow([
        exercise.id,
        exercise.name,
        exercise.exerciseType.name,
        formatCsvBool(exercise.isBuiltIn),
        formatCsvBool(exercise.isArchived),
        exercise.primaryMuscleGroupId ?? '',
        exercise.secondaryMuscleGroupIds.join(';'),
        exercise.equipmentId ?? '',
        exercise.description ?? '',
        exercise.youtubeUrl ?? '',
      ]),
    );
  }
  return buffer.toString();
}
