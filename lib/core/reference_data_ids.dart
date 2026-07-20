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
const List<String> equipmentIds = [
  'barbell',
  'dumbbell',
  'kettlebell',
  'machine',
  'cable',
  'bodyweight',
  'band',
  'cardio_machine',
  'other',
];
