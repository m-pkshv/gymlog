/// Canonical id lists for the built-in reference tables
/// (06_DATA_MODEL.md, sections 5.1–5.2) — the single source of truth both
/// `data/seed/reference_data_seed.dart` (what gets written to the DB) and
/// the exercise form's muscle/equipment pickers (what the user sees) build
/// on, so the two can never drift apart. Localized labels live in ARB.
library;

/// Order matches DM 5.1 and becomes `MuscleGroup.sortOrder` at seed time.
/// `rear_delts`/`obliques`/`hip_flexors`/`adductors` were added on top of
/// the original 13 once the owner's full exercise list (Q-1, 2026-07-20)
/// showed they're needed — several exercises use them as the *primary*
/// muscle (e.g. Machine Hip Adduction -> adductors), so they couldn't be
/// folded into a broader existing group without losing that exercise's
/// primary-muscle assignment.
///
/// `legs` (redesign_v2, 2026-08-04, owner-requested) is a purely additive
/// 18th entry, not a consolidation of the existing leg-specific groups
/// below it (owner confirmed: none of the 359 seeded exercises' primary/
/// secondary muscle changes) — unlike the *workout tag* of the same name
/// (`legsWorkoutTagId`, core/constants.dart), which did replace six
/// muscle-group tags. Different table, same id string is a coincidence,
/// not a reused concept: `MuscleGroup.id` and `WorkoutTag.id` don't share
/// a namespace or foreign key.
const List<String> muscleGroupIds = [
  'chest',
  'back',
  'shoulders',
  'rear_delts',
  'biceps',
  'triceps',
  'forearms',
  'abs',
  'obliques',
  'legs',
  'hip_flexors',
  'glutes',
  'quads',
  'adductors',
  'hamstrings',
  'calves',
  'full_body',
  'cardio_system',
];

/// Order matches DM 5.2 and becomes `Equipment.sortOrder` at seed time.
/// `pull_up_bar`/`dip_bars` (redesign_v2, 2026-08-05, owner-requested) were
/// split out of `other` once icon-by-equipment planning showed `other` was
/// a ~49-exercise grab bag of visually unrelated things -- pull-up-bar and
/// dip-bar exercises were the two large enough (11 and 2, respectively) and
/// visually distinct enough sub-groups to earn their own bucket; the rest
/// of `other` (battle ropes, sled, ab wheel, box jumps, Swiss ball, etc.)
/// stayed merged, each too small on its own.
const List<String> equipmentIds = [
  'barbell',
  'dumbbell',
  'kettlebell',
  'machine',
  'cable',
  'bodyweight',
  'pull_up_bar',
  'dip_bars',
  'band',
  'cardio_machine',
  'other',
];
