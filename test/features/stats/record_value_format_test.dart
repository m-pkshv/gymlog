import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/stats/record_value_format.dart';
import 'package:gymlog/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('formatRecordValue (S-10)', () {
    test('maxWeight is a one-decimal kg figure', () {
      expect(formatRecordValue(l10n, RecordType.maxWeight, 100.0), '100.0 kg');
    });

    test('max1RM is a one-decimal kg figure', () {
      expect(formatRecordValue(l10n, RecordType.max1RM, 116.7), '116.7 kg');
    });

    test('maxVolumeWorkout is a one-decimal kg figure', () {
      expect(
        formatRecordValue(l10n, RecordType.maxVolumeWorkout, 2500.0),
        '2500.0 kg',
      );
    });

    test('maxRepsAtWeight is a plain rounded integer, no unit', () {
      expect(formatRecordValue(l10n, RecordType.maxRepsAtWeight, 12.0), '12');
    });

    test('maxDistance converts meters to a two-decimal km figure', () {
      expect(
        formatRecordValue(l10n, RecordType.maxDistance, 5200.0),
        '5.20 km',
      );
    });

    test('bestPace formats seconds-per-km as m:ss with a unit suffix', () {
      // 330 seconds/km = 5:30/km.
      expect(formatRecordValue(l10n, RecordType.bestPace, 330.0), '5:30 / km');
    });

    test('longestDuration formats seconds as H:MM:SS/MM:SS, no unit suffix', () {
      expect(
        formatRecordValue(l10n, RecordType.longestDuration, 95.0),
        '01:35',
      );
    });
  });

  group('isEstimatedRecord (04_UI_UX_SPEC.md S-10: "пометка «расчётный»")', () {
    test('true only for max1RM', () {
      expect(isEstimatedRecord(RecordType.max1RM), isTrue);
      expect(isEstimatedRecord(RecordType.maxWeight), isFalse);
      expect(isEstimatedRecord(RecordType.maxVolumeWorkout), isFalse);
      expect(isEstimatedRecord(RecordType.maxRepsAtWeight), isFalse);
      expect(isEstimatedRecord(RecordType.maxDistance), isFalse);
      expect(isEstimatedRecord(RecordType.bestPace), isFalse);
      expect(isEstimatedRecord(RecordType.longestDuration), isFalse);
    });
  });
}
