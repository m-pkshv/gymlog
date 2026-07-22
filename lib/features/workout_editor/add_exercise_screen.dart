import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_catalog_filter.dart';
import '../../l10n/app_localizations.dart';
import '../exercises/exercise_type_labels.dart';

/// "+ Упражнение" picker (S-03, and S-13's identical template flavor): pick
/// an existing catalog entry, or create one on the spot ("Создать новое",
/// S-08) — either way the result is popped back to the caller, which adds
/// it to the workout/template right away. Stage 1 scope: no search/filters
/// (those land with the full S-06 in Stage 2). [addExerciseRoute] is this
/// screen's own full path (e.g. `/history/workout/$id/add-exercise` or
/// `/more/templates/$id/add-exercise`) — used only to build the "Создать
/// новое" child route, so this screen doesn't need to know which aggregate
/// it's picking for.
class AddExerciseScreen extends ConsumerWidget {
  const AddExerciseScreen({super.key, required this.addExerciseRoute});

  final String addExerciseRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(
      exercisesListProvider(emptyExerciseCatalogFilter),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addExerciseAction)),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                leading: Icon(exerciseTypeIcon(exercise.exerciseType)),
                title: Text(exercise.name),
                subtitle: Text(exerciseTypeLabel(l10n, exercise.exerciseType)),
                onTap: () => context.pop(exercise),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.exercisesLoadError,
          onRetry: () =>
              ref.invalidate(exercisesListProvider(emptyExerciseCatalogFilter)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await context.push<Exercise>('$addExerciseRoute/new');
          if (created != null && context.mounted) context.pop(created);
        },
        tooltip: l10n.createExerciseAction,
        child: const Icon(Icons.add),
      ),
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
              Icons.fitness_center_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.exercisesEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
