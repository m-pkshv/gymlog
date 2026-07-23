import 'package:flutter/material.dart';

import '../../../core/reference_data_ids.dart';
import '../../../domain/models/workout_tag.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/reference_data_labels.dart';

/// Parses a `#RRGGBB` tag color (06_DATA_MODEL.md, section 6.3) into a
/// `Color`. Tag colors always come from `workoutTagColorPalette`
/// (core/constants.dart), so no alpha channel to handle.
Color tagColor(String colorHex) {
  final value = int.parse(colorHex.substring(1), radix: 16);
  return Color(0xFF000000 | value);
}

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
/// row) — a color dot plus the tag name, no tap action of its own.
class WorkoutTagChip extends StatelessWidget {
  const WorkoutTagChip({super.key, required this.tag});

  final WorkoutTag tag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Chip(
      avatar: CircleAvatar(backgroundColor: tagColor(tag.colorHex), radius: 6),
      label: Text(workoutTagLabel(l10n, tag)),
      visualDensity: VisualDensity.compact,
    );
  }
}
