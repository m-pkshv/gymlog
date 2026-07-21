import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/export/export_file_name.dart';

void main() {
  test('formats as gymlog_export_YYYY-MM-DD_HHmm.zip', () {
    expect(
      exportZipFileName(DateTime(2026, 7, 19, 14, 5)),
      'gymlog_export_2026-07-19_1405.zip',
    );
  });

  test('pads single-digit month/day/hour/minute', () {
    expect(
      exportZipFileName(DateTime(2026, 3, 9, 8, 2)),
      'gymlog_export_2026-03-09_0802.zip',
    );
  });
}
