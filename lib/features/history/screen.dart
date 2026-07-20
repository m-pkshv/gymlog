import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_history_entry.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/status_labels.dart';
import 'copy_workout_flow.dart';

enum _HistoryCardAction { copy }

enum _NewWorkoutChoice { scratch, copy }

/// S-02 "История", simplified for Stage 1: a plain list of completed
/// workouts, no filters/calendar/pagination yet (02_DEVELOPMENT_PLAN.md —
/// those arrive later in Stage 3). Tapping a card opens the editor (S-03).
/// Stage 3 added the per-card "⋮" menu's "Копировать" action (TS 8 section
/// 8) — "перенести"/"удалить" from the same S-02 menu are separate,
/// not-yet-done Stage 3 items (move already exists inside the editor;
/// delete needs the still-pending Undo-delete work) — and turned the FAB
/// into the "с нуля/из шаблона/копией" creation menu (02_DEVELOPMENT_PLAN.md,
/// Stage 3 функциональность).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  Future<void> _openNewWorkoutMenu(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<_NewWorkoutChoice>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l10n.newWorkoutFromScratchAction),
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_NewWorkoutChoice.scratch),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l10n.newWorkoutFromCopyAction),
              onTap: () => Navigator.of(sheetContext).pop(_NewWorkoutChoice.copy),
            ),
            ListTile(
              enabled: false,
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.newWorkoutFromTemplateAction),
              subtitle: Text(l10n.comingSoonLabel),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    switch (choice) {
      case _NewWorkoutChoice.scratch:
        final workout = await ref
            .read(workoutRepositoryProvider)
            .createDraft(date: DateTime.now());
        if (context.mounted) {
          context.push('/history/workout/${workout.id}');
        }
      case _NewWorkoutChoice.copy:
        context.push('/history/copy-source');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHistory)),
      body: historyAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) => _WorkoutHistoryTile(
              entry: entries[index],
              onCopy: (source) => copyWorkoutFlow(context, ref, source),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.historyLoadError)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNewWorkoutMenu(context, ref),
        tooltip: l10n.newWorkoutAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  const _WorkoutHistoryTile({required this.entry, required this.onCopy});

  final WorkoutHistoryEntry entry;
  final void Function(Workout source) onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workout = entry.workout;
    final name = workout.name ?? '${l10n.workoutDefaultNamePrefix} ${formatShortDate(workout.date)}';
    final durationSec = workout.actualDurationSec;

    return ListTile(
      title: Text(name),
      subtitle: Text(
        '${formatShortDate(workout.date)} · '
        '${l10n.workoutExerciseCount(entry.exerciseCount)}'
        '${durationSec != null ? ' · ${l10n.workoutDurationMinutes(durationSec ~/ 60)}' : ''}',
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
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _HistoryCardAction.copy,
                child: Text(l10n.copyWorkoutAction),
              ),
            ],
          ),
        ],
      ),
      onTap: () => context.push('/history/workout/${workout.id}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.historyEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
