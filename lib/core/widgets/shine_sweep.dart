import 'dart:async';

import 'package:flutter/material.dart';

/// A short, one-shot diagonal "shine" that sweeps once across [child] and
/// disappears (owner-reported: the trophy badge on the workout summary's
/// "Новые рекорды" header, `workout_summary/screen.dart`'s
/// `_NewRecordsSection`) -- plays once, [delay] after first build, the
/// same "no repeat" choice already made for `ConfettiOverlay` on this same
/// screen, not a looping shimmer. [delay] exists so a caller can stagger
/// this relative to some *other* one-shot animation (owner-reported: this
/// screen's own confetti burst) without this widget needing to know
/// anything about that other animation.
///
/// [ShaderMask] with [BlendMode.srcATop], not a separately-clipped overlay
/// painted on top: the gradient only lightens pixels where [child] is
/// already opaque (`srcATop`'s own blend formula factors in the
/// destination's alpha), so the sweep is automatically clipped to
/// whatever shape [child] actually draws -- a circular badge here, but
/// nothing here assumes that shape specifically.
class ShineSweep extends StatefulWidget {
  const ShineSweep({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;

  /// How long to wait, after this widget first builds, before the sweep
  /// starts. `Duration.zero` starts immediately.
  final Duration delay;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 900);

  late final AnimationController _controller;
  Timer? _delayTimer;
  bool _started = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _finished = true);
        }
      });
    // A cancellable `Timer`, not `Future.delayed` -- same reason every
    // other delayed/debounced action in this app uses one (e.g.
    // `WorkoutEditorController`'s autosave debounce timers): a bare
    // `Future.delayed` callback still fires even after this widget is
    // gone, and in a widget test specifically, flutter_test's teardown
    // asserts no `Timer` is left pending -- `dispose` below needs
    // something it can actually cancel.
    _delayTimer = Timer(widget.delay, () {
      if (!mounted) return;
      setState(() => _started = true);
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Before the delay elapses, and once the sweep is done, paint the
    // plain child -- no (no-op) ShaderMask sitting around either before
    // it has anything to show or after it's finished.
    if (!_started || _finished) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Owner-reported: the first version looked "грязным" (muddy) --
    // Gradient was fading toward `Colors.transparent`, whose RGB is
    // BLACK (0,0,0) even at alpha 0. Linearly interpolating "transparent
    // black" into white produces visibly gray/brown intermediate colors
    // along the fade (a well-known Flutter/Skia gotcha), not a clean
    // fade to nothing. Fading toward the *same* hue at zero alpha
    // (`highlight` -> `edge` below, same RGB, only alpha changes) keeps
    // the sweep a single, solid tone ("однотонным") end to end.
    //
    // Peak opacity is tuned per theme rather than one hardcoded value:
    // the badge's own accent color is brighter in dark theme
    // (`AppSemanticColors.dark.accent` vs `.light.accent`), so the same
    // white streak reads noticeably fainter against it there -- a
    // slightly higher peak alpha in dark mode keeps the sweep similarly
    // visible in both, instead of nearly vanishing in one of them.
    final highlight = Colors.white.withValues(alpha: isDark ? 0.65 : 0.55);
    final edge = highlight.withValues(alpha: 0);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // The highlight band's center travels from just before the
        // gradient line (-0.25) to just past its end (1.25) -- starting
        // and ending fully outside the visible 0..1 range so the sweep
        // visibly enters and exits [child] rather than fading in/out
        // already inside it.
        final center = -0.25 + _controller.value * 1.5;
        // Owner-reported: narrow the stripe to 1/1.5 (~0.133) of its
        // original width (0.2).
        const halfBand = 0.2 / 1.5;
        // Owner-reported: a smoothly-faded band read as out of place --
        // this app's own visual language is flat/solid color with crisp
        // edges (every badge/card here is a plain fill, no gradients or
        // blur). A tight (not zero -- an exactly-zero-width transition
        // aliases/looks jagged) transition at each edge turns the smooth
        // fade into a solid-toned stripe with a sharp boundary instead,
        // matching that language.
        const edgeSoftness = 0.015;
        double stop(double v) => v.clamp(0.0, 1.0);

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [edge, highlight, highlight, edge],
            stops: [
              stop(center - halfBand),
              stop(center - halfBand + edgeSoftness),
              stop(center + halfBand - edgeSoftness),
              stop(center + halfBand),
            ],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
