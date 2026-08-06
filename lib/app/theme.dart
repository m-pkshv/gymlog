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

/// Rounded rectangle, not Material 3's default stadium (fully-rounded-ends)
/// button shape (owner-reported, Stage 10 redesign, mockup screenshot).
/// Started as a per-widget `style: ...styleFrom(shape: ...)` override on a
/// handful of buttons (Today's quick actions, the workout editor's status
/// CTA); the owner then asked for it app-wide, so it moved here once --
/// every `FilledButton`/`ElevatedButton`/`OutlinedButton`/`TextButton` gets
/// it automatically, including ones added later, instead of relying on
/// every new button remembering to opt in individually. Deliberately not
/// applied to `IconButton` -- circular icon buttons (AppBar actions, the
/// "..." overflow menu, etc.) are standard, expected Material shapes the
/// owner never flagged, unlike the labeled action buttons this was
/// actually reported against.
final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppRadius.button),
);

/// Darkens a filled button's own color for its pressed state (owner-
/// supplied mockup, "Нажатые состояния": a solid, noticeably darker fill,
/// not Material's default faint ripple overlay). A flat 18% black blend
/// reads as "the same color, one shade deeper" for both the blue primary
/// button and the orange accent/timer button without needing a second,
/// hand-picked color per button.
Color _darkenForPress(Color color) {
  return Color.alphaBlend(Colors.black.withValues(alpha: 0.18), color);
}

/// A filled button's `backgroundColor`, darkened on press (see
/// [_darkenForPress]). Setting `backgroundColor` at all on a
/// `ButtonStyle` replaces Material's own per-state resolution wholesale
/// (there's no partial fallback to the button's defaults for states this
/// property doesn't mention), so the disabled state is replicated here
/// too, matching Material 3's own default disabled treatment
/// (`onSurface` at 12% opacity) rather than accidentally losing it.
WidgetStateProperty<Color?> _pressableFilledBackground(
  Color base,
  ColorScheme colorScheme,
) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      return colorScheme.onSurface.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.pressed)) {
      return _darkenForPress(base);
    }
    return base;
  });
}

/// An outlined ("Вторичная") button's `backgroundColor`: transparent at
/// rest (matching Material 3's own default, so this is a no-op change
/// there), a light, translucent tint of [ColorScheme.primary] while
/// pressed (owner-supplied mockup: a filled pale-blue pill, not just a
/// ripple).
WidgetStateProperty<Color?> _pressableOutlinedBackground(
  ColorScheme colorScheme,
) {
  return WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) {
      return colorScheme.primary.withValues(alpha: 0.12);
    }
    return Colors.transparent;
  });
}

/// Shared style for the accent-colored ("Таймер / акцент") filled CTA
/// buttons -- finishing a workout, restoring a backup -- so both share
/// the same pressed-state darkening ([_darkenForPress]) instead of each
/// call site re-deriving its own flat, unpressable accent color.
ButtonStyle accentFilledButtonStyle(
  BuildContext context, {
  EdgeInsetsGeometry? padding,
}) {
  final semantic = Theme.of(context).extension<AppSemanticColors>()!;
  return FilledButton.styleFrom(padding: padding).copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return _darkenForPress(semantic.accent);
      }
      return semantic.accent;
    }),
    foregroundColor: WidgetStatePropertyAll(semantic.onAccent),
  );
}

/// Light theme derived from [seedColor]. Colors must always be read from
/// `Theme.of(context).colorScheme` in widgets, never hardcoded (UX 9).
///
/// Memoized: `ColorScheme.fromSeed` does real perceptual color-space (HCT)
/// math, not a free constant lookup, and this used to run again on every
/// `GymLogApp` rebuild — which `appSettingsProvider` triggers on *any*
/// settings field changing (no `==` override on the `AppSettings` domain
/// model, so a new row for e.g. the rest-timer default is just as much a
/// "changed" value to Riverpod as an actual theme change), not only
/// theme/locale ones. The seed color and brightness never change while the
/// app is running, so caching the result is unconditionally safe.
ThemeData? _lightTheme;
ThemeData buildLightTheme() => _lightTheme ??= _buildLightTheme();

ThemeData _buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(seedColor: seedColor);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: _appBarTheme(colorScheme),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: _buttonShape).copyWith(
        backgroundColor: _pressableFilledBackground(
          colorScheme.primary,
          colorScheme,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: _buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: _buttonShape).copyWith(
        backgroundColor: _pressableOutlinedBackground(colorScheme),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: _buttonShape),
    ),
    extensions: const [AppSemanticColors.light],
  );
}

/// Dark theme derived from the same [seedColor] (UX 9: light/dark share one
/// seed). Memoized for the same reason as [buildLightTheme].
ThemeData? _darkTheme;
ThemeData buildDarkTheme() => _darkTheme ??= _buildDarkTheme();

ThemeData _buildDarkTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: _appBarTheme(colorScheme),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: _buttonShape).copyWith(
        backgroundColor: _pressableFilledBackground(
          colorScheme.primary,
          colorScheme,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: _buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: _buttonShape).copyWith(
        backgroundColor: _pressableOutlinedBackground(colorScheme),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: _buttonShape),
    ),
    extensions: const [AppSemanticColors.dark],
  );
}
