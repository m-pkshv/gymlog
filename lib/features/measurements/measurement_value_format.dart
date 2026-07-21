import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';

const _unitConverter = UnitConverter();

/// Stored `valueMetric` (kg/percent/cm) to the unit shown to the user (D-5).
/// Percent has no unit-system dependence.
double measurementValueToDisplay(
  double valueMetric,
  MeasurementUnitKind unitKind,
  UnitSystem unitSystem,
) {
  switch (unitKind) {
    case MeasurementUnitKind.mass:
      return _unitConverter.massToDisplay(valueMetric, unitSystem);
    case MeasurementUnitKind.percent:
      return valueMetric;
    case MeasurementUnitKind.length:
      return _unitConverter.lengthToDisplay(valueMetric, unitSystem);
  }
}

/// A value typed in the display unit (D-5) to the metric value stored in
/// `BodyMeasurement.valueMetric`. Not rounded — range validation
/// (`BodyMeasurementService`) runs against the raw metric value.
double measurementValueToMetric(
  double displayValue,
  MeasurementUnitKind unitKind,
  UnitSystem unitSystem,
) {
  switch (unitKind) {
    case MeasurementUnitKind.mass:
      return _unitConverter.massToKg(displayValue, unitSystem);
    case MeasurementUnitKind.percent:
      return displayValue;
    case MeasurementUnitKind.length:
      return _unitConverter.lengthToCm(displayValue, unitSystem);
  }
}
