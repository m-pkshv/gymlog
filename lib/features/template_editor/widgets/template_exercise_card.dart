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
///
/// Collapsible (Stage 10, owner-reported), mirroring `ExerciseCard` --
/// tapping the header (type icon + name) collapses everything below it
/// down to just the name. Same purely-local, non-persisted `_expanded`
/// state, preserved across incidental data reloads by this widget's key
/// (`templateExercise.id`) in the list above it.
class TemplateExerciseCard extends StatefulWidget {
  const TemplateExerciseCard({
    super.key,
    required this.details,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onAddSet,
    required this.onDuplicateLastSet,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onCommentChanged,
    required this.onCommentCommit,
    required this.onSetDeleted,
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
  final VoidCallback onAddSet;
  final VoidCallback onDuplicateLastSet;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onCommentCommit;
  final ValueChanged<String> onSetDeleted;

  @override
  State<TemplateExerciseCard> createState() => _TemplateExerciseCardState();
}

class _TemplateExerciseCardState extends State<TemplateExerciseCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final details = widget.details;
    final fields = templateSetFieldsFor(details.exercise.exerciseType, l10n);
    final canDuplicateLastSet =
        details.sets.isNotEmpty &&
        hasTemplatePlannedValues(details.sets.last, details.exercise.exerciseType);

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
                // Hidden entirely rather than shown with an empty menu when
                // this is the only exercise (unlike `ExerciseCard`, whose
                // menu always has other, unconditional items).
                if (widget.canMoveUp || widget.canMoveDown)
                  PopupMenuButton<_TemplateExerciseCardAction>(
                    onSelected: (action) {
                      switch (action) {
                        case _TemplateExerciseCardAction.moveUp:
                          widget.onMoveUp();
                        case _TemplateExerciseCardAction.moveDown:
                          widget.onMoveDown();
                      }
                    },
                    itemBuilder: (context) => [
                      if (widget.canMoveUp)
                        PopupMenuItem(
                          value: _TemplateExerciseCardAction.moveUp,
                          child: Text(l10n.moveExerciseUpAction),
                        ),
                      if (widget.canMoveDown)
                        PopupMenuItem(
                          value: _TemplateExerciseCardAction.moveDown,
                          child: Text(l10n.moveExerciseDownAction),
                        ),
                    ],
                  ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              for (final set in details.sets)
                TemplateSetRow(
                  set: set,
                  fields: fields,
                  onFieldChanged: (field, value) =>
                      widget.onFieldChanged(set.id, field, value),
                  onFieldCommit: (field) => widget.onFieldCommit(set.id, field),
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
                key: ValueKey(
                  'template-exercise-comment-${details.templateExercise.id}',
                ),
                value: details.templateExercise.comment,
                label: l10n.exerciseCommentLabel,
                maxLength: CommentLengthLimits.workoutExercise,
                onChanged: widget.onCommentChanged,
                onCommit: widget.onCommentCommit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
