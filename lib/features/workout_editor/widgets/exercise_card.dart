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
class ExerciseCard extends ConsumerWidget {
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
    required this.onCopyLastPerformance,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onCommentChanged,
    required this.onCommentCommit,
    required this.onSetCommentSaved,
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
  final VoidCallback onCopyLastPerformance;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onCommentCommit;
  final void Function(String setId, String comment) onSetCommentSaved;
  final ValueChanged<ProgressionDecision> onProgressionDecisionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final fields = setFieldsFor(details.exercise.exerciseType, l10n);
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
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.drag_handle),
                    ),
                  ),
                ),
                Icon(exerciseTypeIcon(details.exercise.exerciseType)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    details.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
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
                        onCopyLastPerformance();
                      case _ExerciseCardAction.moveUp:
                        onMoveUp();
                      case _ExerciseCardAction.moveDown:
                        onMoveDown();
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
                    if (canMoveUp)
                      PopupMenuItem(
                        value: _ExerciseCardAction.moveUp,
                        child: Text(l10n.moveExerciseUpAction),
                      ),
                    if (canMoveDown)
                      PopupMenuItem(
                        value: _ExerciseCardAction.moveDown,
                        child: Text(l10n.moveExerciseDownAction),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final set in details.sets)
              SetRow(
                set: set,
                fields: fields,
                onFieldChanged: (field, actual, value) =>
                    onFieldChanged(set.id, field, actual, value),
                onFieldCommit: (field, actual) =>
                    onFieldCommit(set.id, field, actual),
                onCompletedChanged: (value) =>
                    onCompletedChanged(set.id, value),
                onCommentSaved: (comment) =>
                    onSetCommentSaved(set.id, comment),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: Text(l10n.addSetAction),
              ),
            ),
            CommentField(
              key: ValueKey('exercise-comment-${details.workoutExercise.id}'),
              value: details.workoutExercise.comment,
              label: l10n.exerciseCommentLabel,
              maxLength: CommentLengthLimits.workoutExercise,
              onChanged: onCommentChanged,
              onCommit: onCommentCommit,
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
                  onChanged: onProgressionDecisionChanged,
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
        ),
      ),
    );
  }
}
