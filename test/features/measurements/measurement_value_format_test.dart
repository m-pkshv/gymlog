import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/units/unit_converter.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/measurements/measurement_value_format.dart';

void main() {
  group('measurementValueToMetric (D-5)', () {
    test('mass: imperial input converts to kg for storage', () {
      final kg = measurementValueToMetric(
        75.5,
        MeasurementUnitKind.mass,
        UnitSystem.imperial,
      );
      expect(kg, closeTo(75.5 * UnitConverter.kgPerLb, 1e-9));
    });

    test('mass: metric input passes through unchanged', () {
      final kg = measurementValueToMetric(
        75.5,
        MeasurementUnitKind.mass,
        UnitSystem.metric,
      );
      expect(kg, 75.5);
    });

    test('length: imperial input converts to cm for storage', () {
      final cm = measurementValueToMetric(
        10,
        MeasurementUnitKind.length,
        UnitSystem.imperial,
      );
      expect(cm, closeTo(10 * UnitConverter.cmPerInch, 1e-9));
    });

    test('percent: never converted regardless of unit system', () {
      expect(
        measurementValueToMetric(
          22.5,
          MeasurementUnitKind.percent,
          UnitSystem.imperial,
        ),
        22.5,
      );
    });
  });

  group('measurementValueToDisplay (D-5)', () {
    test('mass: a stored kg value round-trips through imperial display', () {
      final storedKg = 75.5 * UnitConverter.kgPerLb;
      final displayedLb = measurementValueToDisplay(
        storedKg,
        MeasurementUnitKind.mass,
        UnitSystem.imperial,
      );
      expect(displayedLb, closeTo(75.5, 0.05));
    });

    test('length: a stored cm value round-trips through imperial display', () {
      final storedCm = 10 * UnitConverter.cmPerInch;
      final displayedIn = measurementValueToDisplay(
        storedCm,
        MeasurementUnitKind.length,
        UnitSystem.imperial,
      );
      expect(displayedIn, closeTo(10, 0.05));
    });
  });
}
