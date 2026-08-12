import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/nice_axis_bounds.dart';

void main() {
  group('niceAxisBounds', () {
    test('rounds a real weight series out to a round-number interval', () {
      // The exact data that triggered the owner report: min/max labels
      // ("79.8"/"84.9") rendered on top of the nearest regular grid label
      // ("80"/"84" or "85").
      final bounds = niceAxisBounds(79.8, 84.9);
      expect(bounds.min % bounds.interval, 0);
      expect(bounds.max % bounds.interval, 0);
      expect(bounds.min, lessThanOrEqualTo(79.8));
      expect(bounds.max, greaterThanOrEqualTo(84.9));
    });

    test('leaves an already-round range untouched', () {
      final bounds = niceAxisBounds(20, 24);
      expect(bounds.min, 20);
      expect(bounds.max, 24);
      expect(bounds.interval, 1);
    });

    test('pads a single-point (flat) series on both sides', () {
      final bounds = niceAxisBounds(50, 50);
      expect(bounds.min, lessThan(50));
      expect(bounds.max, greaterThan(50));
      expect(bounds.interval, greaterThan(0));
    });

    test('a single point at zero does not divide by zero', () {
      final bounds = niceAxisBounds(0, 0);
      expect(bounds.interval, greaterThan(0));
      expect(bounds.min, lessThan(0));
      expect(bounds.max, greaterThan(0));
    });

    test('scales the interval up for a large-magnitude range (tonnage)', () {
      final bounds = niceAxisBounds(1200, 4800);
      expect(bounds.min % bounds.interval, 0);
      expect(bounds.max % bounds.interval, 0);
      expect(bounds.interval, greaterThanOrEqualTo(1000));
    });

    test('scales the interval down for a narrow range (body fat %)', () {
      final bounds = niceAxisBounds(18.2, 19.4);
      expect(bounds.min, lessThanOrEqualTo(18.2));
      expect(bounds.max, greaterThanOrEqualTo(19.4));
      // Modulo on decimal intervals is float-fuzzy -- close to a multiple
      // is what matters, not bit-exact zero.
      expect(bounds.min % bounds.interval, closeTo(0, 1e-9));
      expect(bounds.max % bounds.interval, closeTo(0, 1e-9));
    });
  });
}
