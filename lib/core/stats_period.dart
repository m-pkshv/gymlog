/// The 6 statistics periods (03_TECHNICAL_SPEC.md, section 9: "Периоды
/// графиков: 7 дн, 30 дн, 90 дн, 365 дн, всё время, пользовательский
/// диапазон"). Labels on S-09 are Нед/Мес/3М/Год/Всё/Свой.
enum StatsPeriodPreset { week, month, threeMonths, year, allTime, custom }

const Map<StatsPeriodPreset, int> _presetDays = {
  StatsPeriodPreset.week: 7,
  StatsPeriodPreset.month: 30,
  StatsPeriodPreset.threeMonths: 90,
  StatsPeriodPreset.year: 365,
};

/// A selected statistics period (S-09's per-chart period switcher). Pure
/// and independent of any single chart — the same value drives the query
/// range for weight/body-fat/measurement dynamics, workout counts, and
/// exercise progress alike.
class StatsPeriod {
  const StatsPeriod.preset(this.preset)
    : assert(preset != StatsPeriodPreset.custom),
      customFrom = null,
      customTo = null;

  const StatsPeriod.custom({required DateTime from, required DateTime to})
    : preset = StatsPeriodPreset.custom,
      customFrom = from,
      customTo = to;

  final StatsPeriodPreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;

  /// The inclusive local-date range for this period, anchored at [today]
  /// (time-of-day ignored). `(null, null)` for [StatsPeriodPreset.allTime]
  /// means unbounded on both sides.
  (DateTime? from, DateTime? to) range(DateTime today) {
    final anchor = DateTime(today.year, today.month, today.day);
    switch (preset) {
      case StatsPeriodPreset.allTime:
        return (null, null);
      case StatsPeriodPreset.custom:
        return (customFrom, customTo);
      case StatsPeriodPreset.week:
      case StatsPeriodPreset.month:
      case StatsPeriodPreset.threeMonths:
      case StatsPeriodPreset.year:
        final days = _presetDays[preset]!;
        return (anchor.subtract(Duration(days: days - 1)), anchor);
    }
  }
}
