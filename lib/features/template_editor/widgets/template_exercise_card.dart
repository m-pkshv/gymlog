import 'package:flutter/material.dart';

import '../../../domain/models/template_details.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/exercise_type_labels.dart';
import '../template_set_field_config.dart';
import 'template_set_row.dart';

enum _TemplateExerciseCardAction {
  moveUp,
  moveDown,
  editExercise,
  deleteExercise,
}

/// Card for one exercise entry in the template editor (S-13) -- the
/// template counterpart of `workout_editor/widgets/exercise_card.dart`'s
/// `ExerciseCard`, trimmed to structure + planned values only: no
/// completion checkboxes, no "Прошлые результаты"/"Копировать показатели
/// прошлого выполнения" (those read from *workout* history, which
/// templates never have, D-16), no progression segment (there is nothing
/// to have progressed on a plan that was never performed). Reorder is
/// "⋮ → Вверх/Вниз" only (owner-reported, Stage 10: the drag handle this
/// used to have alongside the menu was removed, mirroring `ExerciseCard`).
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
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onAddSet,
    required this.onDuplicateLastSet,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onSetDeleted,
    required this.onEditExercise,
    required this.onDeleteExercise,
  });

  final TemplateExerciseDetails details;
  final bool canMoveUp;
  final bool canMoveDown;
  final void Function(String setId, TemplateSetFieldSpec field, double? value)
  onFieldChanged;
  final void Function(String setId, TemplateSetFieldSpec field) onFieldCommit;
  final VoidCallback onAddSet;
  final VoidCallback onDuplicateLastSet;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<String> onSetDeleted;
  final VoidCallback onEditExercise;
  final VoidCallback onDeleteExercise;

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
                // Owner-reported (Stage 10): "Delete exercise" is always
                // available, so the menu is no longer hidden even when
                // move up/down are both unavailable (single-exercise
                // template) -- unlike before, when it had only those two
                // conditional entries and nothing else to show.
                PopupMenuButton<_TemplateExerciseCardAction>(
                  onSelected: (action) {
                    switch (action) {
                      case _TemplateExerciseCardAction.moveUp:
                        widget.onMoveUp();
                      case _TemplateExerciseCardAction.moveDown:
                        widget.onMoveDown();
                      case _TemplateExerciseCardAction.editExercise:
                        widget.onEditExercise();
                      case _TemplateExerciseCardAction.deleteExercise:
                        widget.onDeleteExercise();
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
                    // DM 10: only a user-created exercise may be edited.
                    if (!details.exercise.isBuiltIn)
                      PopupMenuItem(
                        value: _TemplateExerciseCardAction.editExercise,
                        child: Text(l10n.editWorkoutExerciseAction),
                      ),
                    PopupMenuItem(
                      value: _TemplateExerciseCardAction.deleteExercise,
                      child: Text(l10n.removeExerciseAction),
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
            ],
          ],
        ),
      ),
    );
  }
}
