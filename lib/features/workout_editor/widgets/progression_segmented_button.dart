import 'package:flutter/material.dart';

import '../../../domain/enums.dart';
import '../../../l10n/app_localizations.dart';

/// The progression-decision segment (—/↑/=/↓, DM 6.11 "ручная отметка"),
/// shared between `ExerciseCard` (S-03) and the workout summary screen
/// (S-05, "решения прогрессии по упражнениям (можно проставить здесь)") --
/// both edit the same `WorkoutExercise.progressionDecision` field through
/// `WorkoutEditorController.setProgressionDecision`.
class ProgressionSegmentedButton extends StatelessWidget {
  const ProgressionSegmentedButton({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ProgressionDecision selected;
  final ValueChanged<ProgressionDecision> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<ProgressionDecision>(
      segments: [
        ButtonSegment(
          value: ProgressionDecision.none,
          label: Text(l10n.progressionDecisionNone),
        ),
        ButtonSegment(
          value: ProgressionDecision.increase,
          label: Text(l10n.progressionDecisionIncrease),
        ),
        ButtonSegment(
          value: ProgressionDecision.repeat,
          label: Text(l10n.progressionDecisionRepeat),
        ),
        ButtonSegment(
          value: ProgressionDecision.decrease,
          label: Text(l10n.progressionDecisionDecrease),
        ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (selected) => onChanged(selected.first),
    );
  }
}
