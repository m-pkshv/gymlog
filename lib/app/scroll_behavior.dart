import 'package:flutter/material.dart';

/// Replaces Android's Material 3 stretch overscroll effect
/// (`StretchingOverscrollIndicator`) with the older, much cheaper
/// glow/ripple effect (`GlowingOverscrollIndicator`).
///
/// Found while profiling frame jank (Stage 10, TS 11.6): the stretch effect
/// composites an `ImageFilter` transform over the whole scrolled viewport on
/// every frame while overscrolling, and a `fling` gesture naturally passes
/// through overscroll at the start/end of a list. That was measurably the
/// single largest driver of rasterizer-thread jank found in on-device
/// profiling — see the profiling note in `03_TECHNICAL_SPEC.md`, section
/// 11.6, for the before/after numbers.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.secondary,
          child: child,
        );
    }
  }
}
