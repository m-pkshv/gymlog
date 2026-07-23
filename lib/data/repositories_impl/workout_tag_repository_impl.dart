import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/workout_tag.dart';
import '../../domain/repositories/workout_tag_repository.dart';
import '../database.dart' as drift;
import '../mappers/workout_tag_mapper.dart';

/// Drift-backed `WorkoutTagRepository` (06_DATA_MODEL.md, section 6.3).
class WorkoutTagRepositoryImpl implements WorkoutTagRepository {
  WorkoutTagRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Stream<List<WorkoutTag>> watchAll() {
    final query = _db.select(_db.workoutTags)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (rows) => rows.map((row) => row.toDomain()).toList(),
    );
  }

  @override
  Future<List<WorkoutTag>> getAll() async {
    final rows = await (_db.select(
      _db.workoutTags,
    )..where((t) => t.isDeleted.equals(false))).get();
    return rows.map((row) => row.toDomain()).toList();
  }

  @override
  Future<WorkoutTag> create({
    required String name,
    required String colorHex,
  }) async {
    final now = DateTime.now().toUtc();
    final tag = WorkoutTag(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
      isHidden: false,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
    await _db.into(_db.workoutTags).insert(tag.toInsertCompanion());
    return tag;
  }

  @override
  Future<int> countWorkoutsUsingTag(String tagId) async {
    final query = _db.select(_db.workoutTagLinks).join([
      innerJoin(
        _db.workouts,
        _db.workouts.id.equalsExp(_db.workoutTagLinks.workoutId),
      ),
    ])..where(
      _db.workoutTagLinks.tagId.equals(tagId) &
          _db.workouts.isDeleted.equals(false),
    );
    final rows = await query.get();
    return rows.length;
  }

  @override
  Future<void> delete(String tagId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _db.transaction(() async {
      await (_db.delete(
        _db.workoutTagLinks,
      )..where((l) => l.tagId.equals(tagId))).go();
      await (_db.update(
        _db.workoutTags,
      )..where((t) => t.id.equals(tagId))).write(
        drift.WorkoutTagsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
    });
  }
}
