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

/// "Копировать показатели прошлого выполнения" (S-03, TS 8 section 8):
/// [from]'s *actual* values become [into]'s *planned* values, for whichever
/// fields [type] uses (same mapping as [setFieldsFor], kept in sync with it
/// deliberately — this is the locale-independent half of that mapping, used
/// by the controller which has no `AppLocalizations` to build the full
/// field list with).
ExerciseSet copyActualsToPlanned(
  ExerciseSet from,
  ExerciseSet into,
  ExerciseType type,
) {
  switch (type) {
    case ExerciseType.strength:
      return into.copyWith(
        plannedWeightKg: from.actualWeightKg,
        plannedReps: from.actualReps,
      );
    case ExerciseType.reps:
      return into.copyWith(plannedReps: from.actualReps);
    case ExerciseType.cardio:
      return into.copyWith(
        plannedDistanceM: from.actualDistanceM,
        plannedDurationSec: from.actualDurationSec,
      );
    case ExerciseType.time:
    case ExerciseType.stretch:
      return into.copyWith(plannedDurationSec: from.actualDurationSec);
  }
}

/// "Дублировать подход" (S-03, Stage 10, owner-reported: filling every set
/// from scratch is tedious): [from]'s *planned* values (and `side`) copied
/// into [into]'s *planned* values, for whichever fields [type] uses (same
/// mapping as [setFieldsFor]).
ExerciseSet copyPlannedToPlanned(
  ExerciseSet from,
  ExerciseSet into,
  ExerciseType type,
) {
  final withSide = into.copyWith(side: from.side);
  switch (type) {
    case ExerciseType.strength:
      return withSide.copyWith(
        plannedWeightKg: from.plannedWeightKg,
        plannedReps: from.plannedReps,
      );
    case ExerciseType.reps:
      return withSide.copyWith(plannedReps: from.plannedReps);
    case ExerciseType.cardio:
      return withSide.copyWith(
        plannedDistanceM: from.plannedDistanceM,
        plannedDurationSec: from.plannedDurationSec,
      );
    case ExerciseType.time:
    case ExerciseType.stretch:
      return withSide.copyWith(plannedDurationSec: from.plannedDurationSec);
  }
}

/// Whether [set] has at least one of [type]'s planned fields filled in —
/// "Дублировать подход" is only offered when there's something worth
/// copying (Stage 10, owner-confirmed: duplicating a still-blank set would
/// just add another blank one).
bool hasPlannedValues(ExerciseSet set, ExerciseType type) {
  switch (type) {
    case ExerciseType.strength:
      return set.plannedWeightKg != null || set.plannedReps != null;
    case ExerciseType.reps:
      return set.plannedReps != null;
    case ExerciseType.cardio:
      return set.plannedDistanceM != null || set.plannedDurationSec != null;
    case ExerciseType.time:
    case ExerciseType.stretch:
      return set.plannedDurationSec != null;
  }
}
