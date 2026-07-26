import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../domain/enums.dart';
import '../../../l10n/app_localizations.dart';

/// The progression-decision segment (—/↑/=/↓, DM 6.11 "ручная отметка"),
/// shared between `ExerciseCard` (S-03) and the workout summary screen
/// (S-05, "решения прогрессии по упражнениям (можно проставить здесь)") --
/// both edit the same `WorkoutExercise.progressionDecision` field through
/// `WorkoutEditorController.setProgressionDecision`.
///
/// A hand-built pill-track control instead of Material's stock
/// `SegmentedButton` (Stage 10 redesign, owner-reported: the stock
/// widget's bordered-box segments and pale tinted selection didn't match
/// the mockup's floating solid-color pill on a soft neutral track).
/// Requires a bounded incoming width (the `Row` of `Expanded` segments
/// needs one) -- callers with a `Row` sibling must wrap this in `Expanded`
/// themselves, same as `ExerciseCard` does.
class ProgressionSegmentedButton extends StatelessWidget {
  const ProgressionSegmentedButton({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProgressionDecision selected;
  final ValueChanged<ProgressionDecision> onChanged;

  static const _segments = [
    ProgressionDecision.none,
    ProgressionDecision.increase,
    ProgressionDecision.repeat,
    ProgressionDecision.decrease,
  ];

  static String _label(AppLocalizations l10n, ProgressionDecision value) {
    switch (value) {
      case ProgressionDecision.none:
        return l10n.progressionDecisionNone;
      case ProgressionDecision.increase:
        return l10n.progressionDecisionIncrease;
      case ProgressionDecision.repeat:
        return l10n.progressionDecisionRepeat;
      case ProgressionDecision.decrease:
        return l10n.progressionDecisionDecrease;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final value in _segments)
            Expanded(
              child: _ProgressionSegment(
                label: _label(l10n, value),
                isSelected: value == selected,
                onTap: () => onChanged(value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressionSegment extends StatelessWidget {
  const _ProgressionSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static final _radius = BorderRadius.circular(AppRadius.control - 3);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: _radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? scheme.primary : Colors.transparent,
            borderRadius: _radius,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
