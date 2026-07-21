import '../../domain/models/personal_record.dart';
import '../../domain/repositories/personal_record_repository.dart';
import '../database.dart' as drift;
import '../mappers/personal_record_mapper.dart';

/// Drift-backed `PersonalRecordRepository` (06_DATA_MODEL.md, section 6.10).
class PersonalRecordRepositoryImpl implements PersonalRecordRepository {
  PersonalRecordRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<PersonalRecord>> watchForExercise(String exerciseId) {
    final query = _db.select(
      _db.personalRecords,
    )..where((r) => r.exerciseId.equals(exerciseId));
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<void> replaceForExercise(
    String exerciseId,
    List<PersonalRecord> records,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.personalRecords,
      )..where((r) => r.exerciseId.equals(exerciseId))).go();
      for (final record in records) {
        await _db
            .into(_db.personalRecords)
            .insert(record.toInsertCompanion());
      }
    });
  }
}
