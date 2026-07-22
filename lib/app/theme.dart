import 'package:flutter/material.dart';

import '../domain/enums.dart';

/// Seed color for `ColorScheme.fromSeed` (04_UI_UX_SPEC.md, section 9,
/// UX-1 — confirmed by the owner at Stage 9, no change).
const Color seedColor = Color(0xFF4C7BD9);

/// Maps the domain [AppTheme] setting (Flutter-free, so the settings layer
/// stays testable without `package:flutter`) to Flutter's own `ThemeMode`,
/// which `MaterialApp.router` actually consumes.
ThemeMode flutterThemeMode(AppTheme theme) {
  switch (theme) {
    case AppTheme.system:
      return ThemeMode.system;
    case AppTheme.light:
      return ThemeMode.light;
    case AppTheme.dark:
      return ThemeMode.dark;
  }
}

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
