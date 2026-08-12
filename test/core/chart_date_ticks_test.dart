import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/chart_date_ticks.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // `formatDateTick`'s monthly branch calls `DateFormat.MMM`, which throws
  // unless locale data has been initialized -- normally a side effect of
  // `MaterialApp`'s own localization delegates loading (never done
  // explicitly anywhere in this project), which this bare unit test has
  // no widget tree to trigger.
  setUpAll(initializeDateFormatting);


  group('dateAxisTicks', () {
    test('empty list gives no ticks', () {
      final ticks = dateAxisTicks([]);
      expect(ticks.indexes, isEmpty);
    });

    test('a span of a month or less ticks every Monday, not month-start', () {
      // Mon/Wed/Fri across ~4 weeks (28 days) -- a month-or-less span.
      final dates = [
        DateTime(2026, 4, 6), // Mon
        DateTime(2026, 4, 8), // Wed
        DateTime(2026, 4, 10), // Fri
        DateTime(2026, 4, 13), // Mon
        DateTime(2026, 4, 15), // Wed
        DateTime(2026, 4, 17), // Fri
        DateTime(2026, 4, 20), // Mon
      ];
      final ticks = dateAxisTicks(dates);
      expect(ticks.monthly, isFalse);
      expect(ticks.indexes, {0, 3, 6});
    });

    test('a span longer than a month ticks the first point of each month, '
        'not literal day 1', () {
      final dates = [
        DateTime(2026, 4, 13), // first point of April
        DateTime(2026, 4, 27),
        DateTime(2026, 5, 4), // first point of May
        DateTime(2026, 5, 18),
        DateTime(2026, 6, 1), // first point of June
        DateTime(2026, 6, 15),
        DateTime(2026, 8, 10), // first point of August (>31 days total span)
      ];
      final ticks = dateAxisTicks(dates);
      expect(ticks.monthly, isTrue);
      expect(ticks.indexes, {0, 2, 4, 6});
    });

    test('a span of exactly a month (31 days) still uses Monday ticks, not '
        'month-start', () {
      final dates = [
        DateTime(2026, 4, 13),
        DateTime(2026, 5, 14), // 31 days after the first
      ];
      final ticks = dateAxisTicks(dates);
      expect(ticks.monthly, isFalse);
    });

    test('a year crossing a new calendar year ticks both Decembers/Januarys '
        'as separate months', () {
      final dates = [
        DateTime(2025, 11, 3),
        DateTime(2025, 12, 1),
        DateTime(2026, 1, 5),
        DateTime(2026, 2, 2),
      ];
      final ticks = dateAxisTicks(dates);
      expect(ticks.monthly, isTrue);
      expect(ticks.indexes, {0, 1, 2, 3});
    });
  });

  group('formatDateTick', () {
    test('weekly ticks format as day.month, locale-independent', () {
      final label = formatDateTick(
        DateTime(2026, 4, 6),
        monthly: false,
        locale: 'ru',
      );
      expect(label, '06.04');
    });

    test('monthly ticks format as a localized short month name', () {
      final en = formatDateTick(
        DateTime(2026, 4, 6),
        monthly: true,
        locale: 'en',
      );
      expect(en, 'Apr');
    });
  });
}
