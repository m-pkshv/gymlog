import 'package:flutter/material.dart';

import '../domain/enums.dart';
import 'design_tokens.dart';

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

/// Material 3's `AppBar` switches its background between two distinct
/// [ColorScheme] roles -- `surface` normally, `surfaceContainer` once
/// scrollable content has passed underneath it -- rather than blending a
/// tint by elevation (owner-reported, Stage 10 redesign, on-device check:
/// the workout editor's header visibly darkening while scrolling the sets
/// list read as a bug, not an elevation cue). `scrolledUnderElevation: 0`
/// and `surfaceTintColor: Colors.transparent` alone do *not* stop this --
/// verified by sampling the rendered pixels on-device before/after
/// scrolling: still `#FAF8FF` (= `surface`) vs `#EEEDF4` (=
/// `surfaceContainer`) either way, because that swap is driven by whether
/// content is scrolled under at all, not by the elevation value. Pinning
/// `backgroundColor` explicitly is what actually short-circuits it.
/// Applies app-wide (every screen has this same AppBar+scrollable-body
/// shape), not just the one screen it was first noticed on.
AppBarTheme _appBarTheme(ColorScheme colorScheme) {
  return AppBarTheme(
    backgroundColor: colorScheme.surface,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
  );
}

/// Light theme derived from [seedColor]. Colors must always be read from
/// `Theme.of(context).colorScheme` in widgets, never hardcoded (UX 9).
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: _appBarTheme(colorScheme),
    extensions: const [AppSemanticColors.light],
  );
}

/// Dark theme derived from the same [seedColor] (UX 9: light/dark share one
/// seed).
ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: _appBarTheme(colorScheme),
    extensions: const [AppSemanticColors.dark],
  );
}
