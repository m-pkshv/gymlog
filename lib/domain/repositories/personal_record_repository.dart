import '../models/personal_record.dart';

/// Storage contract for the personal-record cache (D-8, 06_DATA_MODEL.md
/// section 6.10). Implemented in the Data layer; the records service (once
/// written) is the only writer — the single point of truth for the D-8
/// formulas — this contract just persists whatever it computes.
abstract class PersonalRecordRepository {
  /// All cached records for one exercise (S-10 records list). Empty if none
  /// have been computed yet (no completed occurrences, or nothing
  /// PR-eligible in them).
  Stream<List<PersonalRecord>> watchForExercise(String exerciseId);

  /// Replaces the entire cached record set for [exerciseId] with [records]
  /// in one transaction. The recompute algorithm always rebuilds an
  /// exercise's records from scratch (06_DATA_MODEL.md, section 6.10: "не
  /// является источником истины; полностью перестраивается из истории"),
  /// so this never patches individual rows — a record type/weight
  /// combination that's no longer valid needs to disappear, not linger.
  Future<void> replaceForExercise(
    String exerciseId,
    List<PersonalRecord> records,
  );
}
