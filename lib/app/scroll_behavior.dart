import 'package:flutter/material.dart';

/// Disables Android's overscroll indicator entirely — no stretch, no glow,
/// nothing — when a scrollable is dragged past its start/end.
///
/// Found while profiling frame jank (Stage 10, TS 11.6): Material 3's
/// default `StretchingOverscrollIndicator` composites an `ImageFilter`
/// transform over the whole scrolled viewport on every frame while
/// overscrolling, and a `fling` gesture naturally passes through overscroll
/// at the start/end of a list. That was measurably the single largest
/// driver of rasterizer-thread jank found in on-device profiling of the
/// workout editor's exercise list (missed the 16 ms raster budget on up to
/// ~20% of frames while flinging). Swapping to the cheaper
/// `GlowingOverscrollIndicator` (Material 2's default) roughly halved that,
/// but on-device A/B measurement showed dropping the indicator altogether
/// brought it down to ~0%, with no further measurable win from keeping
/// some indicator — see the profiling note in `03_TECHNICAL_SPEC.md`,
/// section 11.6, for the before/after numbers.
///
/// Owner-confirmed trade-off (2026-07-28): Android's default scroll physics
/// here (`ClampingScrollPhysics`) doesn't rubber-band on its own — the
/// indicator was the *only* visual feedback for hitting the edge of a
/// list, so removing it means dragging past the top/bottom of any list
/// anywhere in the app now shows no reaction at all, instead of a
/// stretch/glow. The owner tried this build on-device and chose it over
/// keeping glow.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
