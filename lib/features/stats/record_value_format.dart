import '../../core/duration_format.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// Formats a [PersonalRecord.value] for display (S-10), by [RecordType] --
/// always metric, same as every other workout-derived figure in the app
/// (ASSUMPTION(fixed-metric-unit), Stage 1; reused as-is for the Stage 7
/// records list and reps-at-weight table rather than converting through
/// `AppSettings.unitSystem` the way Stage 6's measurements do).
String formatRecordValue(AppLocalizations l10n, RecordType type, double value) {
  switch (type) {
    case RecordType.maxWeight:
    case RecordType.max1RM:
    case RecordType.maxVolumeWorkout:
      return l10n.statsKgValue(value.toStringAsFixed(1));
    case RecordType.maxRepsAtWeight:
      return value.round().toString();
    case RecordType.maxDistance:
      return l10n.statsKmValue((value / 1000).toStringAsFixed(2));
    case RecordType.bestPace:
      return l10n.statsPaceValue(const UnitConverter().formatPace(value));
    case RecordType.longestDuration:
      return formatElapsedTime(value.round());
  }
}

/// TS 9 / S-10: the 1RM figure is an estimate (Epley formula, D-6), not a
/// measured value -- 04_UI_UX_SPEC.md calls for a "«расчётный»" badge next
/// to it so it isn't mistaken for an actually-lifted weight.
bool isEstimatedRecord(RecordType type) => type == RecordType.max1RM;
