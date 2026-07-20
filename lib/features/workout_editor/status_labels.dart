import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../services/workout_service.dart';

String workoutStatusLabel(AppLocalizations l10n, WorkoutStatus status) {
  switch (status) {
    case WorkoutStatus.draft:
      return l10n.statusDraft;
    case WorkoutStatus.inProgress:
      return l10n.statusInProgress;
    case WorkoutStatus.completed:
      return l10n.statusCompleted;
    case WorkoutStatus.planned:
      return l10n.statusPlanned;
    case WorkoutStatus.skipped:
      return l10n.statusSkipped;
    case WorkoutStatus.cancelled:
      return l10n.statusCancelled;
  }
}

/// The statuses [from] may transition to (06_DATA_MODEL.md, section 6.4.1)
/// — reuses `WorkoutService.allowedTransitions` directly rather than
/// duplicating the table, so the status menu can never drift out of sync
/// with what the service actually allows.
Set<WorkoutStatus> allowedNextStatuses(WorkoutStatus from) {
  return WorkoutService.allowedTransitions[from] ?? const {};
}

/// Action verb for the (from -> to) transition (DM 6.4.1 names most of
/// these explicitly: "Запланировать", "Начать", "Завершить", "Возобновить",
/// "Вернуть в план"). [to] alone determines the label except for
/// `inProgress` (resuming a `completed` workout reads "Возобновить", not
/// "Начать") and `planned` (returning from `skipped`/`cancelled` reads
/// "Вернуть в план", not "Запланировать").
String workoutTransitionActionLabel(
  AppLocalizations l10n,
  WorkoutStatus from,
  WorkoutStatus to,
) {
  switch (to) {
    case WorkoutStatus.planned:
      return from == WorkoutStatus.draft
          ? l10n.transitionScheduleAction
          : l10n.transitionBackToPlanAction;
    case WorkoutStatus.inProgress:
      return from == WorkoutStatus.completed
          ? l10n.transitionResumeAction
          : l10n.startWorkoutAction;
    case WorkoutStatus.completed:
      return l10n.finishWorkoutAction;
    case WorkoutStatus.cancelled:
      return l10n.transitionCancelAction;
    case WorkoutStatus.skipped:
      return l10n.transitionSkipAction;
    case WorkoutStatus.draft:
      return l10n.transitionBackToDraftAction;
  }
}
