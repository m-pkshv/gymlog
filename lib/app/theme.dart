import 'package:flutter/material.dart';

/// Seed color for `ColorScheme.fromSeed` (04_UI_UX_SPEC.md, section 9,
/// UX-1 — accepted as a default, the owner may replace it before Stage 9).
const Color seedColor = Color(0xFF4C7BD9);

/// Light theme derived from [seedColor]. Colors must always be read from
/// `Theme.of(context).colorScheme` in widgets, never hardcoded (UX 9).
ThemeData buildLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    useMaterial3: true,
  );
}

/// Dark theme derived from the same [seedColor] (UX 9: light/dark share one
/// seed).
ThemeData buildDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
