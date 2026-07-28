import 'package:flutter/material.dart';

import '../../../core/color_hex.dart';
import '../../../core/reference_data_ids.dart';
import '../../../domain/models/workout_tag.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/reference_data_labels.dart';

/// Parses a `#RRGGBB` tag color (06_DATA_MODEL.md, section 6.3) into a
/// `Color`. Tag colors always come from `workoutTagColorPalette`
/// (core/constants.dart), so no alpha channel to handle.
Color tagColor(String colorHex) => colorFromHex(colorHex);

/// Display label for a `WorkoutTag` (Stage 10, owner-confirmed): the
/// built-in muscle-group tags (`tag.id` matching a `muscleGroupIds` entry,
/// seeded by `data/seed/workout_tag_seed.dart`) translate with the app
/// language via the same lookup the exercise catalog's muscle-group
/// filters already use -- there's no separate "built-in" schema flag on
/// `WorkoutTag`, the id match *is* what makes it a built-in tag for display
/// purposes. User-created tags show their fixed `name` as typed
/// (owner-confirmed: no localization for those).
String workoutTagLabel(AppLocalizations l10n, WorkoutTag tag) {
  if (muscleGroupIds.contains(tag.id)) return muscleGroupLabel(l10n, tag.id);
  return tag.name;
}

/// A read-only display chip for a tag assigned to a workout (S-03 header
/// row) -- a color dot plus the tag name, no tap action of its own.
///
/// Hand-rolled instead of Material's `Chip` (Stage 10, TS 11.6 profiling,
/// 2026-07-28): on-device A/B measurement (scrolling a realistic, varied
/// workout history where 0-3 tag chips appear per row) showed the plain
/// `Chip` widget -- its `Material`/`InkWell`/animation-controller scaffolding
/// under the hood, even fully static and non-interactive -- was a real
/// contributor to raster jank; hiding tags roughly halved the miss rate.
/// This app's theme renders a plain `Chip` as border-only (no fill, no
/// elevation -- verified by inspecting the resolved `Material.color`,
/// which is `null`), so a plain bordered `Container` reproduces the same
/// look (border color = `colorScheme.outlineVariant`, text style =
/// `textTheme.labelLarge` tinted `onSurfaceVariant`, 8dp corner radius --
/// all read live from the theme, not hardcoded, so light/dark still match
/// automatically) without Chip's internal machinery.
class WorkoutTagChip extends StatelessWidget {
  const WorkoutTagChip({super.key, required this.tag});

  final WorkoutTag tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: tagColor(tag.colorHex)),
          ),
          const SizedBox(width: 8),
          Text(
            workoutTagLabel(l10n, tag),
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
