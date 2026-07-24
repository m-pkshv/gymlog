import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/workout_tag.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/widgets/workout_tag_chip.dart';
import 'widgets/create_tag_dialog.dart';

/// "Теги" management screen (Ещё → Теги, Stage 10, owner-reported):
/// app-wide tag create/delete. Assigning tags to a specific workout stays
/// in `TagPickerSheet` (opened from the workout editor's tag row), which
/// now only toggles assignment against this list — the split exists
/// because the picker's delete "✕" on a `FilterChip` was easy to mistake
/// for unassigning the tag from the workout.
class TagListScreen extends ConsumerWidget {
  const TagListScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    await showDialog<WorkoutTag>(
      context: context,
      builder: (context) => const CreateTagDialog(),
    );
  }

  /// Confirms with the count of non-deleted workouts that will lose this
  /// tag before deleting it — no Undo afterward, unlike
  /// workouts/templates/measurements (DM 10, matches the rule already used
  /// by the picker sheet before this screen existed).
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkoutTag tag,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(workoutTagRepositoryProvider);
    final count = await repository.countWorkoutsUsingTag(tag.id);
    if (!context.mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTagConfirmTitle),
        content: Text(l10n.deleteTagConfirmMessage(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteTagAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await repository.delete(tag.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(workoutTagsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tagsMenuTitle)),
      body: tagsAsync.when(
        data: (tags) => tags.isEmpty
            ? _EmptyState(l10n: l10n, onCreate: () => _create(context, ref))
            : ListView.builder(
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tagColor(tag.colorHex),
                      radius: 10,
                    ),
                    title: Text(workoutTagLabel(l10n, tag)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: l10n.deleteTagAction,
                      onPressed: () => _delete(context, ref, tag),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.workoutTagsLoadError,
          onRetry: () => ref.invalidate(workoutTagsListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(context, ref),
        tooltip: l10n.createTagAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.onCreate});

  final AppLocalizations l10n;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.tagsEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(l10n.createTagAction),
            ),
          ],
        ),
      ),
    );
  }
}
