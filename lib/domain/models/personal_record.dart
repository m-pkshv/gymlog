import '../enums.dart';

/// One cached personal-record row (06_DATA_MODEL.md, section 6.10, D-8).
/// Not a source of truth — fully rebuilt from history by the records
/// service whenever a trigger fires (workout completed/resumed/deleted/
/// restored, a completed workout's set edited, or its exercise archived).
/// [keyValue] holds the weight (kg) for [RecordType.maxRepsAtWeight] rows
/// (there can be several of those per exercise, one per weight ever used)
/// and is `null` for every other record type.
class PersonalRecord {
  const PersonalRecord({
    required this.exerciseId,
    required this.recordType,
    required this.value,
    required this.workoutId,
    required this.achievedAt,
    required this.computedAt,
    this.keyValue,
    this.exerciseSetId,
  });

  final String exerciseId;
  final RecordType recordType;
  final double? keyValue;

  /// The record's value in metric units.
  final double value;
  final String workoutId;

  /// The specific set that achieved the record; `null` for
  /// [RecordType.maxVolumeWorkout], which is a workout-level total rather
  /// than a single set's value.
  final String? exerciseSetId;

  /// Local calendar date of the source workout.
  final DateTime achievedAt;
  final DateTime computedAt;
}
