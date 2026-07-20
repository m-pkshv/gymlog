import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../l10n/app_localizations.dart';
import 'copy_workout_flow.dart';

/// "Копией" (creation menu option, TS 8 section 8): pick which completed
/// workout to copy from. Reuses `historyListProvider` — the same
/// completed-workouts list History shows — since copying a workout that
/// hasn't actually been performed yet doesn't make sense.
class CopySourcePickerScreen extends ConsumerWidget {
  const CopySourcePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.copySourcePickerTitle)),
      body: historyAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(child: Text(l10n.copySourcePickerEmpty));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final workout = entry.workout;
              final name =
                  workout.name ??
                  '${l10n.workoutDefaultNamePrefix} ${formatShortDate(workout.date)}';
              return ListTile(
                title: Text(name),
                subtitle: Text(
                  '${formatShortDate(workout.date)} · '
                  '${l10n.workoutExerciseCount(entry.exerciseCount)}',
                ),
                onTap: () => copyWorkoutFlow(context, ref, workout),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.historyLoadError)),
      ),
    );
  }
}
