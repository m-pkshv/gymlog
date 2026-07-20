import '../../core/constants.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise_set.dart';
import '../../l10n/app_localizations.dart';

const _unitConverter = UnitConverter();

/// One plan/fact metric column of the sets table, mapped to the pair of
/// `ExerciseSet` fields it reads/writes (06_DATA_MODEL.md, section 6.7 —
/// "приложение показывает/валидирует только колонки, соответствующие
/// exerciseType"). Values here are in the *display* unit (e.g. km for
/// distance); [toStorage]/[fromStorage] convert to/from the metric storage
/// value.
///
/// ASSUMPTION(set-field-mapping): DM 6.7 doesn't tabulate which columns
/// apply to which `ExerciseType` explicitly; the mapping below is inferred
/// from the field descriptions and TS 9's formulas (weight+reps for
/// strength, reps [+ optional weight] for reps, distance+duration for
/// cardio, duration for time/stretch). Optional secondary fields (rpe/rir,
/// resistance, incline, heart rate, stretch side) are deferred — Stage 1 is
/// explicitly "minimum" (02_DEVELOPMENT_PLAN.md).
///
/// ASSUMPTION(fixed-metric-unit): input/display use `UnitSystem.metric`
/// unconditionally — `AppSettings`/the unit toggle (D-5) aren't wired up
/// until Stage 9, so there is no user preference to read yet.
class SetFieldSpec {
  const SetFieldSpec({
    required this.label,
    required this.decimals,
    required this.min,
    required this.max,
    required this.getPlanned,
    required this.setPlanned,
    required this.getActual,
    required this.setActual,
  });

  final String label;

  /// Decimal places shown/accepted for this field (0 = integer).
  final int decimals;
  final double min;
  final double max;
  final double? Function(ExerciseSet) getPlanned;
  final ExerciseSet Function(ExerciseSet, double?) setPlanned;
  final double? Function(ExerciseSet) getActual;
  final ExerciseSet Function(ExerciseSet, double?) setActual;
}

List<SetFieldSpec> setFieldsFor(ExerciseType type, AppLocalizations l10n) {
  final weight = SetFieldSpec(
    label: l10n.setFieldWeightKg,
    decimals: 1,
    min: SetFieldRange.minWeightKg,
    max: SetFieldRange.maxWeightKg,
    getPlanned: (s) => s.plannedWeightKg,
    setPlanned: (s, v) => s.copyWith(plannedWeightKg: v),
    getActual: (s) => s.actualWeightKg,
    setActual: (s, v) => s.copyWith(actualWeightKg: v),
  );
  final reps = SetFieldSpec(
    label: l10n.setFieldReps,
    decimals: 0,
    min: SetFieldRange.minReps.toDouble(),
    max: SetFieldRange.maxReps.toDouble(),
    getPlanned: (s) => s.plannedReps?.toDouble(),
    setPlanned: (s, v) => s.copyWith(plannedReps: v?.round()),
    getActual: (s) => s.actualReps?.toDouble(),
    setActual: (s, v) => s.copyWith(actualReps: v?.round()),
  );
  final distanceKm = SetFieldSpec(
    label: l10n.setFieldDistanceKm,
    decimals: 2,
    min: SetFieldRange.minDistanceM / 1000,
    max: SetFieldRange.maxDistanceM / 1000,
    getPlanned: (s) => s.plannedDistanceM == null
        ? null
        : _unitConverter.distanceToDisplay(
            s.plannedDistanceM!,
            UnitSystem.metric,
          ),
    setPlanned: (s, v) => s.copyWith(
      plannedDistanceM: v == null
          ? null
          : _unitConverter.distanceToMeters(v, UnitSystem.metric),
    ),
    getActual: (s) => s.actualDistanceM == null
        ? null
        : _unitConverter.distanceToDisplay(
            s.actualDistanceM!,
            UnitSystem.metric,
          ),
    setActual: (s, v) => s.copyWith(
      actualDistanceM: v == null
          ? null
          : _unitConverter.distanceToMeters(v, UnitSystem.metric),
    ),
  );
  final durationSec = SetFieldSpec(
    label: l10n.setFieldDurationSec,
    decimals: 0,
    min: SetFieldRange.minDurationSec.toDouble(),
    max: SetFieldRange.maxDurationSec.toDouble(),
    getPlanned: (s) => s.plannedDurationSec?.toDouble(),
    setPlanned: (s, v) => s.copyWith(plannedDurationSec: v?.round()),
    getActual: (s) => s.actualDurationSec?.toDouble(),
    setActual: (s, v) => s.copyWith(actualDurationSec: v?.round()),
  );

  switch (type) {
    case ExerciseType.strength:
      return [weight, reps];
    case ExerciseType.reps:
      return [reps];
    case ExerciseType.cardio:
      return [distanceKm, durationSec];
    case ExerciseType.time:
    case ExerciseType.stretch:
      return [durationSec];
  }
}
