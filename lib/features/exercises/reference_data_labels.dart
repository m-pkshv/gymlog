import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// Display label for a `MuscleGroup.id` (06_DATA_MODEL.md, section 5.1).
String muscleGroupLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'chest':
      return l10n.muscleGroupChest;
    case 'back':
      return l10n.muscleGroupBack;
    case 'shoulders':
      return l10n.muscleGroupShoulders;
    case 'biceps':
      return l10n.muscleGroupBiceps;
    case 'triceps':
      return l10n.muscleGroupTriceps;
    case 'forearms':
      return l10n.muscleGroupForearms;
    case 'abs':
      return l10n.muscleGroupAbs;
    case 'glutes':
      return l10n.muscleGroupGlutes;
    case 'quads':
      return l10n.muscleGroupQuads;
    case 'hamstrings':
      return l10n.muscleGroupHamstrings;
    case 'calves':
      return l10n.muscleGroupCalves;
    case 'full_body':
      return l10n.muscleGroupFullBody;
    case 'cardio_system':
      return l10n.muscleGroupCardioSystem;
    default:
      return id;
  }
}

/// Display label for an `Equipment.id` (06_DATA_MODEL.md, section 5.2).
String equipmentLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'barbell':
      return l10n.equipmentBarbell;
    case 'dumbbell':
      return l10n.equipmentDumbbell;
    case 'kettlebell':
      return l10n.equipmentKettlebell;
    case 'machine':
      return l10n.equipmentMachine;
    case 'cable':
      return l10n.equipmentCable;
    case 'bodyweight':
      return l10n.equipmentBodyweight;
    case 'band':
      return l10n.equipmentBand;
    case 'cardio_machine':
      return l10n.equipmentCardioMachine;
    case 'other':
      return l10n.equipmentOther;
    default:
      return id;
  }
}

/// Display label for an `EffortMetric` (S-08: shown only for `strength`
/// exercises, 06_DATA_MODEL.md, section 6.1).
String effortMetricLabel(AppLocalizations l10n, EffortMetric metric) {
  switch (metric) {
    case EffortMetric.none:
      return l10n.effortMetricNone;
    case EffortMetric.rpe:
      return l10n.effortMetricRpe;
    case EffortMetric.rir:
      return l10n.effortMetricRir;
  }
}
