import 'package:intl/intl.dart';

/// Which of a chronologically-sorted, one-per-chart-X-position list of
/// [DateTime]s should get an X-axis tick label, and how to read them.
class DateAxisTicks {
  const DateAxisTicks({required this.indexes, required this.monthly});

  /// Indexes into the original date list that should show a label.
  final Set<int> indexes;

  /// Whether [indexes] were chosen by the "start of month" rule (true) or
  /// the "Monday" rule (false) -- [formatDateTick] needs to know which,
  /// since it doesn't re-derive it from the dates itself.
  final bool monthly;
}

/// Owner-supplied reference image + explicit rule (redesign_v3): a chart
/// spanning a month or less ticks every Monday; anything longer ticks the
/// first available point of each calendar month. There's no true
/// time-scaled X axis here (chart points sit at equal pixel spacing by
/// list position, not by elapsed days -- unchanged by this), so "start of
/// month" means the first data point that landed in a given month, not
/// literally day 1.
DateAxisTicks dateAxisTicks(List<DateTime> dates) {
  if (dates.isEmpty) return const DateAxisTicks(indexes: {}, monthly: false);
  final monthly = dates.last.difference(dates.first).inDays > 31;
  final indexes = <int>{};
  for (var i = 0; i < dates.length; i++) {
    if (monthly) {
      if (i == 0 ||
          dates[i].year != dates[i - 1].year ||
          dates[i].month != dates[i - 1].month) {
        indexes.add(i);
      }
    } else if (dates[i].weekday == DateTime.monday) {
      indexes.add(i);
    }
  }
  return DateAxisTicks(indexes: indexes, monthly: monthly);
}

/// The label text for one tick -- a localized short month name for
/// [monthly] ticks ("Jan"/"янв."), a locale-independent `DD.MM` for weekly
/// (Monday) ticks, matching the app's existing locale-independent
/// short-date convention (`core/date_format.dart`'s `formatShortDate`).
String formatDateTick(
  DateTime date, {
  required bool monthly,
  required String locale,
}) {
  if (monthly) return DateFormat.MMM(locale).format(date);
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month';
}
