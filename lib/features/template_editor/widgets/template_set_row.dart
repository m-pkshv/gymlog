import 'package:flutter/material.dart';

import '../../../domain/models/template_set.dart';
import '../../../l10n/app_localizations.dart';
import '../../workout_editor/widgets/set_number_field.dart';
import '../template_set_field_config.dart';

/// One row of the template sets table (S-13) -- the template counterpart
/// of `workout_editor/widgets/set_row.dart`'s `SetRow`, trimmed to a single
/// plan column: no facts, no "✓" (templates never carry facts,
/// 06_DATA_MODEL.md section 6.8), and no comment button
/// (`TemplateSet` has no comment field in the schema).
class TemplateSetRow extends StatelessWidget {
  const TemplateSetRow({
    super.key,
    required this.set,
    required this.fields,
    required this.onFieldChanged,
    required this.onFieldCommit,
  });

  final TemplateSet set;
  final List<TemplateSetFieldSpec> fields;
  final void Function(TemplateSetFieldSpec field, double? value)
  onFieldChanged;
  final void Function(TemplateSetFieldSpec field) onFieldCommit;

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
        ],
      ),
    );
  }
}
