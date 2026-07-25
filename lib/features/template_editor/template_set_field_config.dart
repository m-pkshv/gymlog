import '../../core/constants.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../domain/models/template_set.dart';
import '../../l10n/app_localizations.dart';

const _unitConverter = UnitConverter();

/// One planned-metric column of the template sets table (S-13) — the
/// template counterpart of `workout_editor/set_field_config.dart`'s
/// `SetFieldSpec`, minus the actual/plan split: `TemplateSet` only ever
/// carries planned values (06_DATA_MODEL.md, section 6.8 — "только
/// плановые метрики"). Field bounds/mapping mirror `setFieldsFor`
/// (`ASSUMPTION(set-field-mapping)`, Stage 1) exactly, reused here rather
/// than re-derived.
class TemplateSetFieldSpec {
  const TemplateSetFieldSpec({
    required this.label,
    required this.decimals,
    required this.min,
    required this.max,
    required this.step,
    required this.getPlanned,
    required this.setPlanned,
  });

  final String label;
  final int decimals;
  final double min;
  final double max;

  /// Increment/decrement step for [NumericStepperField] (Stage 10 redesign)
  /// -- mirrors `SetFieldSpec.step` exactly, same values (2.5 kg plate,
  /// whole reps, 0.1 km, 15 s).
  final double step;
  final double? Function(TemplateSet) getPlanned;
  final TemplateSet Function(TemplateSet, double?) setPlanned;
}

/// Combined `"80 × 8"`-style summary of every field [type] uses -- the
/// template counterpart of `set_field_config.dart`'s `formatFieldsSummary`,
/// minus the plan/fact split (a `TemplateSet` only ever has planned values).
String formatTemplateFieldsSummary(
  TemplateSet set,
  List<TemplateSetFieldSpec> fields,
) {
  return fields
      .map((field) {
        final value = field.getPlanned(set);
        if (value == null) return '—';
        return field.decimals == 0
            ? value.round().toString()
            : value.toStringAsFixed(field.decimals);
      })
      .join(' × ');
}

List<TemplateSetFieldSpec> templateSetFieldsFor(
  ExerciseType type,
  AppLocalizations l10n,
) {
  final weight = TemplateSetFieldSpec(
    label: l10n.setFieldWeightKg,
    decimals: 1,
    min: SetFieldRange.minWeightKg,
    max: SetFieldRange.maxWeightKg,
    step: 2.5,
    getPlanned: (s) => s.plannedWeightKg,
    setPlanned: (s, v) => s.copyWith(plannedWeightKg: v),
  );
  final reps = TemplateSetFieldSpec(
    label: l10n.setFieldReps,
    decimals: 0,
    min: SetFieldRange.minReps.toDouble(),
    max: SetFieldRange.maxReps.toDouble(),
    step: 1,
    getPlanned: (s) => s.plannedReps?.toDouble(),
    setPlanned: (s, v) => s.copyWith(plannedReps: v?.round()),
  );
  final distanceKm = TemplateSetFieldSpec(
    label: l10n.setFieldDistanceKm,
    decimals: 2,
    min: SetFieldRange.minDistanceM / 1000,
    max: SetFieldRange.maxDistanceM / 1000,
    step: 0.1,
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
  );
  final durationSec = TemplateSetFieldSpec(
    label: l10n.setFieldDurationSec,
    decimals: 0,
    min: SetFieldRange.minDurationSec.toDouble(),
    max: SetFieldRange.maxDurationSec.toDouble(),
    step: 15,
    getPlanned: (s) => s.plannedDurationSec?.toDouble(),
    setPlanned: (s, v) => s.copyWith(plannedDurationSec: v?.round()),
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

/// "Дублировать подход" (S-13, Stage 10) — the template counterpart of
/// `workout_editor/set_field_config.dart`'s `copyPlannedToPlanned`: [from]'s
/// planned values (and `side`) copied into [into].
TemplateSet copyTemplatePlannedToPlanned(
  TemplateSet from,
  TemplateSet into,
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

/// The template counterpart of `set_field_config.dart`'s `hasPlannedValues`.
bool hasTemplatePlannedValues(TemplateSet set, ExerciseType type) {
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
