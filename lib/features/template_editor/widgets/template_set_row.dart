import 'package:flutter/material.dart';

import '../../../domain/models/template_set.dart';
import '../../../l10n/app_localizations.dart';
import '../../workout_editor/widgets/set_number_field.dart';
import '../template_set_field_config.dart';

/// One row of the template sets table (S-13) -- the template counterpart
/// of `workout_editor/widgets/set_row.dart`'s `SetRow`, trimmed to a single
/// plan column: no facts, no "✓" (templates never carry facts,
/// 06_DATA_MODEL.md section 6.8). A delete-set action was added alongside
/// the workout editor's (Stage 10, owner-reported) even though there was
/// no comment button here to make room for -- the same "no way to remove a
/// planned set" gap existed in this screen too.
class TemplateSetRow extends StatelessWidget {
  const TemplateSetRow({
    super.key,
    required this.set,
    required this.fields,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onDelete,
  });

  final TemplateSet set;
  final List<TemplateSetFieldSpec> fields;
  final void Function(TemplateSetFieldSpec field, double? value)
  onFieldChanged;
  final void Function(TemplateSetFieldSpec field) onFieldCommit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                            semanticLabel:
                                '${field.label} ${l10n.setColumnPlan}',
                            onChanged: (value) => onFieldChanged(field, value),
                            onCommit: () => onFieldCommit(field),
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
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: l10n.deleteSetAction,
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}
