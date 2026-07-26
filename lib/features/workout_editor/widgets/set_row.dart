import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/widgets/expandable_set_row.dart';
import '../../../core/widgets/numeric_stepper_field.dart';
import '../../../domain/models/exercise_set.dart';
import '../../../l10n/app_localizations.dart';
import '../set_field_config.dart';

/// One row of the sets table (S-03, Stage 10 redesign): collapsed shows a
/// status-colored bar, the set number, a labelled plan summary, and one big
/// combined value ("82.5 × 8") -- the pre-redesign version showed plan and
/// fact as two identical unlabelled text boxes per field (AUDIT.md, section
/// 1.6: "план и факт визуально неразличимы"). Tapping the row expands
/// [NumericStepperField]s for every field the exercise type uses (DESIGN.md,
/// section 1: "тап... разворачивает степперы... для ввода или правки
/// факта"), pre-filled from the value it edits.
///
/// While [isActive] (the workout is `inProgress`) the steppers edit the
/// *actual* value and a checkbox toggles `isCompleted`, unchanged from
/// before -- still a real `Checkbox` (just restyled into a filled circle
/// via `shape`/`fillColor`), not a bespoke tap target, so nothing that
/// already exercised "the checkbox" needs to change what widget type it
/// looks for. Outside `inProgress` the steppers edit the *planned* value
/// and there's no checkbox at all (matches the mockup's draft/plan-only
/// rows -- marking a set "done" before the workout has even started isn't
/// a real state).
class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.fields,
    required this.isActive,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onCompletedChanged,
    required this.onDelete,
  });

  final ExerciseSet set;
  final List<SetFieldSpec> fields;
  final bool isActive;
  final void Function(SetFieldSpec field, bool actual, double? value)
  onFieldChanged;
  final void Function(SetFieldSpec field, bool actual) onFieldCommit;
  final ValueChanged<bool> onCompletedChanged;
  final VoidCallback onDelete;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  bool _expanded = false;

  void _updateField(SetFieldSpec field, double value) {
    widget.onFieldChanged(field, widget.isActive, value);
    widget.onFieldCommit(field, widget.isActive);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final set = widget.set;
    final isActive = widget.isActive;

    final planSummary = formatFieldsSummary(set, widget.fields, actual: false);
    final valueSummary = isActive
        ? formatFieldsSummary(set, widget.fields, actual: true)
        : planSummary;
    final hasValue = widget.fields.any(
      (field) =>
          (isActive ? field.getActual(set) : field.getPlanned(set)) != null,
    );

    final statusBarColor = !isActive
        ? scheme.outlineVariant
        : (set.isCompleted ? semantic.success : scheme.primary);

    return ExpandableSetRow(
      key: ValueKey('set-row-${set.id}'),
      setNumber: set.setNumber,
      planLabel: '${l10n.setColumnPlan} $planSummary',
      valueLabel: valueSummary,
      valueTextColor: hasValue ? null : scheme.onSurfaceVariant,
      statusBarColor: statusBarColor,
      expanded: _expanded,
      onToggleExpanded: () => setState(() => _expanded = !_expanded),
      trailing: isActive
          ? Transform.scale(
              // The mockup's completion circle reads much larger than
              // Checkbox's default ~18dp glyph (owner-reported, Stage 10
              // redesign on-device check). Scaling the whole widget grows
              // the painted circle within its existing ~48dp tap-target
              // box (no overflow, no change to the tap area itself), so
              // the type stays `Checkbox` and every existing
              // `find.byType(Checkbox)` test keeps working unchanged.
              scale: 1.8,
              child: Checkbox(
                value: set.isCompleted,
                onChanged: (value) =>
                    widget.onCompletedChanged(value ?? false),
                semanticLabel: l10n.setColumnDone,
                shape: const CircleBorder(),
                side: BorderSide(color: scheme.outline, width: 2),
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? semantic.success
                      : Colors.transparent,
                ),
                checkColor: semantic.onSuccess,
              ),
            )
          : null,
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
                  value:
                      (isActive
                          ? field.getActual(set) ?? field.getPlanned(set)
                          : field.getPlanned(set)) ??
                      0,
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
