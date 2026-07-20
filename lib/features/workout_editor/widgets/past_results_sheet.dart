import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/date_format.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/exercise_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/exercise_set_format.dart';

/// "Прошлые результаты" (S-03, 04_UI_UX_SPEC.md section 5): the last 5
/// completed occurrences of an exercise, read-only — opened as a bottom
/// sheet from the exercise card's menu (`showDragHandle: true` gives the
/// handle indicator the spec calls for).
class PastResultsSheet extends ConsumerWidget {
  const PastResultsSheet({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FutureBuilder<List<ExerciseHistoryEntry>>(
          future: ref
              .read(workoutRepositoryProvider)
              .getExerciseHistory(exercise.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                height: 120,
                child: Center(child: Text(l10n.pastResultsLoadError)),
              );
            }
            final entries = (snapshot.data ?? const []).take(5).toList();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pastResultsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.pastResultsEmpty)),
                  )
                else
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(formatShortDate(entry.workout.date)),
                        subtitle: Text(
                          entry.sets
                              .map(
                                (set) => formatSetSummary(
                                  set,
                                  exercise.exerciseType,
                                ),
                              )
                              .join(', '),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
