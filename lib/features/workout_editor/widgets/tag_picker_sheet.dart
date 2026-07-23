import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../domain/models/workout_tag.dart';
import '../../../l10n/app_localizations.dart';
import '../controller.dart';
import 'workout_tag_chip.dart';

/// "Теги" bottom sheet (S-03, DM 6.3/6.5): every non-deleted tag as a
/// togglable `FilterChip` — tapping immediately assigns/unassigns it to
/// [workoutId] (no separate "Apply" button, same as the completed
/// checkbox elsewhere in the editor) — plus a "+ Создать тег" action.
/// Reads the current assignment from the live controller state (not a
/// snapshot passed in) so chips reflect a toggle immediately.
class TagPickerSheet extends ConsumerWidget {
  const TagPickerSheet({super.key, required this.workoutId});

  final String workoutId;

  Future<void> _toggle(
    WorkoutEditorController controller,
    Set<String> currentIds,
    WorkoutTag tag,
    bool selected,
  ) async {
    final updated = Set<String>.from(currentIds);
    if (selected) {
      updated.add(tag.id);
    } else {
      updated.remove(tag.id);
    }
    await controller.setTags(updated.toList());
  }

  Future<void> _createTag(
    BuildContext context,
    WorkoutEditorController controller,
    Set<String> currentIds,
  ) async {
    final created = await showDialog<WorkoutTag>(
      context: context,
      builder: (context) => const _CreateTagDialog(),
    );
    if (created == null) return;
    final updated = Set<String>.from(currentIds)..add(created.id);
    await controller.setTags(updated.toList());
  }

  /// "Удалить тег" (Stage 10, owner-reported/DM 10): confirms with the
  /// count of non-deleted workouts that will lose this tag before deleting
  /// it — no Undo afterward, unlike workouts/templates/measurements
  /// (owner-confirmed: matches DM 10's already-documented rule for tags).
  /// Reloads the *current* workout's own state afterward in case this tag
  /// happened to be assigned here -- `workoutTagsListProvider` (the picker's
  /// own chip list) updates on its own since it's a live stream, but
  /// `WorkoutEditorController`'s `details.tags` is a snapshot taken at load
  /// time, not a live join.
  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    WorkoutEditorController controller,
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
    await controller.reload();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(workoutEditorControllerProvider(workoutId));
    final controller = ref.read(
      workoutEditorControllerProvider(workoutId).notifier,
    );
    final tagsAsync = ref.watch(workoutTagsListProvider);
    final assignedIds =
        detailsAsync.value?.tags.map((tag) => tag.id).toSet() ??
        const <String>{};

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.workoutTagsSheetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            tagsAsync.when(
              data: (tags) => tags.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(l10n.workoutTagsEmpty),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: tagColor(tag.colorHex),
                              radius: 8,
                            ),
                            label: Text(workoutTagLabel(l10n, tag)),
                            selected: assignedIds.contains(tag.id),
                            onSelected: (selected) =>
                                _toggle(controller, assignedIds, tag, selected),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () =>
                                _confirmDelete(context, ref, controller, tag),
                          ),
                      ],
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => ErrorRetryState(
                message: l10n.workoutTagsLoadError,
                onRetry: () => ref.invalidate(workoutTagsListProvider),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _createTag(context, controller, assignedIds),
              icon: const Icon(Icons.add),
              label: Text(l10n.createTagAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateTagDialog extends ConsumerStatefulWidget {
  const _CreateTagDialog();

  @override
  ConsumerState<_CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<_CreateTagDialog> {
  final _nameController = TextEditingController();
  String _colorHex = workoutTagColorPalette.first;
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final result = await ref
        .read(workoutTagServiceProvider)
        .create(name: _nameController.text, colorHex: _colorHex);
    if (!mounted) return;
    result.fold((tag) => Navigator.of(context).pop(tag), (error) {
      setState(() {
        _isSubmitting = false;
        _error = l10n.createTagError;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.createTagTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: WorkoutTagRules.maxNameLength,
            decoration: InputDecoration(
              labelText: l10n.tagNameLabel,
              errorText: _error,
            ),
            onChanged: (_) => setState(() {
              if (_error != null) _error = null;
            }),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final colorHex in workoutTagColorPalette)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _colorHex = colorHex),
                  child: CircleAvatar(
                    backgroundColor: tagColor(colorHex),
                    radius: 14,
                    // Fixed white, not `Theme.of(context)`, on purpose: the
                    // swatch itself is `colorHex` from the tag palette
                    // (UX-1), not a themed surface -- the checkmark needs
                    // to contrast against that arbitrary fixed color, not
                    // against the current theme.
                    child: _colorHex == colorHex
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _isNameValid && !_isSubmitting ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.actionCreate),
        ),
      ],
    );
  }
}
