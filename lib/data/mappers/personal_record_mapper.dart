import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../../domain/models/personal_record.dart';
import '../database.dart' as drift;
import 'workout_mapper.dart' show dateOnlyString;

extension PersonalRecordRowMapper on drift.PersonalRecord {
  PersonalRecord toDomain() {
    return PersonalRecord(
      exerciseId: exerciseId,
      recordType: RecordType.values.byName(recordType),
      keyValue: keyValue,
      value: value,
      workoutId: workoutId,
      exerciseSetId: exerciseSetId,
      achievedAt: DateTime.parse(achievedAt),
      computedAt: DateTime.parse(computedAt),
    );
  }
}

extension PersonalRecordCompanionMapper on PersonalRecord {
  drift.PersonalRecordsCompanion toInsertCompanion() {
    return drift.PersonalRecordsCompanion.insert(
      exerciseId: exerciseId,
      recordType: recordType.name,
      keyValue: Value(keyValue),
      value: value,
      workoutId: workoutId,
      exerciseSetId: Value(exerciseSetId),
      achievedAt: dateOnlyString(achievedAt),
      computedAt: computedAt.toUtc().toIso8601String(),
    );
  }
}
