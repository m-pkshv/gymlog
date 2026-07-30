import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../features/workout_editor/status_labels.dart';
import '../../l10n/app_localizations.dart';

/// Markers for [WorkoutStatusMenu]'s two non-[WorkoutStatus] entries, so a
/// single `PopupMenuButton<Object>` can carry transitions and these extra
/// actions without a separate wrapper class per item.
///
/// An `enum` on purpose, not two `const Object()` sentinels (an earlier
/// version of this file used those): `Object`'s const constructor takes no
/// arguments, so the Dart compiler canonicalizes every `const Object()`
/// literal in the whole program to the *same* singleton instance --
/// `identical(const Object(), const Object())` is `true`. Two supposedly
/// distinct sentinels declared that way are actually one and the same
/// value, so `action == deleteWorkoutMenuAction` and
/// `action == saveAsTemplateMenuAction` would both be true for *either*
/// action (found the hard way: tapping "Создать шаблон" silently ran the
/// delete flow instead, since that `if` branch was checked first). Enum
/// values don't have this problem -- each one is guaranteed distinct.
enum _WorkoutMenuExtraAction { saveAsTemplate, delete, exportPdf }

/// Marker for the "Создать шаблон" entry inside [WorkoutStatusMenu]
/// (Stage 10, owner-reported: any workout -- draft, planned, or already
/// completed -- can be saved as a template right from the editor's own
/// "⋮" menu, not only from a History card).
const Object saveAsTemplateMenuAction = _WorkoutMenuExtraAction.saveAsTemplate;

/// Marker for the "Удалить" entry inside [WorkoutStatusMenu].
const Object deleteWorkoutMenuAction = _WorkoutMenuExtraAction.delete;

/// Marker for the "Экспортировать в PDF" entry inside [WorkoutStatusMenu]
/// (Stage 11).
const Object exportPdfMenuAction = _WorkoutMenuExtraAction.exportPdf;

/// "⋮"-menu of workout status transitions other than the one already shown
/// as a big primary CTA button (Stage 10 redesign: the mockup's single
/// "Начать тренировку"/"Завершить тренировку" button replaces the old
/// status chip's dropdown, but DM 6.4.1 still allows 5 other transitions
/// from any given status plus delete -- this menu is where those live now,
/// so nothing that already worked is lost). [excludeStatuses] are the
/// transitions already covered by CTA buttons elsewhere on screen, e.g.
/// `{inProgress}` while showing "Начать тренировку" for a draft, or
/// `{inProgress, planned}` once a draft also gets its own "Запланировать"
/// button (Stage 10 redesign, owner-reported).
///
/// Reuses [allowedNextStatuses]/[workoutTransitionActionLabel] directly, so
/// this can never drift out of sync with what `WorkoutService` actually
/// allows (DM 6.4.1).
class WorkoutStatusMenu extends StatelessWidget {
  const WorkoutStatusMenu({
    super.key,
    required this.status,
    required this.onSelectStatus,
    this.excludeStatuses = const {},
    this.onSaveAsTemplate,
    this.onDelete,
    this.onExportPdf,
  });

  final WorkoutStatus status;
  final ValueChanged<WorkoutStatus> onSelectStatus;
  final Set<WorkoutStatus> excludeStatuses;

  /// Omit to hide "Создать шаблон" entirely -- there's no status this
  /// isn't allowed from (TS 8 section 8 places no restriction on it, unlike
  /// delete's DM 10 rule below), so callers that support it should always
  /// pass this.
  final VoidCallback? onSaveAsTemplate;

  /// Omit to hide "Удалить" entirely (e.g. while the workout is
  /// `inProgress`, where DM 10 forbids deletion).
  final VoidCallback? onDelete;

  /// Omit to hide "Экспортировать в PDF" entirely (Stage 11) -- unlike
  /// delete, there's no status restriction, so every caller that supports
  /// it should always pass this.
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final transitions = allowedNextStatuses(
      status,
    ).where((to) => !excludeStatuses.contains(to)).toList();

    if (transitions.isEmpty &&
        onSaveAsTemplate == null &&
        onDelete == null &&
        onExportPdf == null) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<Object>(
      tooltip: l10n.workoutStatusMenuTooltip,
      // Matches the tag button's density (workout_editor/screen.dart's
      // _TagAddButton) -- Stage 10 redesign, owner-reported: the two
      // icon buttons in the header row didn't line up with each other
      // (default PopupMenuButton is a full 48dp target, the tag button
      // was already compact/40dp). `PopupMenuButton` has no direct
      // `visualDensity` param -- it forwards `style` to the internal
      // `IconButton` it builds when no custom `icon`/`child` is given.
      style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
      onSelected: (action) {
        if (action == deleteWorkoutMenuAction) {
          onDelete?.call();
        } else if (action == saveAsTemplateMenuAction) {
          onSaveAsTemplate?.call();
        } else if (action == exportPdfMenuAction) {
          onExportPdf?.call();
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
        if (onSaveAsTemplate != null)
          PopupMenuItem(
            value: saveAsTemplateMenuAction,
            child: Text(l10n.createTemplateFromWorkoutAction),
          ),
        if (onExportPdf != null)
          PopupMenuItem(
            value: exportPdfMenuAction,
            child: Text(l10n.exportWorkoutPdfAction),
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
