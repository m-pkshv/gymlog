import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// Fill-or-outline circle for "this set is done" (S-03's set row). A stock
/// [Checkbox] can't be tuned this way -- Material's own check glyph nearly
/// fills its box, and there's no API to shrink just the glyph independent
/// of the circle around it (owner-reported, Stage 10 redesign: the mockup's
/// checkmark reads noticeably smaller relative to its circle than
/// `Checkbox`'s default, even after scaling the whole checkbox up to match
/// the circle's size). Draws the circle and the check icon as two
/// independently-sized pieces instead of relying on Checkbox's painter.
class CompletionToggle extends StatelessWidget {
  const CompletionToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  /// Matches the circle size the owner confirmed against the mockup
  /// (Checkbox's ~18dp glyph scaled 1.8x).
  static const double _diameter = AppSpacing.xxl;
  static const double _tapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      button: true,
      onTap: () => onChanged(!value),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          excludeFromSemantics: true,
          onTap: () => onChanged(!value),
          child: SizedBox(
            width: _tapTarget,
            height: _tapTarget,
            child: Center(
              child: Container(
                width: _diameter,
                height: _diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? semantic.success : Colors.transparent,
                  border: Border.all(
                    color: value ? semantic.success : scheme.outline,
                    width: 2,
                  ),
                ),
                child: value
                    ? Icon(Icons.check, size: 16, color: semantic.onSuccess)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
