import 'dart:math';

import 'package:flutter/material.dart';

import '../color_hex.dart';
import '../constants.dart';

/// A short, one-shot confetti burst falling from the top of the screen
/// (Stage: design/redesign_v2, owner-requested for the workout summary
/// screen): simple shapes (circle/square/triangle) in the app's own tag
/// palette (`workoutTagColorPalette`, core/constants.dart), so this
/// doesn't introduce a second arbitrary color set. Each particle
/// decelerates as it falls (ease-out) and fades out around the middle of
/// the screen rather than reaching the bottom (owner-reported). Self-
/// contained -- an [AnimationController] driving a [CustomPainter], no
/// external package (05_AI_INSTRUCTIONS.md forbids adding a dependency
/// not already in TS 3 without asking first, and this doesn't need one).
///
/// Purely decorative: [IgnorePointer]-wrapped so it never blocks taps on
/// whatever it's layered over, and stops painting anything at all once the
/// burst finishes (`_finished` collapses to [SizedBox.shrink], so there's
/// nothing left consuming frames or sitting invisibly off-screen).
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1600);
  static const _particleCount = 36;

  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _particles = List.generate(
      _particleCount,
      (_) => _ConfettiParticle.random(random),
    );
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _finished = true);
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

enum _ConfettiShape { circle, square, triangle }

class _ConfettiParticle {
  /// A visually varied particle: random horizontal position, a small
  /// staggered start (so the burst doesn't fall as one rigid grid), a
  /// random fall speed/size/sway/spin, a color drawn from the app's
  /// existing 8-color tag palette rather than inventing a separate one,
  /// and a landing point a little above/below the exact middle of the
  /// screen (owner-reported: fade out around mid-screen, not the bottom).
  factory _ConfettiParticle.random(Random random) {
    return _ConfettiParticle(
      dx: random.nextDouble(),
      startDelay: random.nextDouble() * 0.25,
      fallDuration: 0.55 + random.nextDouble() * 0.25,
      color: colorFromHex(
        workoutTagColorPalette[random.nextInt(workoutTagColorPalette.length)],
      ),
      shape: _ConfettiShape
          .values[random.nextInt(_ConfettiShape.values.length)],
      size: 6 + random.nextDouble() * 6,
      swayAmount: 10 + random.nextDouble() * 20,
      swaySpeed: 2 + random.nextDouble() * 3,
      rotationSpeed: 2 + random.nextDouble() * 4,
      rotationDirection: random.nextBool() ? 1 : -1,
      targetHeightFraction: 0.42 + random.nextDouble() * 0.16,
    );
  }

  const _ConfettiParticle({
    required this.dx,
    required this.startDelay,
    required this.fallDuration,
    required this.color,
    required this.shape,
    required this.size,
    required this.swayAmount,
    required this.swaySpeed,
    required this.rotationSpeed,
    required this.rotationDirection,
    required this.targetHeightFraction,
  });

  /// Horizontal position as a fraction of the canvas width (0..1).
  final double dx;

  /// Fraction (0..~0.25) of the total animation this particle waits
  /// before it starts falling -- the staggering that makes the burst read
  /// as loose confetti rather than a synchronized grid.
  final double startDelay;

  /// Fraction of the total animation this particle spends actually
  /// falling, once its [startDelay] has elapsed.
  final double fallDuration;

  final Color color;
  final _ConfettiShape shape;
  final double size;
  final double swayAmount;
  final double swaySpeed;
  final double rotationSpeed;
  final int rotationDirection;

  /// Where this particle finishes falling, as a fraction of the canvas
  /// height (~0.42..0.58 -- around the middle, not the very bottom).
  final double targetHeightFraction;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final localT = ((progress - particle.startDelay) / particle.fallDuration)
          .clamp(0.0, 1.0);
      if (localT <= 0) continue;

      // Owner-reported: slow down a bit while falling (ease-out, fast at
      // the top and gently braking) and fade out around the middle of the
      // screen instead of falling all the way to the bottom -- only the
      // vertical position eases; sway/rotation stay on the raw (linear)
      // `localT` below so the flutter/spin doesn't visibly freeze as the
      // fall decelerates.
      final fallT = Curves.easeOut.transform(localT);
      final targetY = particle.targetHeightFraction * size.height;
      final y = -20 + fallT * (targetY + 20);
      final sway =
          sin(localT * particle.swaySpeed * pi * 2) * particle.swayAmount;
      final x = particle.dx * size.width + sway;
      final opacity = localT > 0.85 ? (1 - (localT - 0.85) / 0.15) : 1.0;
      if (opacity <= 0) continue;

      final paint = Paint()..color = particle.color.withValues(alpha: opacity);
      final rotation =
          localT * particle.rotationSpeed * pi * 2 * particle.rotationDirection;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      switch (particle.shape) {
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
        case _ConfettiShape.square:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
        case _ConfettiShape.triangle:
          final path = Path()
            ..moveTo(0, -particle.size / 2)
            ..lineTo(particle.size / 2, particle.size / 2)
            ..lineTo(-particle.size / 2, particle.size / 2)
            ..close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
