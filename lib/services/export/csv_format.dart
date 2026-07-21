/// Locale-independent CSV primitives (03_TECHNICAL_SPEC.md, section 10.1):
/// RFC 4180 escaping, CRLF row terminators, `.` decimal separator, and
/// `YYYY-MM-DD` dates -- never `NumberFormat`/`DateFormat` of the current
/// locale, which TS 10.1 explicitly forbids for CSV output. This file has
/// no dependency on the domain models -- it's pure string formatting,
/// reused by every `*_csv.dart` builder.
library;

/// RFC 4180: a field is quoted only when it contains a comma, a double
/// quote, or a line break; an embedded quote is escaped by doubling it.
String csvEscape(String value) {
  final needsQuoting =
      value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}

/// One CSV row: comma-joined, RFC 4180-escaped, CRLF-terminated (the
/// canonical RFC 4180 line ending, understood by Excel/Sheets either way).
String csvRow(List<String> cells) {
  return '${cells.map(csvEscape).join(',')}\r\n';
}

/// `YYYY-MM-DD`, locale-independent (TS 10.1). Same format
/// `data/mappers/workout_mapper.dart`'s `dateOnlyString` produces for
/// storage -- reimplemented here rather than imported so this Services-
/// layer module has no dependency on the Data layer.
String formatCsvDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Empty cell for `null` (TS 10.1: "Пустое значение — пустая ячейка (не
/// null, не 0)"), otherwise the plain decimal text -- `.` separator, no
/// locale formatting, no rounding.
String formatCsvDecimal(double? value) =>
    value == null ? '' : value.toString();

String formatCsvInt(int? value) => value == null ? '' : value.toString();

String formatCsvBool(bool? value) =>
    value == null ? '' : (value ? 'true' : 'false');
