import 'package:drift/drift.dart';

import '../database.dart';
import 'exercise_seed.dart';
import 'reference_data_seed.dart';
import 'workout_tag_seed.dart';
import 'workout_template_seed.dart';

/// Current seed content version (06_DATA_MODEL.md, section 12). Bump this
/// when the seed data itself changes; `SeedRunner` re-applies the seed for
/// rows the app hasn't already stored a matching version for.
///
/// v2 (2026-07-20): replaced the 5 one-per-type placeholder exercises
/// (`ASSUMPTION(placeholder-exercise-content)`, Stage 0) with the first 9
/// real exercises supplied by the owner (Q-1, partial — more to come).
/// `insertReferenceDataSeed`/`insertExerciseSeed` upsert rather than plain
/// `insertAll` starting here, so bumping this on an already-seeded install
/// doesn't crash on a primary-key conflict.
/// v3 (2026-07-20): the owner's full base exercise list (199 exercises,
/// Q-1) — supersedes the v2 batch of 9 (several of those were renamed/
/// refined in the full list; matched by the same generated id where the
/// exercise carried over unchanged, e.g. `barbell_back_squat`).
/// v4 (2026-07-23, Stage 10, owner-reported): 17 built-in workout tags, one
/// per muscle group (`workout_tag_seed.dart`).
/// v5 (2026-07-27, Stage 10 redesign, owner-reported): 5 starter workout
/// templates (`workout_template_seed.dart`) — ordinary, fully editable/
/// deletable templates (no `isBuiltIn` flag on `WorkoutTemplates`), just
/// convenience starter content.
/// v6 (2026-08-01, owner-supplied list): 160 additional exercises (grip/
/// stance/equipment variants and functional/cardio movements) appended to
/// the v3 base list — 197 of the owner's ~358 supplied rows already matched
/// an existing exercise by English name and were skipped rather than
/// duplicated; catalog grows from 199 to 359.
/// v7 (2026-08-02, owner-reported): one more built-in workout tag, "Legs"
/// (`legsWorkoutTagId`, core/constants.dart) — not a muscle group, spliced
/// into `workout_tag_seed.dart`'s seeded order right after Obliques and
/// before Hip Flexors, the owner's requested position.
/// v8 (2026-08-02, owner-confirmed): the built-in tag list is trimmed from
/// 18 to 13 and the display order switched to alphabetical-by-translated-
/// label (computed on screen, not stored) — Rear Delts/Obliques/Hip
/// Flexors/Quads/Adductors/Hamstrings are dropped (soft-deleted, any
/// existing assignment silently removed) in favor of the single "Legs"
/// tag, and a new standalone "Crossfit" tag (`crossfitWorkoutTagId`) is
/// added.
/// v9 (2026-08-04, redesign_v2, owner-requested): a new "Legs" muscle
/// group (`reference_data_ids.dart`'s `muscleGroupIds`, 17→18) — purely
/// additive, owner confirmed no existing exercise's primary/secondary
/// muscle changes. Not the same row as the "Legs" *workout tag* seeded in
/// v7/v8 (`WorkoutTags` is a different table).
/// v10 (2026-08-05, redesign_v2, owner-requested): two new equipment ids,
/// "Pull-up bar" and "Dip bars" (`equipmentIds`, 9→11), split out of the
/// catch-all "Other" bucket (icon-by-equipment planning found it was a
/// ~49-exercise grab bag) — 11 pull-up/chin-up/hanging exercises and 2
/// dip exercises reclassified accordingly in `exercises_v1.json`. Also
/// fixes a real pre-existing data bug found in the same review: 17
/// exercises with "cable" literally in their name/id (e.g.
/// `cable_crossover`, `high_cable_curl`) had been misclassified as
/// `machine` instead of `cable` since the v6 (2026-08-01) full-list
/// import — corrected in the same seed update.
const int currentSeedVersion = 10;

/// Loads built-in reference data and the placeholder exercise catalog
/// (06_DATA_MODEL.md, section 12) on first run, tracked by
/// `SeedInfoTable.seedVersion` so a later run doesn't duplicate rows
/// (02_DEVELOPMENT_PLAN.md, Stage 0 acceptance criteria).
class SeedRunner {
  const SeedRunner(this._db);

  final AppDatabase _db;

  /// Runs the seed if it hasn't run yet for [currentSeedVersion]. Safe to
  /// call on every app start.
  Future<void> run() async {
    final existing = await (_db.select(
      _db.seedInfoTable,
    )..where((row) => row.id.equals(0))).getSingleOrNull();

    if (existing != null && existing.seedVersion >= currentSeedVersion) {
      return;
    }

    await _db.transaction(() async {
      await insertReferenceDataSeed(_db);
      await insertExerciseSeed(_db);
      await insertWorkoutTagSeed(_db);
      await insertWorkoutTemplateSeed(_db);
      await _db
          .into(_db.seedInfoTable)
          .insertOnConflictUpdate(
            SeedInfoTableCompanion.insert(
              id: const Value(0),
              seedVersion: currentSeedVersion,
            ),
          );
    });
  }
}
