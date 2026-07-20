import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/exercise.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';

/// S-06 "Упражнения", simplified for Stage 1: list + FAB, no search or
/// filters yet (04_UI_UX_SPEC.md, section 5 — those arrive in Stage 2).
class ExercisesScreen extends ConsumerWidget {
  const ExercisesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(exercisesListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabExercises)),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return _EmptyState(l10n: l10n);
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) =>
                _ExerciseListTile(exercise: exercises[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.exercisesLoadError)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/exercises/new'),
        tooltip: l10n.createExerciseAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: Icon(exerciseTypeIcon(exercise.exerciseType)),
      title: Text(exercise.name),
      subtitle: Text(exerciseTypeLabel(l10n, exercise.exerciseType)),
      onTap: () => context.push('/exercises/${exercise.id}'),
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
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.push('/exercises/new'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createExerciseAction),
            ),
          ],
        ),
      ),
    );
  }
}
