import 'package:flutter/material.dart';

import '../../../domain/models/exercise_set.dart';
import '../../../l10n/app_localizations.dart';
import '../set_field_config.dart';
import 'set_number_field.dart';

/// One row of the sets table (S-03): set number, warm-up toggle, plan/fact
/// fields for the exercise's type, and the "✓" completion checkbox that
/// copies plan into empty facts (DM 6.7).
class SetRow extends StatelessWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.fields,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onWarmupChanged,
    required this.onCompletedChanged,
  });

  final ExerciseSet set;
  final List<SetFieldSpec> fields;
  final void Function(SetFieldSpec field, bool actual, double? value)
  onFieldChanged;
  final void Function(SetFieldSpec field, bool actual) onFieldCommit;
  final ValueChanged<bool> onWarmupChanged;
  final ValueChanged<bool> onCompletedChanged;

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
          SizedBox(
            width: 48,
            height: 48,
            child: Checkbox(
              value: set.isWarmup,
              onChanged: (value) => onWarmupChanged(value ?? false),
              semanticLabel: l10n.setColumnWarmup,
            ),
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
