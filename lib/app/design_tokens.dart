import 'package:flutter/material.dart';

import '../domain/enums.dart';

/// Semantic colors Material 3's seed-derived [ColorScheme] doesn't provide
/// on its own: an energetic accent (CTA buttons, rest timer) and a success
/// green (done checkmarks, positive deltas, the "completed" workout
/// status). "Skipped" and "cancelled" reuse [ColorScheme.tertiary] /
/// [ColorScheme.error] respectively -- distinct hues already exist there,
/// so a third and fourth custom family would just duplicate what the seed
/// already generates. Values are derived from the Stage 10 redesign
/// mockup's OKLCH palette, converted to sRGB; each `on*` color is chosen
/// for contrast against its own container in its own theme (the mockup's
/// dark-mode rest-timer text was too dark against its own container to be
/// legible -- not copied literally, see `onAccentContainer` below).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.accent,
    required this.onAccent,
    required this.accentContainer,
    required this.onAccentContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
  });

  final Color accent;
  final Color onAccent;
  final Color accentContainer;
  final Color onAccentContainer;

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  static const light = AppSemanticColors(
    accent: Color(0xFFE76C2B),
    onAccent: Color(0xFFFFFFFF),
    accentContainer: Color(0xFFFFDCC7),
    onAccentContainer: Color(0xFF541600),
    success: Color(0xFF2C974F),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFC9F1D0),
    onSuccessContainer: Color(0xFF00481B),
  );

  static const dark = AppSemanticColors(
    accent: Color(0xFFFA8C58),
    onAccent: Color(0xFF250F06),
    accentContainer: Color(0xFF3D2013),
    onAccentContainer: Color(0xFFFFD9BB),
    success: Color(0xFF62BB78),
    onSuccess: Color(0xFF0C1016),
    successContainer: Color(0xFF163825),
    onSuccessContainer: Color(0xFF8FE3A6),
  );

  @override
  AppSemanticColors copyWith({
    Color? accent,
    Color? onAccent,
    Color? accentContainer,
    Color? onAccentContainer,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
  }) {
    return AppSemanticColors(
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accentContainer: accentContainer ?? this.accentContainer,
      onAccentContainer: onAccentContainer ?? this.onAccentContainer,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accentContainer: Color.lerp(accentContainer, other.accentContainer, t)!,
      onAccentContainer: Color.lerp(
        onAccentContainer,
        other.onAccentContainer,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
    );
  }
}

/// A container/on-container/border triple for badging a [WorkoutStatus]
/// (status chips in History/Today, the workout editor's status row).
@immutable
class StatusColorSet {
  const StatusColorSet({
    required this.container,
    required this.onContainer,
    required this.border,
  });

  final Color container;
  final Color onContainer;
  final Color border;
}

/// Maps each of the 6 [WorkoutStatus] values (06_DATA_MODEL.md, section
/// 6.4.1) to a distinct color family, so status is readable at a glance
/// (Stage 10 redesign, AUDIT.md section 1.8: "no semantic color for the 6
/// statuses" was a named problem). `draft`/`planned` intentionally share
/// one neutral family -- neither is "in flight" yet, splitting them by
/// color would suggest a difference that isn't there.
StatusColorSet workoutStatusColors(BuildContext context, WorkoutStatus status) {
  final scheme = Theme.of(context).colorScheme;
  final semantic = Theme.of(context).extension<AppSemanticColors>()!;
  switch (status) {
    case WorkoutStatus.draft:
    case WorkoutStatus.planned:
      return StatusColorSet(
        container: scheme.surfaceContainerHighest,
        onContainer: scheme.onSurfaceVariant,
        border: scheme.outlineVariant,
      );
    case WorkoutStatus.inProgress:
      return StatusColorSet(
        container: scheme.primaryContainer,
        onContainer: scheme.onPrimaryContainer,
        border: scheme.primary,
      );
    case WorkoutStatus.completed:
      return StatusColorSet(
        container: semantic.successContainer,
        onContainer: semantic.onSuccessContainer,
        border: semantic.success,
      );
    case WorkoutStatus.skipped:
      return StatusColorSet(
        container: scheme.tertiaryContainer,
        onContainer: scheme.onTertiaryContainer,
        border: scheme.tertiary,
      );
    case WorkoutStatus.cancelled:
      return StatusColorSet(
        container: scheme.errorContainer,
        onContainer: scheme.onErrorContainer,
        border: scheme.error,
      );
  }
}

/// Spacing scale (AUDIT.md, section 2.3: no scale existed before Stage 10
/// -- ad hoc 4/8/12/16/24 literals scattered per-screen). Use these instead
/// of new numeric literals in redesigned widgets.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Corner-radius scale (AUDIT.md, section 2.3: same "no scale" gap as
/// spacing). `card` matches the redesign's exercise-card/rest-timer-card
/// roundness; `chip` is the pill shape used for tags/muscle-group labels.
class AppRadius {
  const AppRadius._();

  static const double control = 12;
  static const double button = 16;
  static const double card = 20;
  static const double chip = 20;
}

/// Text styles for the numbers users read at a glance mid-set -- timers,
/// tonnage, stepper values (DESIGN.md, section 1: "large numbers ... weight
/// 900, tabular figures, +5-10% larger than body text -- the only thing
/// that needs to read by peripheral vision between sets"). All read the
/// active [TextTheme] rather than hardcoding a font, so RU/EN and text-scale
/// settings (UX 9-12) still apply.
class AppNumberTextStyles {
  const AppNumberTextStyles._();

  static TextStyle timer(BuildContext context) {
    return _tabular(context, Theme.of(context).textTheme.headlineSmall);
  }

  /// A smaller sibling of [timer] for inline placements that must not
  /// dominate their surroundings -- the workout editor's AppBar timer chip
  /// (Stage 10 redesign, owner-reported: the old full-size timer took a
  /// whole row on its own).
  static TextStyle compactTimer(BuildContext context) {
    return _tabular(
      context,
      Theme.of(context).textTheme.titleMedium,
      weight: FontWeight.w700,
    );
  }

  static TextStyle stepperValue(BuildContext context) {
    return _tabular(context, Theme.of(context).textTheme.titleLarge);
  }

  static TextStyle heroStat(BuildContext context) {
    return _tabular(context, Theme.of(context).textTheme.headlineMedium);
  }

  static TextStyle setValue(BuildContext context) {
    return _tabular(
      context,
      Theme.of(context).textTheme.bodyLarge,
      weight: FontWeight.w800,
    );
  }

  static TextStyle _tabular(
    BuildContext context,
    TextStyle? base, {
    FontWeight weight = FontWeight.w900,
  }) {
    return (base ?? const TextStyle()).copyWith(
      fontWeight: weight,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1,
    );
  }
}
