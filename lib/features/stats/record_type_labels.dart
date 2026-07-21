import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// S-10 records-list row label for a [RecordType]. [RecordType.maxRepsAtWeight]
/// never reaches this — those rows render as their own "Повторения при весе"
/// table instead (04_UI_UX_SPEC.md, S-10), so it's not given a label here.
String recordTypeLabel(AppLocalizations l10n, RecordType type) {
  switch (type) {
    case RecordType.maxWeight:
      return l10n.recordTypeMaxWeight;
    case RecordType.max1RM:
      return l10n.recordTypeMax1RM;
    case RecordType.maxVolumeWorkout:
      return l10n.recordTypeMaxVolumeWorkout;
    case RecordType.maxDistance:
      return l10n.recordTypeMaxDistance;
    case RecordType.bestPace:
      return l10n.recordTypeBestPace;
    case RecordType.longestDuration:
      return l10n.recordTypeLongestDuration;
    case RecordType.maxRepsAtWeight:
      return l10n.statsRepsAtWeightTableTitle;
  }
}
