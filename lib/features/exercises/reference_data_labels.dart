import 'package:flutter/material.dart';

import '../../core/color_hex.dart';
import '../../core/constants.dart';
import '../../core/reference_data_ids.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// Deterministic color for a muscle group id (Stage 10 redesign,
/// AUDIT.md section 1.3: "the catalog's icon carries no information --
/// the same icon for nearly every strength exercise"). Reuses the exact
/// muscle-group -> palette-index mapping `data/seed/workout_tag_seed.dart`
/// already uses for the built-in per-muscle-group tags, so a given muscle
/// group reads as the same color everywhere in the app (tag chips, the
/// tag filter, and now the catalog list), not a second independent color
/// scheme. Unknown/missing ids fall back to the palette's first color
/// rather than throwing -- the only caller passes either a real
/// `muscleGroupIds` entry or short-circuits before calling this at all
/// (see `_ExerciseListTile`'s null-group fallback in `screen.dart`).
Color muscleGroupColor(String muscleGroupId) {
  final index = muscleGroupIds.indexOf(muscleGroupId);
  final hex =
      workoutTagColorPalette[(index < 0 ? 0 : index) % workoutTagColorPalette.length];
  return colorFromHex(hex);
}

/// Display label for a `MuscleGroup.id` (06_DATA_MODEL.md, section 5.1).
String muscleGroupLabel(AppLocalizations l10n, String id) {
  switch (id) {
    case 'chest':
      return l10n.muscleGroupChest;
    case 'back':
      return l10n.muscleGroupBack;
    case 'shoulders':
      return l10n.muscleGroupShoulders;
    case 'rear_delts':
      return l10n.muscleGroupRearDelts;
    case 'biceps':
      return l10n.muscleGroupBiceps;
    case 'triceps':
      return l10n.muscleGroupTriceps;
    case 'forearms':
      return l10n.muscleGroupForearms;
    case 'abs':
      return l10n.muscleGroupAbs;
    case 'obliques':
      return l10n.muscleGroupObliques;
    case 'legs':
      return l10n.muscleGroupLegs;
    case 'hip_flexors':
      return l10n.muscleGroupHipFlexors;
    case 'glutes':
      return l10n.muscleGroupGlutes;
    case 'quads':
      return l10n.muscleGroupQuads;
    case 'adductors':
      return l10n.muscleGroupAdductors;
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
