import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../database.dart';

/// Built-in tag ids (Stage 12, owner-reported, 2026-08-02): a curated
/// subset of 13, not a 1:1 mirror of `muscleGroupIds` (18 tags, Stage 10)
/// -- the array order here no longer drives what the user sees (the
/// picker sheet/management screen/history filter all sort the fetched
/// list alphabetically by translated label instead, since a fixed DB
/// position turned out fragile: a tag added to an already-seeded install
/// gets today's `createdAt`, sorting it to the top of the old
/// `createdAt DESC` order regardless of where it sits in this array).
const List<String> _seedTagIds = [
  'chest',
  'back',
  legsWorkoutTagId,
  'shoulders',
  'biceps',
  'triceps',
  'forearms',
  'abs',
  'glutes',
  'calves',
  'full_body',
  crossfitWorkoutTagId,
  'cardio_system',
];

/// English canonical names, matching [_seedTagIds] order exactly. Only used
/// as the stored `WorkoutTag.name` (fallback/uniqueness value, same
/// "canonical English text" role `Exercise.name` plays, DM 12) — the label
/// actually shown for these built-in tags is looked up by id via
/// `workoutTagLabel` (RU/EN), not read from this field directly.
const List<String> _seedTagCanonicalNames = [
  'Chest',
  'Back',
  'Legs',
  'Shoulders',
  'Biceps',
  'Triceps',
  'Forearms',
  'Abs',
  'Glutes',
  'Calves',
  'Full body',
  'Crossfit',
  'Cardio',
];

/// Muscle-group tags dropped from the built-in set (Stage 12,
/// owner-confirmed 2026-08-02): Rear Delts/Obliques/Hip Flexors/Quads/
/// Adductors/Hamstrings are now all covered by the single broader
/// [legsWorkoutTagId] tag. Soft-deleted (DM 10) rather than left in
/// `_seedTagIds` and forgotten -- an already-seeded install (the owner's
/// device) still has these 6 rows from the Stage 10 seed and would
/// otherwise keep showing them forever, since this seed never deletes a
/// row it simply stops mentioning.
const List<String> _removedTagIds = [
  'rear_delts',
  'obliques',
  'hip_flexors',
  'quads',
  'adductors',
  'hamstrings',
];

/// Built-in workout tags (Stage 10, owner-reported; trimmed and
/// generalized on Stage 12, 2026-08-02), so a workout can be tagged by
/// what it trained without typing a tag by hand every time.
/// Owner-confirmed: these are deletable exactly like a user-created tag —
/// there is no "built-in, can't delete" rule the way Exercises/
/// MeasurementTypes have (a `tag.id` matching a known muscle group id, or
/// one of the standalone ids in `core/constants.dart`, is what makes
/// `workoutTagLabel` translate it, not a schema flag) — so no `isBuiltIn`
/// column was added to `WorkoutTags`; this seed is the only thing
/// distinguishing them from a tag the owner types in by hand.
///
/// Inserted via a per-row `DoUpdate` (not `insertAllOnConflictUpdate`) that
/// only refreshes `name`/`colorHex`/`updatedAt` — mirrors
/// `insertExerciseSeed`'s caution: if the owner has already deleted one of
/// these tags (`isDeleted = true`), a later seed-version bump touching this
/// list must never silently resurrect it.
Future<void> insertWorkoutTagSeed(AppDatabase db) async {
  final now = DateTime.now().toUtc().toIso8601String();
  await db.batch((batch) {
    for (var i = 0; i < _seedTagIds.length; i++) {
      final id = _seedTagIds[i];
      final name = _seedTagCanonicalNames[i];
      final colorHex = workoutTagColorPalette[i % workoutTagColorPalette.length];
      batch.insert(
        db.workoutTags,
        WorkoutTagsCompanion.insert(
          id: id,
          name: name,
          colorHex: Value(colorHex),
          createdAt: now,
          updatedAt: now,
        ),
        onConflict: DoUpdate(
          (_) => WorkoutTagsCompanion(
            name: Value(name),
            colorHex: Value(colorHex),
            updatedAt: Value(now),
          ),
        ),
      );
    }
  });

  // Owner-confirmed (2026-08-02): silently drop any assignment of a
  // removed tag rather than trying to guess which of the 6 a tagged
  // workout "should" become instead (DM 10's usual soft-delete + drop
  // links, same as a manual tag deletion does). A no-op on a fresh
  // install, where these ids were never inserted in the first place.
  await (db.delete(
    db.workoutTagLinks,
  )..where((l) => l.tagId.isIn(_removedTagIds))).go();
  await (db.update(db.workoutTags)..where((t) => t.id.isIn(_removedTagIds)))
      .write(
        WorkoutTagsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(now),
        ),
      );
}
