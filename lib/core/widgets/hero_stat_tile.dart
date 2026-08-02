import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// A big-number-first metric tile (Stage 10 redesign, AUDIT.md sections 1.4
/// & 1.7: "ключевые числа... визуально не выделены" on both the workout
/// summary and stats screens -- same size as their labels). Formalizes the
/// ad hoc `_StatTile` in `workout_summary/screen.dart` into a shared
/// widget so Phase 2 can reuse it on both screens without duplicating the
/// "hero number" text style. [icon] is optional -- the stats screen's
/// mockup shows plain number+label tiles with no icon at all.
///
/// [value] is forced onto a single line, shrinking its font (not wrapping
/// or clipping) if it doesn't fit at the normal hero size (Stage: design/
/// redesign_v2, owner-reported: a long value -- e.g. a workout with a
/// title long enough to force wrapping, or a large tonnage figure -- used
/// to make its tile taller than its neighbors in a row of equal-width
/// tiles).
class HeroStatTile extends StatelessWidget {
  const HeroStatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.valueColor,
    this.iconColor,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? valueColor;

  /// Defaults to [ColorScheme.primary] -- overridable for tiles placed on a
  /// non-default background (e.g. an accent-tinted card), where the default
  /// primary-blue icon would clash.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? scheme.primary),
          const SizedBox(height: AppSpacing.xs),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppNumberTextStyles.heroStat(
              context,
            ).copyWith(color: valueColor ?? scheme.primary),
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
