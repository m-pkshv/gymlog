import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database.dart';

/// Path to the built-in exercise seed file (06_DATA_MODEL.md, section 12).
/// `D-4`: content arrives from the owner incrementally (Q-1) — as of v2
/// this holds the first batch of real exercises, not the full catalog yet.
const String exerciseSeedAssetPath = 'assets/seed/exercises_v1.json';

/// Parses [exerciseSeedAssetPath] and upserts the built-in exercises, their
/// secondary muscles and localized name/description
/// (06_DATA_MODEL.md, section 12). Called by `SeedRunner` inside its
/// transaction whenever `currentSeedVersion` advances — which can be on an
/// install that already ran an earlier version, so this must not assume a
/// fresh, empty table.
///
/// Exercises upsert on `id`: content fields are always overwritten, but
/// `isArchived` and `createdAt` are deliberately left out of the update —
/// re-running the seed must not silently un-archive an exercise the owner
/// archived, or reset its creation date (DM 12: "существующие обновляются
/// целиком, кроме isArchived"). Secondary-muscle links and localized names
/// have no state of their own, so they're simply rebuilt (delete + insert)
/// for every exercise present in this run of the seed file.
Future<void> insertExerciseSeed(AppDatabase db) async {
  final raw = await rootBundle.loadString(exerciseSeedAssetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final exercises = json['exercises'] as List<dynamic>;
  final now = DateTime.now().toUtc().toIso8601String();

  final exerciseIds = <String>[];
  final inserts = <ExercisesCompanion>[];
  final updates = <ExercisesCompanion>[];
  final secondaryMuscleRows = <ExerciseSecondaryMusclesCompanion>[];
  final l10nRows = <ExerciseL10nCompanion>[];

  for (final entry in exercises) {
    final item = entry as Map<String, dynamic>;
    final id = item['id'] as String;
    final name = (item['name'] as Map<String, dynamic>).cast<String, String>();
    final description = (item['description'] as Map<String, dynamic>?)
        ?.cast<String, String>();
    final secondaryMuscles = (item['secondaryMuscles'] as List<dynamic>)
        .cast<String>();
    // Canonical name/description are the English seed text (used in
    // CSV/search); localized display text lives in ExerciseL10n.
    final canonicalName = name['en']!;
    final canonicalDescription = description?['en'];
    final exerciseType = item['type'] as String;
    final primaryMuscleGroupId = item['primaryMuscle'] as String?;
    final equipmentId = item['equipment'] as String?;
    final effortMetric = item['effortMetric'] as String? ?? 'none';

    exerciseIds.add(id);
    inserts.add(
      ExercisesCompanion.insert(
        id: id,
        name: canonicalName,
        description: Value(canonicalDescription),
        exerciseType: exerciseType,
        primaryMuscleGroupId: Value(primaryMuscleGroupId),
        equipmentId: Value(equipmentId),
        effortMetric: Value(effortMetric),
        isBuiltIn: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
    );
    updates.add(
      ExercisesCompanion(
        name: Value(canonicalName),
        description: Value(canonicalDescription),
        exerciseType: Value(exerciseType),
        primaryMuscleGroupId: Value(primaryMuscleGroupId),
        equipmentId: Value(equipmentId),
        effortMetric: Value(effortMetric),
        updatedAt: Value(now),
      ),
    );

    for (final muscleGroupId in secondaryMuscles) {
      secondaryMuscleRows.add(
        ExerciseSecondaryMusclesCompanion.insert(
          exerciseId: id,
          muscleGroupId: muscleGroupId,
        ),
      );
    }

    for (final localeEntry in name.entries) {
      l10nRows.add(
        ExerciseL10nCompanion.insert(
          exerciseId: id,
          locale: localeEntry.key,
          name: localeEntry.value,
          description: Value(description?[localeEntry.key]),
        ),
      );
    }
  }

  await db.batch((batch) {
    for (var i = 0; i < inserts.length; i++) {
      final update = updates[i];
      batch.insert(
        db.exercises,
        inserts[i],
        onConflict: DoUpdate((_) => update),
      );
    }
    batch.deleteWhere(
      db.exerciseSecondaryMuscles,
      (s) => s.exerciseId.isIn(exerciseIds),
    );
    batch.deleteWhere(db.exerciseL10n, (l) => l.exerciseId.isIn(exerciseIds));
    batch.insertAll(db.exerciseSecondaryMuscles, secondaryMuscleRows);
    batch.insertAll(db.exerciseL10n, l10nRows);
  });
}
