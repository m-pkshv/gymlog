import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../domain/models/exercise_set.dart';
import '../../../l10n/app_localizations.dart';
import '../set_field_config.dart';
import 'set_number_field.dart';

/// One row of the sets table (S-03): set number, plan/fact fields for the
/// exercise's type, the "✓" completion checkbox that copies plan into
/// empty facts (DM 6.7), and a comment action (dialog — DM 6.7 caps it at
/// 500 chars, too long to keep inline in this already-dense row).
class SetRow extends StatelessWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.fields,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onCompletedChanged,
    required this.onCommentSaved,
  });

  final ExerciseSet set;
  final List<SetFieldSpec> fields;
  final void Function(SetFieldSpec field, bool actual, double? value)
  onFieldChanged;
  final void Function(SetFieldSpec field, bool actual) onFieldCommit;
  final ValueChanged<bool> onCompletedChanged;
  final ValueChanged<String> onCommentSaved;

  Future<void> _editComment(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: set.comment ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.setCommentTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          maxLength: CommentLengthLimits.exerciseSet,
          decoration: InputDecoration(labelText: l10n.setCommentLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (result != null) onCommentSaved(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasComment = (set.comment ?? '').isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            child: Text('${set.setNumber}', textAlign: TextAlign.center),
          ),
          Expanded(
            child: Column(
              children: [
                for (final field in fields)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 76,
                          child: Text(
                            field.label,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                        Expanded(
                          child: SetNumberField(
                            value: field.getPlanned(set),
                            decimals: field.decimals,
                            semanticLabel: '${field.label} ${l10n.setColumnPlan}',
                            onChanged: (value) =>
                                onFieldChanged(field, false, value),
                            onCommit: () => onFieldCommit(field, false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SetNumberField(
                            value: field.getActual(set),
                            decimals: field.decimals,
                            semanticLabel: '${field.label} ${l10n.setColumnFact}',
                            onChanged: (value) =>
                                onFieldChanged(field, true, value),
                            onCommit: () => onFieldCommit(field, true),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 36,
            height: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                hasComment ? Icons.comment : Icons.comment_outlined,
                size: 18,
              ),
              tooltip: l10n.setCommentAction,
              onPressed: () => _editComment(context),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Checkbox(
              value: set.isCompleted,
              onChanged: (value) => onCompletedChanged(value ?? false),
              semanticLabel: l10n.setColumnDone,
            ),
          ),
        ],
      ),
    );
  }
}
