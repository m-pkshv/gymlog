import 'package:drift/drift.dart';

import '../database.dart';
import 'exercise_seed.dart';
import 'reference_data_seed.dart';

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
const int currentSeedVersion = 2;

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
