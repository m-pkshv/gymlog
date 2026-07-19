/// Domain enums (06_DATA_MODEL.md, section 4). Values match the string
/// literals stored in `TEXT`+`CHECK` columns exactly (see
/// `lib/data/tables/`); mapping happens in `lib/data/mappers/`.
///
/// Only the enums needed by the entities modeled so far (Exercise, Workout
/// aggregate) are defined here. The rest of DM section 4 (RecordType,
/// OperationType/Status, AppTheme, AppLocale, MeasurementSource) is added
/// alongside the features that need them, per stage. `UnitSystem` already
/// lives in `core/units/unit_converter.dart` (D-5) and is reused as-is.
library;

enum ExerciseType { strength, cardio, reps, time, stretch }

enum EffortMetric { none, rpe, rir }

enum WorkoutStatus { draft, planned, inProgress, completed, skipped, cancelled }

enum ProgressionDecision { none, increase, repeat, decrease }

enum BodySide { none, left, right, both }
