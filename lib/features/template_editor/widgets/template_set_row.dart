import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/widgets/expandable_set_row.dart';
import '../../../core/widgets/numeric_stepper_field.dart';
import '../../../domain/models/template_set.dart';
import '../../../l10n/app_localizations.dart';
import '../template_set_field_config.dart';

/// One row of the template sets table (S-13, Stage 10 redesign) -- the
/// template counterpart of `workout_editor/widgets/set_row.dart`'s
/// `SetRow`, trimmed to a single plan column: no facts, no "✓" (templates
/// never carry facts, 06_DATA_MODEL.md section 6.8), so the status bar is
/// always the same neutral color `SetRow` uses for its own not-yet-started
/// (`!isActive`) case, and there's no `trailing` checkbox. Collapsed shows
/// one combined plan value ("80 × 8"); tapping expands
/// [NumericStepperField]s for every field the exercise type uses, same as
/// the workout editor's row.
class TemplateSetRow extends StatefulWidget {
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
  State<TemplateSetRow> createState() => _TemplateSetRowState();
}

class _TemplateSetRowState extends State<TemplateSetRow> {
  // Stage 12, owner-reported: mirrors `SetRow`'s same fix -- a brand-new
  // set starts expanded (one fewer tap to see the steppers), a duplicated
  // one (already carrying a copied planned value) starts collapsed.
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    final hasValue = widget.fields.any(
      (field) => field.getPlanned(widget.set) != null,
    );
    _expanded = !hasValue;
  }

  void _updateField(TemplateSetFieldSpec field, double value) {
    widget.onFieldChanged(field, value);
    widget.onFieldCommit(field);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final set = widget.set;

    final planSummary = formatTemplateFieldsSummary(set, widget.fields);
    final hasValue = widget.fields.any(
      (field) => field.getPlanned(set) != null,
    );

    return ExpandableSetRow(
      key: ValueKey('template-set-row-${set.id}'),
      setNumber: set.setNumber,
      planLabel: l10n.setColumnPlan,
      valueLabel: planSummary,
      valueTextColor: hasValue ? null : scheme.onSurfaceVariant,
      statusBarColor: scheme.outlineVariant,
      expanded: _expanded,
      onToggleExpanded: () => setState(() => _expanded = !_expanded),
      expandedChild: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            for (final field in widget.fields)
              SizedBox(
                width: 150,
                child: NumericStepperField(
                  label: field.label,
                  value: field.getPlanned(set) ?? 0,
                  step: field.step,
                  decimals: field.decimals,
                  min: field.min,
                  max: field.max,
                  onChanged: (value) => _updateField(field, value),
                ),
              ),
          ],
        ),
      ),
      onDelete: widget.onDelete,
    );
  }
}
