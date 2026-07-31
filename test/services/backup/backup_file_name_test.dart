import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/services/backup/backup_file_name.dart';

void main() {
  test('formats as ironbook_backup_YYYY-MM-DD_HHmm.zip', () {
    expect(
      backupZipFileName(DateTime(2026, 7, 30, 9, 5)),
      'ironbook_backup_2026-07-30_0905.zip',
    );
  });

  test('pads single-digit month/day/hour/minute', () {
    expect(
      backupZipFileName(DateTime(2026, 1, 2, 3, 4)),
      'ironbook_backup_2026-01-02_0304.zip',
    );
  });
}
