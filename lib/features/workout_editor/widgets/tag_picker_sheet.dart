import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../domain/models/workout_tag.dart';
import '../../../l10n/app_localizations.dart';
import '../controller.dart';
import 'workout_tag_chip.dart';

/// "Теги" bottom sheet (S-03, DM 6.3/6.5): every non-deleted tag as a
/// togglable `FilterChip` — tapping immediately assigns/unassigns it to
/// [workoutId] (no separate "Apply" button, same as the completed checkbox
/// elsewhere in the editor). Reads the current assignment from the live
/// controller state (not a snapshot passed in) so chips reflect a toggle
/// immediately.
///
/// Stage 10, owner-reported: creating and deleting tags used to live here
/// too (a "+ Создать тег" button and a delete "✕" on each chip), but the
/// delete "✕" was easy to mistake for unassigning the tag from this
/// workout. That management now lives on its own screen (Ещё → Теги,
/// `TagListScreen`) — this sheet only ever assigns/unassigns.
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
        // Stage 10, owner-reported: with 17 seeded muscle-group tags plus
        // whatever custom ones exist, the chip `Wrap` regularly grows
        // taller than the sheet's available height and overflows past the
        // bottom of the screen. Scrolling the content (same fix already
        // used by the exercise/history filter sheets) instead of letting
        // it overflow.
        child: SingleChildScrollView(
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
                          for (final tag in sortedWorkoutTags(tags, l10n))
                            FilterChip(
                              avatar: CircleAvatar(
                                backgroundColor: tagColor(tag.colorHex),
                                radius: 8,
                              ),
                              label: Text(workoutTagLabel(l10n, tag)),
                              selected: assignedIds.contains(tag.id),
                              onSelected: (selected) => _toggle(
                                controller,
                                assignedIds,
                                tag,
                                selected,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
