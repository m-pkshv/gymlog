import 'package:drift/drift.dart';

import '../database.dart';
import 'exercise_seed.dart';
import 'reference_data_seed.dart';
import 'workout_tag_seed.dart';

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
const int currentSeedVersion = 4;

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
