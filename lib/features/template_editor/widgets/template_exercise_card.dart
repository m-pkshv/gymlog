import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../domain/models/template_details.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/exercise_type_labels.dart';
import '../../workout_editor/widgets/comment_field.dart';
import '../template_set_field_config.dart';
import 'template_set_row.dart';

enum _TemplateExerciseCardAction { moveUp, moveDown }

/// Card for one exercise entry in the template editor (S-13) -- the
/// template counterpart of `workout_editor/widgets/exercise_card.dart`'s
/// `ExerciseCard`, trimmed to structure + planned values only: no
/// completion checkboxes, no "Прошлые результаты"/"Копировать показатели
/// прошлого выполнения" (those read from *workout* history, which
/// templates never have, D-16), no progression segment (there is nothing
/// to have progressed on a plan that was never performed).
class TemplateExerciseCard extends StatelessWidget {
  const TemplateExerciseCard({
    super.key,
    required this.details,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onWarmupChanged,
    required this.onAddSet,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onCommentChanged,
    required this.onCommentCommit,
  });

  final TemplateExerciseDetails details;

  /// This card's position in the exercise list -- required by
  /// [ReorderableDragStartListener] to identify the drag handle's item.
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final void Function(String setId, TemplateSetFieldSpec field, double? value)
  onFieldChanged;
  final void Function(String setId, TemplateSetFieldSpec field) onFieldCommit;
  final void Function(String setId, bool value) onWarmupChanged;
  final VoidCallback onAddSet;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onCommentCommit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fields = templateSetFieldsFor(details.exercise.exerciseType, l10n);

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
                // Hidden entirely rather than shown with an empty menu when
                // this is the only exercise (unlike `ExerciseCard`, whose
                // menu always has other, unconditional items).
                if (canMoveUp || canMoveDown)
                  PopupMenuButton<_TemplateExerciseCardAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _TemplateExerciseCardAction.moveUp:
                          onMoveUp();
                        case _TemplateExerciseCardAction.moveDown:
                          onMoveDown();
                      }
                    },
                    itemBuilder: (context) => [
                      if (canMoveUp)
                        PopupMenuItem(
                          value: _TemplateExerciseCardAction.moveUp,
                          child: Text(l10n.moveExerciseUpAction),
                        ),
                      if (canMoveDown)
                        PopupMenuItem(
                          value: _TemplateExerciseCardAction.moveDown,
                          child: Text(l10n.moveExerciseDownAction),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            for (final set in details.sets)
              TemplateSetRow(
                set: set,
                fields: fields,
                onFieldChanged: (field, value) =>
                    onFieldChanged(set.id, field, value),
                onFieldCommit: (field) => onFieldCommit(set.id, field),
                onWarmupChanged: (value) => onWarmupChanged(set.id, value),
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
              key: ValueKey(
                'template-exercise-comment-${details.templateExercise.id}',
              ),
              value: details.templateExercise.comment,
              label: l10n.exerciseCommentLabel,
              maxLength: CommentLengthLimits.workoutExercise,
              onChanged: onCommentChanged,
              onCommit: onCommentCommit,
            ),
          ],
        ),
      ),
    );
  }
}
