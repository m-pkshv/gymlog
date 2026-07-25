import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` hex string into a [Color]. Shared by every place in
/// the app that reads a color out of `workoutTagColorPalette`
/// (`core/constants.dart`) -- tag chips, tag swatches, and (Stage 10
/// redesign) the exercise catalog's muscle-group color coding.
Color colorFromHex(String hex) {
  final value = int.parse(hex.substring(1), radix: 16);
  return Color(0xFF000000 | value);
}
