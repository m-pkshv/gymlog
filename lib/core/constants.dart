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

/// Comment field length limits (06_DATA_MODEL.md, sections 6.4/6.6/6.7),
/// enforced via `maxLength` on the S-03 comment fields.
class CommentLengthLimits {
  const CommentLengthLimits._();

  static const int workout = 2000;
  static const int workoutExercise = 1000;
  static const int exerciseSet = 500;
  static const int workoutTemplate = 2000;
  static const int bodyMeasurement = 500;
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

/// CSV export format (03_TECHNICAL_SPEC.md, section 10.1/10.2, D-9).
class ExportFormat {
  const ExportFormat._();

  static const int formatVersion = 1;

  /// Mirrors `pubspec.yaml`'s semantic version (currently `1.0.0+1`) --
  /// there's no `package_info_plus` dependency (not in TS 3) to read it at
  /// runtime, so this is updated by hand alongside `pubspec.yaml`.
  static const String appVersion = '1.0.0';
}
