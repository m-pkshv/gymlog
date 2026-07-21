import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/date_format.dart';
import '../../../domain/models/workout.dart';
import '../../../domain/models/workout_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../workout_editor/status_labels.dart';
import '../../workout_editor/widgets/workout_tag_chip.dart';

enum _HistoryCardAction { copy, delete }

/// A single workout row (S-02): date/name/exercise count/duration/status/
/// tags, "⋮" menu with "Копировать"/"Удалить". Shared by History's list
/// view (`screen.dart`) and calendar view (`calendar/history_calendar_view.dart`,
/// Stage 3) so both render workouts identically.
class WorkoutHistoryTile extends ConsumerWidget {
  const WorkoutHistoryTile({
    super.key,
    required this.entry,
    required this.onCopy,
    required this.onDelete,
  });

  final WorkoutHistoryEntry entry;
  final void Function(Workout source) onCopy;
  final void Function(Workout workout) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final workout = entry.workout;
    final name = workout.name ?? '${l10n.workoutDefaultNamePrefix} ${formatShortDate(workout.date)}';
    final durationSec = workout.actualDurationSec;
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;

    return ListTile(
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
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
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
          Chip(label: Text(workoutStatusLabel(l10n, workout.status))),
          PopupMenuButton<_HistoryCardAction>(
            onSelected: (action) {
              switch (action) {
                case _HistoryCardAction.copy:
                  onCopy(workout);
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
                value: _HistoryCardAction.delete,
                child: Text(l10n.deleteWorkoutAction),
              ),
            ],
          ),
        ],
      ),
      onTap: () => context.push('/history/workout/${workout.id}'),
    );
  }
}
