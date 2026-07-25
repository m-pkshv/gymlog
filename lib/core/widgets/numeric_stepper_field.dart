import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../core/units/unit_converter.dart';
import '../../l10n/app_localizations.dart';

const _unitConverter = UnitConverter();

/// A "−  value  +" stepper (Stage 10 redesign, DESIGN.md section 1: replaces
/// the plain [SetNumberField] text box for weight/reps entry). Tapping the
/// big value opens a precise keyboard-entry dialog -- the mockup only shows
/// the steppers, but reaching a value like 82.5 kg from 80 one tap at a time
/// would be tedious, so this keeps the visual language while still letting
/// a user type an exact number.
class NumericStepperField extends StatelessWidget {
  const NumericStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.decimals = 0,
    this.min = 0,
    this.max,
    this.semanticLabel,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final int decimals;
  final double min;
  final double? max;
  final String? semanticLabel;

  String get _display => decimals == 0
      ? value.round().toString()
      : value.toStringAsFixed(decimals);

  double _clamp(double v) {
    final lowered = v < min ? min : v;
    return (max != null && lowered > max!) ? max! : lowered;
  }

  Future<void> _openPreciseEntry(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: _display);
    final entered = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.numberWithOptions(
            decimal: decimals > 0,
          ),
          onSubmitted: (text) => Navigator.pop(
            dialogContext,
            _unitConverter.parseDecimal(text),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              _unitConverter.parseDecimal(controller.text),
            ),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    if (entered != null) onChanged(_clamp(entered));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  semanticLabel: l10n.stepperDecreaseTooltip(label),
                  onPressed: () => onChanged(_clamp(value - step)),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                    onTap: () => _openPreciseEntry(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Center(
                        child: Semantics(
                          label: semanticLabel,
                          value: _display,
                          child: Text(
                            _display,
                            style: AppNumberTextStyles.stepperValue(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  filled: true,
                  semanticLabel: l10n.stepperIncreaseTooltip(label),
                  onPressed: () => onChanged(_clamp(value + step)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: filled
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          foregroundColor: filled ? scheme.onPrimary : scheme.onSurface,
        ),
        icon: Icon(icon, size: 16),
      ),
    );
  }
}
