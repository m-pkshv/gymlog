import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants.dart';
import '../../../domain/enums.dart';
import '../../../domain/models/workout_details.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/exercise_type_labels.dart';
import '../set_field_config.dart';
import 'comment_field.dart';
import 'past_results_sheet.dart';
import 'progression_segmented_button.dart';
import 'set_row.dart';

enum _ExerciseCardAction { pastResults, copyLastPerformance, moveUp, moveDown }

/// Card for one exercise entry in the workout editor (S-03): header + the
/// sets table + "+ Подход" + "Прошлые результаты"/"Копировать показатели
/// прошлого выполнения" (menu, TS 8 section 8) + reorder — a leading drag
/// handle (04_UI_UX_SPEC.md, section 5: "ручка-иконка (drag)") plus
/// "⋮ → Вверх/Вниз" as the gesture-free alternative (05_AI_INSTRUCTIONS.md,
/// rule: every gesture needs one) + a comment field + the progression
/// segment (—/↑/=/↓, DM 6.11 "ручная отметка") with the D-7 stagnation hint
/// ("N без роста", read from `progressionStateProvider` — a cache the
/// manual decision itself never influences).
///
/// Collapsible (Stage 10, owner-reported): a long workout's sets table
/// becomes one hard-to-scan wall of rows; tapping the header (type icon +
/// name, not the drag handle or "⋮" menu, which keep their own gestures)
/// collapses everything below it down to just the name. Purely local UI
/// state (`_expanded`, defaulting to `true`) -- nothing is written to the
/// database, and it isn't meant to survive leaving/reopening the editor.
/// It does survive incidental data reloads (`_load()` after every add/edit)
/// within the same screen instance, because `ExerciseCard` is keyed by
/// `workoutExercise.id` in the list above it, so Flutter reuses this
/// State object rather than recreating it.
class ExerciseCard extends ConsumerStatefulWidget {
  const ExerciseCard({
    super.key,
    required this.details,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onCompletedChanged,
    required this.onAddSet,
    required this.onDuplicateLastSet,
    required this.onCopyLastPerformance,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onCommentChanged,
    required this.onCommentCommit,
    required this.onSetDeleted,
    required this.onProgressionDecisionChanged,
  });

  final WorkoutExerciseDetails details;

  /// This card's position in the exercise list — required by
  /// [ReorderableDragStartListener] to identify the drag handle's item.
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final void Function(
    String setId,
    SetFieldSpec field,
    bool actual,
    double? value,
  )
  onFieldChanged;
  final void Function(String setId, SetFieldSpec field, bool actual)
  onFieldCommit;
  final void Function(String setId, bool value) onCompletedChanged;
  final VoidCallback onAddSet;
  final VoidCallback onDuplicateLastSet;
  final VoidCallback onCopyLastPerformance;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onCommentCommit;
  final ValueChanged<String> onSetDeleted;
  final ValueChanged<ProgressionDecision> onProgressionDecisionChanged;

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = widget.details;
    final fields = setFieldsFor(details.exercise.exerciseType, l10n);
    final canDuplicateLastSet =
        details.sets.isNotEmpty &&
        hasPlannedValues(details.sets.last, details.exercise.exerciseType);
    final stagnationCount = ref
        .watch(progressionStateProvider(details.exercise.id))
        .value
        ?.stagnationCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // UX 11: icon-only control, no visible text of its own --
                // needs a Semantics label. The bare 24dp icon is also below
                // the 48dp minimum touch target; the padding brings it up
                // to exactly 48dp without changing what's visually drawn.
                Semantics(
                  label: l10n.reorderDragHandleLabel,
                  child: ReorderableDragStartListener(
                    index: widget.index,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    label: _expanded
                        ? l10n.collapseExerciseAction
                        : l10n.expandExerciseAction,
                    child: InkWell(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(exerciseTypeIcon(details.exercise.exerciseType)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                details.exercise.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Icon(
                              _expanded ? Icons.expand_less : Icons.expand_more,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<_ExerciseCardAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _ExerciseCardAction.pastResults:
                        showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          isScrollControlled: true,
                          builder: (context) =>
                              PastResultsSheet(exercise: details.exercise),
                        );
                      case _ExerciseCardAction.copyLastPerformance:
                        widget.onCopyLastPerformance();
                      case _ExerciseCardAction.moveUp:
                        widget.onMoveUp();
                      case _ExerciseCardAction.moveDown:
                        widget.onMoveDown();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: _ExerciseCardAction.pastResults,
                      child: Text(l10n.pastResultsAction),
                    ),
                    PopupMenuItem(
                      value: _ExerciseCardAction.copyLastPerformance,
                      child: Text(l10n.copyLastPerformanceAction),
                    ),
                    if (widget.canMoveUp)
                      PopupMenuItem(
                        value: _ExerciseCardAction.moveUp,
                        child: Text(l10n.moveExerciseUpAction),
                      ),
                    if (widget.canMoveDown)
                      PopupMenuItem(
                        value: _ExerciseCardAction.moveDown,
                        child: Text(l10n.moveExerciseDownAction),
                      ),
                  ],
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              for (final set in details.sets)
                SetRow(
                  set: set,
                  fields: fields,
                  onFieldChanged: (field, actual, value) =>
                      widget.onFieldChanged(set.id, field, actual, value),
                  onFieldCommit: (field, actual) =>
                      widget.onFieldCommit(set.id, field, actual),
                  onCompletedChanged: (value) =>
                      widget.onCompletedChanged(set.id, value),
                  onDelete: () => widget.onSetDeleted(set.id),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: widget.onAddSet,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addSetAction),
                  ),
                  if (canDuplicateLastSet)
                    IconButton(
                      onPressed: widget.onDuplicateLastSet,
                      icon: const Icon(Icons.content_copy),
                      tooltip: l10n.duplicateSetAction,
                    ),
                ],
              ),
              CommentField(
                key: ValueKey('exercise-comment-${details.workoutExercise.id}'),
                value: details.workoutExercise.comment,
                label: l10n.exerciseCommentLabel,
                maxLength: CommentLengthLimits.workoutExercise,
                onChanged: widget.onCommentChanged,
                onCommit: widget.onCommentCommit,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.progressionDecisionLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 8),
                  ProgressionSegmentedButton(
                    selected: details.workoutExercise.progressionDecision,
                    onChanged: widget.onProgressionDecisionChanged,
                  ),
                ],
              ),
              if (stagnationCount != null && stagnationCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.stagnationHint(stagnationCount),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
