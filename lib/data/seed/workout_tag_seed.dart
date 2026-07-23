import 'package:drift/drift.dart';

import '../../core/constants.dart';
import '../../core/reference_data_ids.dart';
import '../database.dart';

/// English canonical names, matching [muscleGroupIds] order exactly. Only
/// used as the stored `WorkoutTag.name` (fallback/uniqueness value, same
/// "canonical English text" role `Exercise.name` plays, DM 12) — the label
/// actually shown for these built-in tags is looked up by id via
/// `workoutTagLabel` (RU/EN), not read from this field directly.
const List<String> _muscleGroupCanonicalNames = [
  'Chest',
  'Back',
  'Shoulders',
  'Rear Delts',
  'Biceps',
  'Triceps',
  'Forearms',
  'Abs',
  'Obliques',
  'Hip Flexors',
  'Glutes',
  'Quads',
  'Adductors',
  'Hamstrings',
  'Calves',
  'Full body',
  'Cardio',
];

/// Built-in workout tags (Stage 10, owner-reported): one per muscle group
/// (06_DATA_MODEL.md, section 5.1), so a workout can be tagged by what it
/// trained without typing a tag by hand every time. Owner-confirmed: these
/// are deletable exactly like a user-created tag — there is no "built-in,
/// can't delete" rule the way Exercises/MeasurementTypes have (a
/// `tag.id` matching a known muscle group id is what makes `workoutTagLabel`
/// translate it, not a schema flag) — so no `isBuiltIn` column was added to
/// `WorkoutTags`; this seed is the only thing distinguishing them from a
/// tag the owner types in by hand.
///
/// Inserted via a per-row `DoUpdate` (not `insertAllOnConflictUpdate`) that
/// only refreshes `name`/`colorHex`/`updatedAt` — mirrors
/// `insertExerciseSeed`'s caution: if the owner has already deleted one of
/// these tags (`isDeleted = true`), a later seed-version bump touching this
/// list must never silently resurrect it.
Future<void> insertWorkoutTagSeed(AppDatabase db) async {
  final now = DateTime.now().toUtc().toIso8601String();
  await db.batch((batch) {
    for (var i = 0; i < muscleGroupIds.length; i++) {
      final id = muscleGroupIds[i];
      final name = _muscleGroupCanonicalNames[i];
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
}
