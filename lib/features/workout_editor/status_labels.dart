import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// Display label for the statuses reachable from the Stage 1 editor
/// (draft/inProgress/completed — the full status menu is Stage 3 scope).
String workoutStatusLabel(AppLocalizations l10n, WorkoutStatus status) {
  switch (status) {
    case WorkoutStatus.draft:
      return l10n.statusDraft;
    case WorkoutStatus.inProgress:
      return l10n.statusInProgress;
    case WorkoutStatus.completed:
      return l10n.statusCompleted;
    case WorkoutStatus.planned:
    case WorkoutStatus.skipped:
    case WorkoutStatus.cancelled:
      // Unreachable from the Stage 1 editor (draft -> inProgress ->
      // completed only); the full status menu lands in Stage 3.
      return status.name;
  }
}
