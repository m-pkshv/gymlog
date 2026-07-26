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
/// the mockup's square segments on a soft neutral track). Compact by
/// design -- each segment is a fixed-size square, and the track shrink-
/// wraps to them (`mainAxisSize.min`), it does *not* stretch to fill
/// whatever width its parent offers (owner-reported: an earlier version
/// stretched the whole control across the row, which doesn't match the
/// mockup either).
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.control),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in _segments)
            _ProgressionSegment(
              label: _label(l10n, value),
              isSelected: value == selected,
              onTap: () => onChanged(value),
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

  static const _size = 34.0;
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
          width: _size,
          height: _size,
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
