/// Domain enums (06_DATA_MODEL.md, section 4). Values match the string
/// literals stored in `TEXT`+`CHECK` columns exactly (see
/// `lib/data/tables/`); mapping happens in `lib/data/mappers/`.
///
/// Only the enums needed by the entities modeled so far (Exercise, Workout
/// aggregate, MeasurementType/BodyMeasurement, PersonalRecord, AppSettings)
/// are defined here. `AppLocale` is added alongside the language switcher
/// (Stage 9, later step). `UnitSystem` already lives in
/// `core/units/unit_converter.dart` (D-5) and is reused as-is.
library;

enum ExerciseType { strength, cardio, reps, time, stretch }

enum EffortMetric { none, rpe, rir }

enum WorkoutStatus { draft, planned, inProgress, completed, skipped, cancelled }

enum ProgressionDecision { none, increase, repeat, decrease }

enum BodySide { none, left, right, both }

/// `MeasurementType.unitKind` (06_DATA_MODEL.md, section 5.3): which
/// `UnitConverter` conversion applies to a measurement's `valueMetric` —
/// mass (kg), percent (no conversion), or length (cm).
enum MeasurementUnitKind { mass, percent, length }

/// `BodyMeasurement.source` (06_DATA_MODEL.md, section 6.9). Only `manual`
/// entry exists so far (S-15); `import`/`health` are reserved for the CSV
/// importer (Stage 8) and a future health-app sync, not produced anywhere
/// yet.
enum MeasurementSource { manual, import, health }

/// `PersonalRecord.recordType` (06_DATA_MODEL.md, section 6.10, D-8) — which
/// personal-best metric a cached row represents. `maxRepsAtWeight` is the
/// only one keyed by `PersonalRecord.keyValue` (the weight); the app can
/// have several `maxRepsAtWeight` rows per exercise, one per weight ever
/// used.
enum RecordType {
  maxWeight,
  maxRepsAtWeight,
  max1RM,
  maxVolumeWorkout,
  maxDistance,
  bestPace,
  longestDuration,
}

/// `ImportExportOperation.operationType` (06_DATA_MODEL.md, section 6.13).
/// Only `export` is ever produced in the MVP (D-9); `import` is reserved for
/// a post-MVP importer (TS 10.6).
enum ImportExportOperationType { export, import }

/// `ImportExportOperation.status` (06_DATA_MODEL.md, section 6.13).
enum ImportExportOperationStatus { inProgress, success, failed }

/// `AppSettings.theme` (06_DATA_MODEL.md, section 6.12; 04_UI_UX_SPEC.md,
/// section 9). `system` follows the OS light/dark setting; `light`/`dark`
/// pin the app to one regardless of the OS. Mapped to Flutter's own
/// `ThemeMode` in `app/theme.dart` rather than reused directly, so this
/// (Flutter-free) domain layer stays testable without `package:flutter`.
enum AppTheme { system, light, dark }
