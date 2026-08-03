import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../domain/models/workout.dart';
import '../../../domain/models/workout_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../workout_editor/widgets/workout_tag_chip.dart';

enum _HistoryCardAction { copy, createTemplate, exportPdf, delete }

/// A single workout row (S-02): date/name/exercise count/duration/status/
/// tags, "⋮" menu with "Копировать"/"Создать шаблон"/"Экспортировать в
/// PDF"/"Удалить" (the PDF item added Stage 11, owner-reported: sharing a
/// workout without opening it first). Shared by
/// History's list view (`screen.dart`) and calendar view
/// (`calendar/history_calendar_view.dart`, Stage 3) so both render workouts
/// identically. Tapping the row always opens the editor (S-03), regardless
/// of status -- a completed workout stays fully editable/resumable (owner-
/// confirmed, Stage 10 redesign scope decision #2: unlike the mockup's
/// read-only "completed" card, this app keeps the existing 24h-resume/
/// retroactive-fact-edit behavior, so nothing here should suggest the row
/// is read-only).
///
/// Stage 10 redesign, AUDIT.md section 1.2: two named problems fixed here.
/// (1) the plain outlined status text "Завершена" didn't read as a status
/// at a glance -- replaced by [StatusBadge] (color-coded per
/// `workoutStatusColors`, same as the editor's own status control).
/// (2) rows had no card boundary at all (bare `ListTile`s back to back),
/// so a tag chip in the subtitle looked "torn off" from its own row and
/// nothing separated one workout from the next -- wrapped in a `Card`,
/// same margin `ExerciseCard`/`TemplateExerciseCard` use elsewhere.
class WorkoutHistoryTile extends ConsumerWidget {
  const WorkoutHistoryTile({
    super.key,
    required this.entry,
    required this.onCopy,
    required this.onCreateTemplate,
    required this.onExportPdf,
    required this.onDelete,
  });

  final WorkoutHistoryEntry entry;
  final void Function(Workout source) onCopy;

  /// "Создать шаблон" (TS 8 section 8, Stage 5) — the forward workout ->
  /// template copy direction; the reverse ("создать тренировку из
  /// шаблона") isn't wired up here yet, it needs DM-1 resolved first.
  final void Function(Workout source) onCreateTemplate;

  /// "Экспортировать в PDF" (Stage 11, owner-reported) -- unlike the other
  /// actions here, this one needs the full `WorkoutDetails` aggregate, not
  /// just the `Workout` row, so the callback itself is `async` (fetches
  /// the details first) rather than a plain `void Function`.
  final Future<void> Function(Workout source) onExportPdf;
  final void Function(Workout workout) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final workout = entry.workout;
    final name = workout.name ?? l10n.workoutDefaultNamePrefix;
    final durationSec = workout.actualDurationSec;
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        // Owner-reported: the "⋮" sat much further from the card's right
        // edge than it looked like it should. Measured it directly
        // (a throwaway widget test, comparing rendered rects) rather than
        // guess twice: `ListTile`'s own default `contentPadding`
        // (`EdgeInsets.symmetric(horizontal: 16)`) accounted for most of
        // that gap (measured ~36dp from the tile's own right edge to the
        // icon glyph, default padding included) -- the `PopupMenuButton`'s
        // `style` below (compact density, its own fix for a *different*
        // problem: matching the workout editor's own "⋮" size) only ever
        // moved the icon 4dp, not the 24+ it looked like it should. Ended
        // up shrinking `contentPadding`'s end inset specifically (title/
        // subtitle keep the normal 16dp start), which cut that measured
        // gap to 12dp -- the actual effective lever, not the button style.
        contentPadding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 4,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatShortDate(workout.date)} · '
              '${l10n.workoutExerciseCount(entry.exerciseCount)}'
              '${durationSec != null ? ' · ${l10n.workoutDurationMinutes(durationSec ~/ 60)}' : ''}',
            ),
            if (showTags && entry.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final tag in entry.tags) WorkoutTagChip(tag: tag),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatusBadge(status: workout.status),
            // Compact density: same fix already used for
            // `WorkoutStatusMenu`'s "⋮" (the workout editor's header
            // row) -- shrinks the default 48dp touch target to 40dp, a
            // smaller, secondary contributor to the edge-distance fix
            // above (`ListTile.contentPadding`'s the main lever; this
            // alone only measured ~4dp on its own, see that comment).
            PopupMenuButton<_HistoryCardAction>(
              style: IconButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              onSelected: (action) {
                switch (action) {
                  case _HistoryCardAction.copy:
                    onCopy(workout);
                  case _HistoryCardAction.createTemplate:
                    onCreateTemplate(workout);
                  case _HistoryCardAction.exportPdf:
                    onExportPdf(workout);
                  case _HistoryCardAction.delete:
                    onDelete(workout);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _HistoryCardAction.copy,
                  child: Text(l10n.copyWorkoutAction),
                ),
                PopupMenuItem(
                  value: _HistoryCardAction.createTemplate,
                  child: Text(l10n.createTemplateFromWorkoutAction),
                ),
                PopupMenuItem(
                  value: _HistoryCardAction.exportPdf,
                  child: Text(l10n.exportWorkoutPdfAction),
                ),
                PopupMenuItem(
                  value: _HistoryCardAction.delete,
                  child: Text(l10n.deleteWorkoutAction),
                ),
              ],
            ),
          ],
        ),
        onTap: () => context.push('/workout/${workout.id}'),
      ),
    );
  }
}
