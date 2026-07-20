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
