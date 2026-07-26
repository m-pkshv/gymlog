import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';

/// `DD.MM.YYYY` — the short date format used wherever a `Workout.date`
/// (local calendar date, no time-of-day) is shown (S-02, S-03). Locale-
/// independent by design (03_TECHNICAL_SPEC.md, section 10 uses the same
/// principle for CSV): no ambiguity between DD/MM and MM/DD regardless of
/// device locale.
String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

/// A relative day label for a [Workout.date] shown in a scannable list
/// (S-01 "Сегодня", Stage 10 redesign mockup: "Сегодня, 18:00" / "Завтра,
/// 08:00" / "Четверг, 19:00"). Only the day part is real -- `Workout.date`
/// has no time-of-day component (DM 6.4), so unlike the mockup this never
/// shows a fabricated time. "Сегодня"/"Завтра" for the next two days,
/// otherwise the localized weekday name; falls back to [formatShortDate]
/// once a bare weekday would be ambiguous without a year (6+ days out).
String formatRelativeDay(BuildContext context, DateTime date) {
  final l10n = AppLocalizations.of(context)!;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final dayDiff = target.difference(today).inDays;
  if (dayDiff == 0) return l10n.todayRelativeDayLabel;
  if (dayDiff == 1) return l10n.tomorrowRelativeDayLabel;
  if (dayDiff > 1 && dayDiff < 7) {
    final locale = Localizations.localeOf(context).toString();
    final weekday = DateFormat.EEEE(locale).format(date);
    return weekday[0].toUpperCase() + weekday.substring(1);
  }
  return formatShortDate(date);
}
