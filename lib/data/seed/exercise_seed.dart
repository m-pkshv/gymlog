import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../database.dart';

/// Path to the built-in exercise seed file (06_DATA_MODEL.md, section 12).
/// `D-4`: until the project owner supplies real content (Q-1), this file
/// holds a 5-exercise placeholder set, one per `ExerciseType`.
const String exerciseSeedAssetPath = 'assets/seed/exercises_v1.json';

/// Parses [exerciseSeedAssetPath] and inserts the built-in exercises, their
/// secondary muscles and localized name/description
/// (06_DATA_MODEL.md, section 12). Called once by `SeedRunner`, inside its
/// transaction, so this doesn't guard against being run twice itself.
Future<void> insertExerciseSeed(AppDatabase db) async {
  final raw = await rootBundle.loadString(exerciseSeedAssetPath);
  final json = jsonDecode(raw) as Map<String, dynamic>;
  final exercises = json['exercises'] as List<dynamic>;

  final exerciseRows = <ExercisesCompanion>[];
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

    exerciseRows.add(
      ExercisesCompanion.insert(
        id: id,
        // Canonical name/description are the English seed text (used in
        // CSV/search); localized display text lives in ExerciseL10n.
        name: name['en']!,
        description: Value(description?['en']),
        exerciseType: item['type'] as String,
        primaryMuscleGroupId: Value(item['primaryMuscle'] as String?),
        equipmentId: Value(item['equipment'] as String?),
        effortMetric: Value(item['effortMetric'] as String? ?? 'none'),
        isBuiltIn: const Value(true),
        createdAt: DateTime.now().toUtc().toIso8601String(),
        updatedAt: DateTime.now().toUtc().toIso8601String(),
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
    batch.insertAll(db.exercises, exerciseRows);
    batch.insertAll(db.exerciseSecondaryMuscles, secondaryMuscleRows);
    batch.insertAll(db.exerciseL10n, l10nRows);
  });
}
