import '../models/workout_tag.dart';

/// Storage contract for `WorkoutTag` (06_DATA_MODEL.md, section 6.3).
/// Implemented in the Data layer (D-13); services/UI depend only on this
/// interface, never on `AppDatabase` directly. Uniqueness/length validation
/// (DM 6.3) is `WorkoutTagService`'s job, not this contract's.
abstract class WorkoutTagRepository {
  /// All non-deleted tags, most recently created first — the tag picker
  /// (S-03) and, once Stage 3's history filters land, the tag filter.
  Stream<List<WorkoutTag>> watchAll();

  /// One-shot read of the same set `watchAll` streams — used for the
  /// uniqueness check in `WorkoutTagService.create`.
  Future<List<WorkoutTag>> getAll();

  Future<WorkoutTag> create({required String name, required String colorHex});
}
