import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/stats_period.dart';

void main() {
  final today = DateTime(2026, 7, 21);

  group('StatsPeriod.range (TS 9: inclusive local-date periods)', () {
    test('week is a 7-day inclusive range ending today', () {
      final (from, to) = const StatsPeriod.preset(StatsPeriodPreset.week).range(today);
      expect(from, DateTime(2026, 7, 15));
      expect(to, DateTime(2026, 7, 21));
      expect(to!.difference(from!).inDays, 6); // 7 days inclusive = 6 apart
    });

    test('month is a 30-day inclusive range ending today', () {
      final (from, to) = const StatsPeriod.preset(StatsPeriodPreset.month).range(today);
      expect(to!.difference(from!).inDays, 29);
    });

    test('threeMonths is a 90-day inclusive range ending today', () {
      final (from, to) = const StatsPeriod.preset(
        StatsPeriodPreset.threeMonths,
      ).range(today);
      expect(to!.difference(from!).inDays, 89);
    });

    test('year is a 365-day inclusive range ending today', () {
      final (from, to) = const StatsPeriod.preset(StatsPeriodPreset.year).range(today);
      expect(to!.difference(from!).inDays, 364);
    });

    test('allTime is unbounded on both sides', () {
      final (from, to) = const StatsPeriod.preset(
        StatsPeriodPreset.allTime,
      ).range(today);
      expect(from, isNull);
      expect(to, isNull);
    });

    test('custom returns exactly the given range, ignoring the anchor', () {
      final period = StatsPeriod.custom(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 3, 1),
      );
      final (from, to) = period.range(today);
      expect(from, DateTime(2026, 1, 1));
      expect(to, DateTime(2026, 3, 1));
    });

    test('the anchor drops any time-of-day component', () {
      final (from, to) = const StatsPeriod.preset(
        StatsPeriodPreset.week,
      ).range(DateTime(2026, 7, 21, 23, 59));
      expect(to, DateTime(2026, 7, 21));
      expect(from, DateTime(2026, 7, 15));
    });
  });
}
