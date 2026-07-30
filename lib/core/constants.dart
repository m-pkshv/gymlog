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

/// Comment field length limits (06_DATA_MODEL.md, sections 6.4/6.6/6.8),
/// enforced via `maxLength` on the S-03/S-13 comment fields.
class CommentLengthLimits {
  const CommentLengthLimits._();

  static const int workout = 2000;
  static const int workoutExercise = 1000;
  static const int workoutTemplate = 2000;
}

/// Soft-delete Undo window (06_DATA_MODEL.md, section 10, D-19): how long
/// the "Отменить" snackbar action stays available after a delete.
const Duration undoSnackbarDuration = Duration(seconds: 5);

/// `WorkoutTemplate.name` bounds (06_DATA_MODEL.md, section 6.8), validated
/// in `WorkoutTemplateService.create`.
class WorkoutTemplateRules {
  const WorkoutTemplateRules._();

  static const int minNameLength = 1;
  static const int maxNameLength = 80;
}

/// `Workout.name` bounds (06_DATA_MODEL.md, section 6.4) -- unlike
/// [WorkoutTemplateRules], no minimum: an empty name is valid and falls
/// back to "Тренировка + date" (DM 6.4), so there's nothing to validate
/// beyond the length cap, enforced via `maxLength` on the rename dialog
/// (Stage 10, owner-reported).
class WorkoutNameRules {
  const WorkoutNameRules._();

  static const int maxNameLength = 80;
}

/// `MeasurementType.nameCustom` bounds (06_DATA_MODEL.md, section 5.3),
/// validated in `MeasurementTypeService.create`.
class MeasurementTypeRules {
  const MeasurementTypeRules._();

  static const int minNameLength = 1;
  static const int maxNameLength = 60;
}

/// `BodyMeasurement.valueMetric` ranges by `MeasurementType.unitKind`
/// (06_DATA_MODEL.md, section 6.9), validated in `BodyMeasurementService`.
class MeasurementValueRange {
  const MeasurementValueRange._();

  static const double minMassKg = 20;
  static const double maxMassKg = 400;
  static const double minPercent = 1;
  static const double maxPercent = 75;
  static const double minLengthCm = 1;
  static const double maxLengthCm = 300;
}

/// `AppSettings.defaultRestTimerSec` bounds (06_DATA_MODEL.md, section
/// 6.12, Q-4), validated in `AppSettingsService.setDefaultRestTimerSec`.
class RestTimerRules {
  const RestTimerRules._();

  static const int minSeconds = 10;
  static const int maxSeconds = 600;
}

/// `UserProfile` name field bounds (06_DATA_MODEL.md, section 6.15),
/// validated in `UserProfileService.updateProfile`. All three fields are
/// optional -- there's no minimum, only a length cap.
class UserProfileRules {
  const UserProfileRules._();

  static const int maxNameLength = 60;
}

/// Full-database backup format (Stage 11) -- a ZIP containing
/// `manifest.json` + a raw copy of `gymlog.sqlite`. A separate
/// format/version space from [ExportFormat] (the human-readable CSV
/// export, TS 10): the two can evolve independently.
class BackupFormat {
  const BackupFormat._();

  static const int formatVersion = 1;
}

/// CSV export format (03_TECHNICAL_SPEC.md, section 10.1/10.2, D-9).
class ExportFormat {
  const ExportFormat._();

  /// v2 (Stage 10, 2026-07-23, owner-confirmed): `workouts.csv` dropped the
  /// `is_warmup` column -- the warm-up concept was removed from the app.
  /// v3 (Stage 10, 2026-07-23, owner-confirmed): `measurements.csv` dropped
  /// the `comment` column -- per-entry measurement comments were removed.
  /// v4 (Stage 10, 2026-07-24, owner-confirmed): `workouts.csv` dropped the
  /// `set_comment` column -- per-set comments were removed in favor of a
  /// "delete set" action.
  /// v5 (Stage 10 redesign, 2026-07-26, owner-confirmed): `workouts.csv`
  /// dropped the `exercise_comment` column -- per-exercise comments were
  /// removed entirely.
  /// v6 (Stage 11, 2026-07-28, owner-confirmed): `workouts.csv` gets the
  /// `exercise_comment` column back -- per-exercise comments are back
  /// (same position as before, right after `exercise_order`).
  static const int formatVersion = 6;

  /// Mirrors `pubspec.yaml`'s semantic version (currently `1.0.0+1`) --
  /// there's no `package_info_plus` dependency (not in TS 3) to read it at
  /// runtime, so this is updated by hand alongside `pubspec.yaml`.
  static const String appVersion = '1.0.0';
}
