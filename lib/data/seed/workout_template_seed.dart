import 'package:drift/drift.dart';

import '../database.dart';

/// One planned set of a `_SeedExercise` — mirrors the `strength`/`time`
/// subset of `TemplateSet`'s planned fields actually used below (no
/// built-in template here uses `reps`-only or `cardio` exercises).
class _SeedSet {
  const _SeedSet({this.weightKg, this.reps, this.durationSec});

  final double? weightKg;
  final int? reps;
  final int? durationSec;
}

class _SeedExercise {
  const _SeedExercise(this.exerciseId, this.sets);

  final String exerciseId;
  final List<_SeedSet> sets;
}

class _SeedTemplate {
  const _SeedTemplate(this.id, this.name, this.exercises);

  final String id;
  final String name;
  final List<_SeedExercise> exercises;
}

/// 5 owner-requested starter templates (Stage 10 redesign, owner-supplied
/// exercise lists) — plausible-but-arbitrary set/rep/weight numbers
/// (owner-confirmed: "не принципиально, но желательно правдоподобные"),
/// not derived from any real training program. `exerciseId`s reference
/// `exercises_v1.json`'s ids; 7 of the owner's 26 exercise names had no
/// exact-name match in the catalog (only a more specific variant) --
/// substitutions confirmed with the owner before writing this file:
/// "Отжимания на брусьях" -> `chest_dip` ("...с акцентом на грудь"),
/// "Сгибание рук с гантелями" -> `standing_dumbbell_curl` ("Подъём
/// гантелей на бицепс стоя"), "Подтягивания" -> `pull_up` ("...прямым
/// хватом"), "Французский жим" -> `lying_triceps_extension` ("...лёжа"),
/// "Румынская тяга" -> `barbell_romanian_deadlift` ("...со штангой"),
/// "Сгибание ног в тренажёре" -> `lying_leg_curl` ("...лёжа"), "Махи
/// гантелями в стороны" -> `dumbbell_lateral_raise` ("Подъём гантелей в
/// стороны", same movement).
const List<_SeedTemplate> _templates = [
  _SeedTemplate('seed_template_chest_biceps', 'Грудь + Бицепс', [
    _SeedExercise('barbell_bench_press', [
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
    ]),
    _SeedExercise('incline_dumbbell_press', [
      _SeedSet(weightKg: 22, reps: 10),
      _SeedSet(weightKg: 22, reps: 10),
      _SeedSet(weightKg: 22, reps: 10),
    ]),
    _SeedExercise('cable_crossover', [
      _SeedSet(weightKg: 15, reps: 12),
      _SeedSet(weightKg: 15, reps: 12),
      _SeedSet(weightKg: 15, reps: 12),
    ]),
    _SeedExercise('chest_dip', [
      _SeedSet(reps: 10),
      _SeedSet(reps: 10),
      _SeedSet(reps: 10),
    ]),
    _SeedExercise('barbell_curl', [
      _SeedSet(weightKg: 30, reps: 10),
      _SeedSet(weightKg: 30, reps: 10),
      _SeedSet(weightKg: 30, reps: 10),
    ]),
    _SeedExercise('standing_dumbbell_curl', [
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
    ]),
    _SeedExercise('hammer_curl', [
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
    ]),
  ]),
  _SeedTemplate('seed_template_back_triceps', 'Спина + Трицепс', [
    _SeedExercise('pull_up', [
      _SeedSet(reps: 8),
      _SeedSet(reps: 8),
      _SeedSet(reps: 8),
      _SeedSet(reps: 8),
    ]),
    _SeedExercise('barbell_bent_over_row', [
      _SeedSet(weightKg: 50, reps: 8),
      _SeedSet(weightKg: 50, reps: 8),
      _SeedSet(weightKg: 50, reps: 8),
      _SeedSet(weightKg: 50, reps: 8),
    ]),
    _SeedExercise('lat_pulldown', [
      _SeedSet(weightKg: 55, reps: 10),
      _SeedSet(weightKg: 55, reps: 10),
      _SeedSet(weightKg: 55, reps: 10),
      _SeedSet(weightKg: 55, reps: 10),
    ]),
    _SeedExercise('seated_cable_row', [
      _SeedSet(weightKg: 60, reps: 10),
      _SeedSet(weightKg: 60, reps: 10),
      _SeedSet(weightKg: 60, reps: 10),
      _SeedSet(weightKg: 60, reps: 10),
    ]),
    _SeedExercise('close_grip_bench_press', [
      _SeedSet(weightKg: 45, reps: 8),
      _SeedSet(weightKg: 45, reps: 8),
      _SeedSet(weightKg: 45, reps: 8),
      _SeedSet(weightKg: 45, reps: 8),
    ]),
    _SeedExercise('cable_triceps_pushdown', [
      _SeedSet(weightKg: 25, reps: 12),
      _SeedSet(weightKg: 25, reps: 12),
      _SeedSet(weightKg: 25, reps: 12),
    ]),
    _SeedExercise('lying_triceps_extension', [
      _SeedSet(weightKg: 25, reps: 10),
      _SeedSet(weightKg: 25, reps: 10),
      _SeedSet(weightKg: 25, reps: 10),
    ]),
  ]),
  _SeedTemplate('seed_template_legs_shoulders', 'Ноги + Плечи', [
    _SeedExercise('barbell_back_squat', [
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
    ]),
    _SeedExercise('leg_press', [
      _SeedSet(weightKg: 140, reps: 10),
      _SeedSet(weightKg: 140, reps: 10),
      _SeedSet(weightKg: 140, reps: 10),
      _SeedSet(weightKg: 140, reps: 10),
    ]),
    _SeedExercise('barbell_romanian_deadlift', [
      _SeedSet(weightKg: 70, reps: 10),
      _SeedSet(weightKg: 70, reps: 10),
      _SeedSet(weightKg: 70, reps: 10),
    ]),
    _SeedExercise('lying_leg_curl', [
      _SeedSet(weightKg: 35, reps: 12),
      _SeedSet(weightKg: 35, reps: 12),
      _SeedSet(weightKg: 35, reps: 12),
    ]),
    _SeedExercise('standing_calf_raise', [
      _SeedSet(weightKg: 40, reps: 15),
      _SeedSet(weightKg: 40, reps: 15),
      _SeedSet(weightKg: 40, reps: 15),
      _SeedSet(weightKg: 40, reps: 15),
    ]),
    _SeedExercise('seated_dumbbell_shoulder_press', [
      _SeedSet(weightKg: 18, reps: 10),
      _SeedSet(weightKg: 18, reps: 10),
      _SeedSet(weightKg: 18, reps: 10),
    ]),
    _SeedExercise('dumbbell_lateral_raise', [
      _SeedSet(weightKg: 8, reps: 12),
      _SeedSet(weightKg: 8, reps: 12),
      _SeedSet(weightKg: 8, reps: 12),
    ]),
    _SeedExercise('reverse_pec_deck_fly', [
      _SeedSet(weightKg: 20, reps: 12),
      _SeedSet(weightKg: 20, reps: 12),
      _SeedSet(weightKg: 20, reps: 12),
    ]),
  ]),
  _SeedTemplate('seed_template_full_body_a', 'Full Body A', [
    _SeedExercise('barbell_back_squat', [
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
      _SeedSet(weightKg: 80, reps: 8),
    ]),
    _SeedExercise('barbell_bench_press', [
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
      _SeedSet(weightKg: 60, reps: 8),
    ]),
    _SeedExercise('lat_pulldown', [
      _SeedSet(weightKg: 55, reps: 10),
      _SeedSet(weightKg: 55, reps: 10),
      _SeedSet(weightKg: 55, reps: 10),
    ]),
    _SeedExercise('barbell_romanian_deadlift', [
      _SeedSet(weightKg: 70, reps: 10),
      _SeedSet(weightKg: 70, reps: 10),
      _SeedSet(weightKg: 70, reps: 10),
    ]),
    _SeedExercise('seated_dumbbell_shoulder_press', [
      _SeedSet(weightKg: 18, reps: 10),
      _SeedSet(weightKg: 18, reps: 10),
      _SeedSet(weightKg: 18, reps: 10),
    ]),
    _SeedExercise('standing_dumbbell_curl', [
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
    ]),
    _SeedExercise('cable_triceps_pushdown', [
      _SeedSet(weightKg: 25, reps: 12),
      _SeedSet(weightKg: 25, reps: 12),
      _SeedSet(weightKg: 25, reps: 12),
    ]),
    _SeedExercise('crunch', [
      _SeedSet(reps: 15),
      _SeedSet(reps: 15),
      _SeedSet(reps: 15),
    ]),
  ]),
  _SeedTemplate('seed_template_full_body_b', 'Full Body B', [
    _SeedExercise('conventional_deadlift', [
      _SeedSet(weightKg: 100, reps: 5),
      _SeedSet(weightKg: 100, reps: 5),
      _SeedSet(weightKg: 100, reps: 5),
    ]),
    _SeedExercise('incline_dumbbell_press', [
      _SeedSet(weightKg: 22, reps: 10),
      _SeedSet(weightKg: 22, reps: 10),
      _SeedSet(weightKg: 22, reps: 10),
    ]),
    _SeedExercise('seated_cable_row', [
      _SeedSet(weightKg: 60, reps: 10),
      _SeedSet(weightKg: 60, reps: 10),
      _SeedSet(weightKg: 60, reps: 10),
    ]),
    _SeedExercise('dumbbell_lunge', [
      _SeedSet(weightKg: 14, reps: 10),
      _SeedSet(weightKg: 14, reps: 10),
      _SeedSet(weightKg: 14, reps: 10),
    ]),
    _SeedExercise('dumbbell_lateral_raise', [
      _SeedSet(weightKg: 8, reps: 12),
      _SeedSet(weightKg: 8, reps: 12),
      _SeedSet(weightKg: 8, reps: 12),
    ]),
    _SeedExercise('hammer_curl', [
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
      _SeedSet(weightKg: 12, reps: 10),
    ]),
    _SeedExercise('lying_triceps_extension', [
      _SeedSet(weightKg: 25, reps: 10),
      _SeedSet(weightKg: 25, reps: 10),
      _SeedSet(weightKg: 25, reps: 10),
    ]),
    _SeedExercise('plank', [
      _SeedSet(durationSec: 45),
      _SeedSet(durationSec: 45),
      _SeedSet(durationSec: 45),
    ]),
  ]),
];

