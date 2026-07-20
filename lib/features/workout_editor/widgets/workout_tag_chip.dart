import 'package:flutter/material.dart';

import '../../../domain/models/workout_tag.dart';

/// Parses a `#RRGGBB` tag color (06_DATA_MODEL.md, section 6.3) into a
/// `Color`. Tag colors always come from `workoutTagColorPalette`
/// (core/constants.dart), so no alpha channel to handle.
Color tagColor(String colorHex) {
  final value = int.parse(colorHex.substring(1), radix: 16);
  return Color(0xFF000000 | value);
}

/// A read-only display chip for a tag assigned to a workout (S-03 header
/// row) — a color dot plus the tag name, no tap action of its own.
class WorkoutTagChip extends StatelessWidget {
  const WorkoutTagChip({super.key, required this.tag});

  final WorkoutTag tag;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: tagColor(tag.colorHex), radius: 6),
      label: Text(tag.name),
      visualDensity: VisualDensity.compact,
    );
  }
}
