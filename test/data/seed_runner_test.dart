import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/seed/exercise_seed.dart';
import 'package:gymlog/data/seed/reference_data_seed.dart';
import 'package:gymlog/data/seed/seed_runner.dart';
import 'package:gymlog/data/seed/workout_tag_seed.dart';
import 'package:gymlog/data/seed/workout_template_seed.dart';

/// The Stage 12 (2026-08-02) curated built-in tag set -- mirrors
/// `workout_tag_seed.dart`'s `_seedTagIds` (private to that library, so
/// spelled out here rather than imported).
const Set<String> _expectedBuiltInTagIds = {
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
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'first run inserts reference data and the placeholder exercises',
    () async {
      await SeedRunner(db).run();

      final muscleGroups = await db.select(db.muscleGroups).get();
      final equipments = await db.select(db.equipments).get();
      final measurementTypes = await db.select(db.measurementTypes).get();
      final exercises = await db.select(db.exercises).get();
      final secondaryMuscles = await db
          .select(db.exerciseSecondaryMuscles)
          .get();
      final l10n = await db.select(db.exerciseL10n).get();
      final workoutTags = await db.select(db.workoutTags).get();
      final workoutTemplates = await db.select(db.workoutTemplates).get();
      final templateExercises = await db.select(db.templateExercises).get();
      final templateSets = await db.select(db.templateSets).get();
      final seedInfo = await db.select(db.seedInfoTable).getSingle();

      // 18 groups: the original 13 (DM 5.1) plus rear_delts/obliques/
      // hip_flexors/adductors, added once the owner's full list (Q-1)
      // showed they're needed as primary-muscle assignments, plus "legs"
      // (redesign_v2, 2026-08-04, purely additive -- no existing
      // exercise's muscle assignment changes).
      expect(muscleGroups, hasLength(18));
      expect(equipments, hasLength(9));
      expect(measurementTypes, hasLength(15));
      // Stage 10, owner-reported, trimmed/generalized Stage 12
      // (2026-08-02): a curated 13-tag set, not a 1:1 mirror of every
      // muscle group -- Rear Delts/Obliques/Hip Flexors/Quads/Adductors/
      // Hamstrings were dropped in favor of the single "Legs" tag, and
      // "Crossfit" was added.
      expect(workoutTags, hasLength(13));
      expect(workoutTags.map((t) => t.id).toSet(), _expectedBuiltInTagIds);
      expect(workoutTags.every((t) => !t.isDeleted), isTrue);

      // Q-1: the owner's full base list (199 exercises, 2026-07-20) plus a
      // 2026-08-01 update adding 160 more grip/stance/equipment variants
      // and functional/cardio movements — 359 total.
      expect(exercises, hasLength(359));
      expect(
        exercises.map((exercise) => exercise.exerciseType).toSet(),
        {'strength', 'cardio', 'reps', 'time'},
      );
      expect(exercises.every((exercise) => exercise.isBuiltIn), isTrue);
      expect(exercises.map((exercise) => exercise.id), contains('barbell_back_squat'));
      expect(secondaryMuscles, isNotEmpty);
      expect(l10n, hasLength(718)); // 359 exercises x 2 locales (ru, en)
      expect(l10n.map((row) => row.locale).toSet(), {'ru', 'en'});

      // Stage 10 redesign, owner-reported: 5 starter workout templates.
      expect(workoutTemplates, hasLength(5));
      expect(workoutTemplates.every((t) => !t.isDeleted), isTrue);
      expect(workoutTemplates.every((t) => !t.isArchived), isTrue);
      expect(templateExercises, isNotEmpty);
      // Every seeded template-exercise references a real, existing
      // exercise id from the catalog seeded just above.
      final exerciseIds = exercises.map((e) => e.id).toSet();
      expect(
        templateExercises.every((te) => exerciseIds.contains(te.exerciseId)),
        isTrue,
      );
      expect(templateSets, isNotEmpty);

      expect(seedInfo.seedVersion, currentSeedVersion);
    },
  );

  test('running the seed twice does not duplicate rows', () async {
    await SeedRunner(db).run();
    await SeedRunner(db).run();

    final muscleGroups = await db.select(db.muscleGroups).get();
    final exercises = await db.select(db.exercises).get();
    final l10n = await db.select(db.exerciseL10n).get();
    final workoutTags = await db.select(db.workoutTags).get();
    final workoutTemplates = await db.select(db.workoutTemplates).get();
    final templateExercises = await db.select(db.templateExercises).get();
    final templateSets = await db.select(db.templateSets).get();

    expect(muscleGroups, hasLength(18));
    expect(exercises, hasLength(359));
    expect(l10n, hasLength(718));
    expect(workoutTags, hasLength(13));
    expect(workoutTemplates, hasLength(5));
    final templateExerciseCountAfterTwoRuns = templateExercises.length;
    final templateSetCountAfterTwoRuns = templateSets.length;

    // A third run should still leave the child-row counts unchanged (not
    // just the top-level template count).
    await SeedRunner(db).run();
    expect(
      await db.select(db.templateExercises).get(),
      hasLength(templateExerciseCountAfterTwoRuns),
    );
    expect(
      await db.select(db.templateSets).get(),
      hasLength(templateSetCountAfterTwoRuns),
    );
  });

  test(
    'insertWorkoutTemplateSeed can re-run against an already-seeded DB '
    'without erroring, preserving a template the owner already deleted',
    () async {
      // TemplateExercises.exerciseId references Exercises, so the catalog
      // must exist first.
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);
      await insertWorkoutTemplateSeed(db);

      // Simulate the owner having deleted one of the built-in templates.
      await (db.update(
        db.workoutTemplates,
      )..where((t) => t.id.equals('seed_template_chest_biceps'))).write(
        const WorkoutTemplatesCompanion(isDeleted: Value(true)),
      );

      // Re-running the seed (e.g. a future content update bumping the
      // version on an install that already has this template) must not
      // un-delete it, must not error on the primary-key conflict, and must
      // not duplicate the template-exercise/set child rows.
      await insertWorkoutTemplateSeed(db);

      final deleted = await (db.select(
        db.workoutTemplates,
      )..where((t) => t.id.equals('seed_template_chest_biceps'))).getSingle();
      expect(deleted.isDeleted, isTrue);

      final templates = await db.select(db.workoutTemplates).get();
      final templateExercises = await db.select(db.templateExercises).get();
      expect(templates, hasLength(5));
      expect(
        templateExercises
            .where((te) => te.templateId == 'seed_template_chest_biceps')
            .length,
        7, // not duplicated by the re-run
      );
    },
  );

  test(
    'insertWorkoutTagSeed can re-run against an already-seeded DB without '
    'erroring, preserving a tag the owner already deleted',
    () async {
      await insertWorkoutTagSeed(db);

      // Simulate the owner having deleted one of the built-in tags.
      await (db.update(
        db.workoutTags,
      )..where((t) => t.id.equals('chest'))).write(
        const WorkoutTagsCompanion(isDeleted: Value(true)),
      );

      // Re-running the seed (e.g. a future content update bumping the
      // version on an install that already has this tag) must not
      // un-delete it, and must not error on the primary-key conflict.
      await insertWorkoutTagSeed(db);

      final chest = await (db.select(
        db.workoutTags,
      )..where((t) => t.id.equals('chest'))).getSingle();
      expect(chest.isDeleted, isTrue);

      final tags = await db.select(db.workoutTags).get();
      expect(tags, hasLength(13));
    },
  );

  test(
    'insertWorkoutTagSeed soft-deletes the six retired muscle-group tags '
    'and drops their existing assignments (Stage 12, 2026-08-02)',
    () async {
      // Simulate an already-seeded install from before Stage 12: the old
      // 18-tag set, one of them ("hip_flexors") assigned to a workout.
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);
      const oldTagIds = [
        'chest',
        'back',
        'shoulders',
        'rear_delts',
        'biceps',
        'triceps',
        'forearms',
        'abs',
        'obliques',
        'hip_flexors',
        'glutes',
        'quads',
        'adductors',
        'hamstrings',
        'calves',
        'full_body',
        'cardio_system',
      ];
      final now = DateTime.now().toUtc().toIso8601String();
      await db.batch((batch) {
        for (final id in oldTagIds) {
          batch.insert(
            db.workoutTags,
            WorkoutTagsCompanion.insert(
              id: id,
              name: id,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      });
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'workout-1',
              date: '2026-08-02',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.workoutTagLinks)
          .insert(
            const WorkoutTagLinksCompanion(
              workoutId: Value('workout-1'),
              tagId: Value('hip_flexors'),
            ),
          );

      // Re-running the seed (the Stage 12 content update) must retire the
      // six dropped tags and silently untag the workout that had one of
      // them assigned (owner-confirmed 2026-08-02) -- not error, and not
      // touch any of the 11 tags this update keeps.
      await insertWorkoutTagSeed(db);

      final retired = await (db.select(db.workoutTags)..where(
        (t) => t.id.isIn([
          'rear_delts',
          'obliques',
          'hip_flexors',
          'quads',
          'adductors',
          'hamstrings',
        ]),
      )).get();
      expect(retired, hasLength(6));
      expect(retired.every((t) => t.isDeleted), isTrue);

      final links = await (db.select(
        db.workoutTagLinks,
      )..where((l) => l.workoutId.equals('workout-1'))).get();
      expect(links, isEmpty);

      final kept = await (db.select(
        db.workoutTags,
      )..where((t) => t.id.equals('chest'))).getSingle();
      expect(kept.isDeleted, isFalse);
    },
  );

  test(
    'insertExerciseSeed can re-run against an already-seeded DB without '
    'erroring, preserving isArchived and not duplicating child rows',
    () async {
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);

      // Simulate the owner having archived one of the built-in exercises.
      await (db.update(
        db.exercises,
      )..where((e) => e.id.equals('barbell_back_squat'))).write(
        const ExercisesCompanion(isArchived: Value(true)),
      );

      // Re-running the seed (e.g. a content update bumping the version on
      // an install that already has this exercise) must not un-archive it,
      // must not error on the primary-key conflict, and must not duplicate
      // the secondary-muscle/localized-name child rows.
      await insertReferenceDataSeed(db);
      await insertExerciseSeed(db);

      final squat = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('barbell_back_squat'))).getSingle();
      expect(squat.isArchived, isTrue);

      final exercises = await db.select(db.exercises).get();
      final secondaryMuscles = await db
          .select(db.exerciseSecondaryMuscles)
          .get();
      final l10n = await db.select(db.exerciseL10n).get();
      expect(exercises, hasLength(359));
      expect(l10n, hasLength(718));
      expect(
        secondaryMuscles
            .where((row) => row.exerciseId == 'barbell_back_squat')
            .length,
        4, // glutes, hamstrings, abs, back — not duplicated by the re-run
      );
    },
  );
}
