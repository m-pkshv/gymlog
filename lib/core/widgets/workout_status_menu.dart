import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../features/workout_editor/status_labels.dart';
import '../../l10n/app_localizations.dart';

/// Marker for the "Удалить" entry inside [WorkoutStatusMenu] -- distinct
/// from any [WorkoutStatus] so a single `PopupMenuButton<Object>` can carry
/// both transition and delete items without an extra wrapper class.
const Object deleteWorkoutMenuAction = Object();

/// "⋮"-menu of workout status transitions other than the one already shown
/// as a big primary CTA button (Stage 10 redesign: the mockup's single
/// "Начать тренировку"/"Завершить тренировку" button replaces the old
/// status chip's dropdown, but DM 6.4.1 still allows 5 other transitions
/// from any given status plus delete -- this menu is where those live now,
/// so nothing that already worked is lost). [excludeStatus] is the
/// transition the primary CTA already covers, e.g. `inProgress` while
/// showing "Начать тренировку" for a draft.
///
/// Reuses [allowedNextStatuses]/[workoutTransitionActionLabel] directly, so
/// this can never drift out of sync with what `WorkoutService` actually
/// allows (DM 6.4.1).
class WorkoutStatusMenu extends StatelessWidget {
  const WorkoutStatusMenu({
    super.key,
    required this.status,
    required this.onSelectStatus,
    this.excludeStatus,
    this.onDelete,
  });

  final WorkoutStatus status;
  final ValueChanged<WorkoutStatus> onSelectStatus;
  final WorkoutStatus? excludeStatus;

  /// Omit to hide "Удалить" entirely (e.g. while the workout is
  /// `inProgress`, where DM 10 forbids deletion).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transitions = allowedNextStatuses(
      status,
    ).where((to) => to != excludeStatus).toList();

    if (transitions.isEmpty && onDelete == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<Object>(
      tooltip: l10n.workoutStatusMenuTooltip,
      onSelected: (action) {
        if (action == deleteWorkoutMenuAction) {
          onDelete?.call();
        } else {
          onSelectStatus(action as WorkoutStatus);
        }
      },
      itemBuilder: (context) => [
        for (final target in transitions)
          PopupMenuItem(
            value: target,
            child: Text(workoutTransitionActionLabel(l10n, status, target)),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: deleteWorkoutMenuAction,
            child: Text(l10n.deleteWorkoutAction),
          ),
      ],
    );
  }
}
