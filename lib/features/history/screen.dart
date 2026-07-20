import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/models/workout_history_entry.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/status_labels.dart';

/// S-02 "История", simplified for Stage 1: a plain list of completed
/// workouts, no filters/calendar/tags/pagination yet
/// (02_DEVELOPMENT_PLAN.md — those arrive in Stage 3). Tapping a card opens
/// the editor (S-03); the FAB creates a draft and opens it there too.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

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
            itemBuilder: (context, index) =>
                _WorkoutHistoryTile(entry: entries[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.historyLoadError)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final workout = await ref
              .read(workoutRepositoryProvider)
              .createDraft(date: DateTime.now());
          if (context.mounted) {
            context.push('/history/workout/${workout.id}');
          }
        },
        tooltip: l10n.newWorkoutAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  const _WorkoutHistoryTile({required this.entry});

  final WorkoutHistoryEntry entry;

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
      trailing: Chip(label: Text(workoutStatusLabel(l10n, workout.status))),
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
