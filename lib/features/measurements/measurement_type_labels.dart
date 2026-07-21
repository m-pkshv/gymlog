import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../domain/models/measurement_type.dart';
import '../../l10n/app_localizations.dart';

/// Display label for a `MeasurementType` (06_DATA_MODEL.md, section 5.3):
/// the user-typed name for custom types, or the ARB label
/// (`measurementType<Id>`) for the 15 built-in ones.
String measurementTypeLabel(AppLocalizations l10n, MeasurementType type) {
  if (!type.isBuiltIn) return type.nameCustom ?? type.id;
  switch (type.id) {
    case 'body_weight':
      return l10n.measurementTypeBodyWeight;
    case 'body_fat':
      return l10n.measurementTypeBodyFat;
    case 'neck':
      return l10n.measurementTypeNeck;
    case 'shoulders_girth':
      return l10n.measurementTypeShouldersGirth;
    case 'chest_girth':
      return l10n.measurementTypeChestGirth;
    case 'waist':
      return l10n.measurementTypeWaist;
    case 'hips':
      return l10n.measurementTypeHips;
    case 'biceps_left':
      return l10n.measurementTypeBicepsLeft;
    case 'biceps_right':
      return l10n.measurementTypeBicepsRight;
    case 'forearm_left':
      return l10n.measurementTypeForearmLeft;
    case 'forearm_right':
      return l10n.measurementTypeForearmRight;
    case 'thigh_left':
      return l10n.measurementTypeThighLeft;
    case 'thigh_right':
      return l10n.measurementTypeThighRight;
    case 'calf_left':
      return l10n.measurementTypeCalfLeft;
    case 'calf_right':
      return l10n.measurementTypeCalfRight;
    default:
      return type.id;
  }
}

/// Display label for a `MeasurementUnitKind` (06_DATA_MODEL.md, section 5.3)
/// — used in the "Свои" tab's create-type dialog (S-14).
String measurementUnitKindLabel(
  AppLocalizations l10n,
  MeasurementUnitKind unitKind,
) {
  switch (unitKind) {
    case MeasurementUnitKind.mass:
      return l10n.measurementUnitKindMass;
    case MeasurementUnitKind.percent:
      return l10n.measurementUnitKindPercent;
    case MeasurementUnitKind.length:
      return l10n.measurementUnitKindLength;
  }
}

/// The unit suffix shown next to a value input/display, honoring the D-5
/// unit system for mass/length (percent has no unit system dependence).
String measurementUnitSuffix(
  AppLocalizations l10n,
  MeasurementUnitKind unitKind,
  UnitSystem unitSystem,
) {
  switch (unitKind) {
    case MeasurementUnitKind.mass:
      return unitSystem == UnitSystem.imperial ? l10n.unitLb : l10n.unitKg;
    case MeasurementUnitKind.percent:
      return '%';
    case MeasurementUnitKind.length:
      return unitSystem == UnitSystem.imperial ? l10n.unitIn : l10n.unitCm;
  }
}
