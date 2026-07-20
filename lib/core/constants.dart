/// App-wide magic-number constants (05_AI_INSTRUCTIONS.md, section 7:
/// no unexplained literals in feature code).
library;

/// Valid ranges for `ExerciseSet` numeric fields (06_DATA_MODEL.md, section
/// 6.7). The workout editor (S-03) clamps input against these before
/// writing.
class SetFieldRange {
  const SetFieldRange._();

  static const double minWeightKg = 0;
  static const double maxWeightKg = 1000;
  static const int minReps = 0;
  static const int maxReps = 1000;
  static const int minDurationSec = 0;
  static const int maxDurationSec = 86400;
  static const double minDistanceM = 0;
  static const double maxDistanceM = 1000000;
}

/// Autosave debounce for text fields (03_TECHNICAL_SPEC.md, section 5): a
/// killed process loses at most this much of the last unflushed field.
const Duration autosaveDebounce = Duration(milliseconds: 500);

/// `WorkoutTag.name` bounds (06_DATA_MODEL.md, section 6.3), validated in
/// `WorkoutTagService.create`.
class WorkoutTagRules {
  const WorkoutTagRules._();

  static const int minNameLength = 1;
  static const int maxNameLength = 30;
}

/// The 8-color tag palette (04_UI_UX_SPEC.md, section 9, UX-1). The first
/// entry is also `WorkoutTagsTable`'s default `colorHex`.
const List<String> workoutTagColorPalette = [
  '#4C7BD9',
  '#2E9E6B',
  '#D9774C',
  '#B34CD9',
  '#D9B84C',
  '#4CC3D9',
  '#D94C6B',
  '#7B8794',
];