/// Seeds the 5 built-in starter templates above. Same upsert-without-
/// resurrecting-deleted-rows caution as `insertWorkoutTagSeed`/
/// `insertExerciseSeed`: each row (template / template-exercise / set) has
/// a stable id built from its position, and re-running this on a later
/// seed-version bump only refreshes content fields via `DoUpdate` — never
/// touches `isDeleted`/`isArchived`, so an owner who deleted or archived
/// one of these templates never has it silently come back. These are
/// otherwise ordinary templates: no `isBuiltIn` flag exists on
/// `WorkoutTemplates` (unlike `Exercises`), so they're fully editable/
/// deletable exactly like a template the owner creates by hand — this
/// seed is the only thing that makes them exist in the first place.
Future<void> insertWorkoutTemplateSeed(AppDatabase db) async {
  final now = DateTime.now().toUtc().toIso8601String();
  await db.batch((batch) {
    for (final template in _templates) {
      batch.insert(
        db.workoutTemplates,
        WorkoutTemplatesCompanion.insert(
          id: template.id,
          name: template.name,
          createdAt: now,
          updatedAt: now,
        ),
        onConflict: DoUpdate(
          (_) => WorkoutTemplatesCompanion(
            name: Value(template.name),
            updatedAt: Value(now),
          ),
        ),
      );

      for (var exIndex = 0; exIndex < template.exercises.length; exIndex++) {
        final exercise = template.exercises[exIndex];
        final templateExerciseId = '${template.id}_ex_$exIndex';
        batch.insert(
          db.templateExercises,
          TemplateExercisesCompanion.insert(
            id: templateExerciseId,
            templateId: template.id,
            exerciseId: exercise.exerciseId,
            orderIndex: exIndex,
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => TemplateExercisesCompanion(
              exerciseId: Value(exercise.exerciseId),
              orderIndex: Value(exIndex),
              updatedAt: Value(now),
            ),
          ),
        );

        for (var setIndex = 0; setIndex < exercise.sets.length; setIndex++) {
          final set = exercise.sets[setIndex];
          final setId = '${templateExerciseId}_set_$setIndex';
          batch.insert(
            db.templateSets,
            TemplateSetsCompanion.insert(
              id: setId,
              templateExerciseId: templateExerciseId,
              setNumber: setIndex + 1,
              plannedWeightKg: Value(set.weightKg),
              plannedReps: Value(set.reps),
              plannedDurationSec: Value(set.durationSec),
              createdAt: now,
              updatedAt: now,
            ),
            onConflict: DoUpdate(
              (_) => TemplateSetsCompanion(
                setNumber: Value(setIndex + 1),
                plannedWeightKg: Value(set.weightKg),
                plannedReps: Value(set.reps),
                plannedDurationSec: Value(set.durationSec),
                updatedAt: Value(now),
              ),
            ),
          );
        }
      }
    }
  });
}
