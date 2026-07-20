import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

/// S-02 "История" placeholder (04_UI_UX_SPEC.md, section 5). The list,
/// filters and calendar view land in the next Stage 1 step.
///
/// ASSUMPTION(temp-new-workout-entry): the FAB below is only enough of S-02
/// to reach the workout editor (S-03) for manual testing this step — it
/// creates a draft and opens it, nothing else. The full list (and its own
/// FAB per 04_UI_UX_SPEC.md, section 5) replaces this placeholder body in
/// the next step; the FAB's behavior carries over unchanged.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabHistory)),
      body: Center(child: Text(l10n.tabHistory)),
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
