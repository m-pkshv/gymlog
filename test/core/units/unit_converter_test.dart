import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/units/unit_converter.dart';

void main() {
  const converter = UnitConverter();

  group('mass', () {
    test('kg to display metric rounds to 1 decimal', () {
      expect(converter.massToDisplay(82.456, UnitSystem.metric), 82.5);
    });

    test('kg to display imperial converts to lb', () {
      expect(converter.massToDisplay(100, UnitSystem.imperial), 220.5);
    });

    test('imperial input converts to kg for storage, unrounded', () {
      expect(
        converter.massToKg(10, UnitSystem.imperial),
        closeTo(4.5359237, 1e-9),
      );
    });

    test('metric input is stored unchanged', () {
      expect(converter.massToKg(82.456, UnitSystem.metric), 82.456);
    });
  });

  group('distance', () {
    test('meters to display metric converts to km, rounded to 2 decimals', () {
      expect(converter.distanceToDisplay(12344, UnitSystem.metric), 12.34);
      expect(converter.distanceToDisplay(12346, UnitSystem.metric), 12.35);
    });

    test('meters to display imperial converts to miles', () {
      expect(converter.distanceToDisplay(1609.344, UnitSystem.imperial), 1.0);
      expect(converter.distanceToDisplay(3218.688, UnitSystem.imperial), 2.0);
    });

    test('km input converts to meters for storage', () {
      expect(converter.distanceToMeters(5, UnitSystem.metric), 5000);
    });

    test('miles input converts to meters for storage', () {
      expect(converter.distanceToMeters(1, UnitSystem.imperial), 1609.344);
    });
  });

  group('length measurements', () {
    test('cm to display metric rounds to 1 decimal', () {
      expect(converter.lengthToDisplay(40.06, UnitSystem.metric), 40.1);
    });

    test('cm to display imperial converts to inches', () {
      expect(converter.lengthToDisplay(100, UnitSystem.imperial), 39.4);
    });

    test('inch input converts to cm for storage', () {
      expect(converter.lengthToCm(1, UnitSystem.imperial), 2.54);
    });
  });

  group('pace', () {
    test('seconds per km for metric', () {
      expect(converter.paceSecondsPerUnit(300, 1000, UnitSystem.metric), 300);
    });

    test('seconds per mile for imperial', () {
      expect(
        converter.paceSecondsPerUnit(300, 1609.344, UnitSystem.imperial),
        closeTo(300, 1e-9),
      );
    });

    test('returns null for zero distance', () {
      expect(converter.paceSecondsPerUnit(300, 0, UnitSystem.metric), isNull);
    });

    test('formats pace as m:ss', () {
      expect(converter.formatPace(300), '5:00');
      expect(converter.formatPace(272), '4:32');
      expect(converter.formatPace(65), '1:05');
    });
  });

  group('decimal parsing', () {
    test('accepts dot as decimal separator', () {
      expect(converter.parseDecimal('82.5'), 82.5);
    });

    test('accepts comma as decimal separator', () {
      expect(converter.parseDecimal('82,5'), 82.5);
    });

    test('returns null for empty input', () {
      expect(converter.parseDecimal('  '), isNull);
    });

    test('returns null for invalid input', () {
      expect(converter.parseDecimal('abc'), isNull);
    });
  });
}
