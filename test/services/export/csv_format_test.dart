import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/export/csv_format.dart';

void main() {
  group('csvEscape (RFC 4180)', () {
    test('a plain value is left unquoted', () {
      expect(csvEscape('Squat'), 'Squat');
    });

    test('a value containing a comma is quoted', () {
      expect(csvEscape('kg, lb'), '"kg, lb"');
    });

    test('a value containing a double quote is quoted and the quote doubled', () {
      expect(csvEscape('felt "great" today'), '"felt ""great"" today"');
    });

    test('a value containing a newline is quoted', () {
      expect(csvEscape('line one\nline two'), '"line one\nline two"');
    });

    test('a value containing a carriage return is quoted', () {
      expect(csvEscape('a\rb'), '"a\rb"');
    });

    test('an empty value is left unquoted', () {
      expect(csvEscape(''), '');
    });
  });

  group('csvRow', () {
    test('joins cells with commas and terminates with CRLF', () {
      expect(csvRow(['a', 'b', 'c']), 'a,b,c\r\n');
    });

    test('escapes cells that need it while joining', () {
      expect(csvRow(['a,b', 'c']), '"a,b",c\r\n');
    });
  });

  group('formatCsvDate', () {
    test('formats as YYYY-MM-DD regardless of locale', () {
      expect(formatCsvDate(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('pads single-digit month and day', () {
      expect(formatCsvDate(DateTime(2026, 3, 9)), '2026-03-09');
    });
  });

  group('formatCsvDecimal / formatCsvInt / formatCsvBool (TS 10.1)', () {
    test('null becomes an empty cell, never "0" or "null"', () {
      expect(formatCsvDecimal(null), '');
      expect(formatCsvInt(null), '');
      expect(formatCsvBool(null), '');
    });

    test('decimal uses a dot separator, no locale formatting', () {
      expect(formatCsvDecimal(100.5), '100.5');
    });

    test('bool renders as literal true/false', () {
      expect(formatCsvBool(true), 'true');
      expect(formatCsvBool(false), 'false');
    });

    test('int renders as plain digits', () {
      expect(formatCsvInt(5), '5');
    });
  });
}
