import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../core/duration_format.dart';
import '../../l10n/app_localizations.dart';

/// Pinned, high-emphasis rest-timer display (Stage 10 redesign, AUDIT.md
/// section 1.6-доп.: the old `_RestTimerBar` was "the most time-sensitive
/// row on the screen, but also the most cramped ... no color/progress
/// indication at all"). Purely presentational -- [remainingSeconds],
/// [totalSeconds], and the three callbacks are all the caller needs to
/// supply; the workout editor screen still owns querying
/// `ActiveWorkoutTimerService`/rescheduling the notification (Stage 4, TS
/// 7.2/7.3), same as `_RestTimerBar` already did. Keeps all three existing
/// controls (±15 с/Пропустить) rather than the mockup's single button --
/// dropping any of them would be a functional regression nobody asked for,
/// the mockup's simplification there reads as a space constraint of the
/// static image, not a deliberate cut.
class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.onAdjust,
    required this.onSkip,
  });

  final int remainingSeconds;
  final int totalSeconds;

  /// Called with a signed delta in seconds (-15 or +15).
  final ValueChanged<int> onAdjust;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final elapsedSeconds = (totalSeconds - remainingSeconds).clamp(
      0,
      totalSeconds,
    );
    final elapsed = totalSeconds > 0 ? elapsedSeconds / totalSeconds : 0.0;
    // Owner-reported: completing another set restarts the rest timer from
    // full duration even if the previous one hadn't run out yet, so the
    // fill can be jumping down from anywhere -- e.g. mostly full -- back to
    // (almost) empty. `elapsedSeconds` is only ever this close to zero
    // structurally right when `startRestTimer` just wrote a fresh deadline
    // (`elapsed = total - remaining ≈ 0` by construction); a ±15с
    // adjustment or an ordinary tick essentially never lands here (the
    // narrow exception -- adjusting past a nearly-just-started timer -- has
    // nothing visible to animate anyway, the bar's already near empty).
    // That reset should snap instantly, not glide backwards.
    final isFreshRestart = elapsedSeconds <= 1;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card - 2),
      child: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: semantic.accentContainer),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              // Owner-reported: the fill used to jump in visible steps,
              // once per tick of the shared 1-second ticker
              // (`_ActiveWorkoutTicker`) that drives `remainingSeconds`.
              // `TweenAnimationBuilder` smoothly interpolates its own width
              // toward whatever `elapsed` happens to be on each rebuild --
              // since a new tick arrives right as the previous animation
              // finishes, the two together read as one continuous glide
              // rather than a stepped bar, with no extra per-frame ticking
              // of our own. The same interpolation also covers a ±15с
              // adjustment landing mid-tick: rather than snapping instantly,
              // it eases to the new position over the same short window.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: elapsed, end: elapsed),
                duration: isFreshRestart
                    ? Duration.zero
                    : const Duration(milliseconds: 950),
                curve: Curves.linear,
                builder: (context, value, child) => FractionallySizedBox(
                  widthFactor: value,
                  heightFactor: 1,
                  child: child,
                ),
                child: ColoredBox(color: semantic.accent),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.restTimerLabel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(
                              color: semantic.onAccentContainer,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                      ),
                      Text(
                        formatElapsedTime(remainingSeconds),
                        style: AppNumberTextStyles.timer(context).copyWith(
                          color: semantic.onAccentContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                // -15с shortens the remaining wait (`endsAt` moves earlier)
                // -- the same effect as fast-forwarding through the
                // countdown, so it gets a forward-pointing scrub icon;
                // +15с lengthens it (`endsAt` moves later), matching a
                // rewind (owner-reported: replace the generic +/- circles
                // with player-style seek arrows for clarity).
                _SeekSecondsButton(
                  seconds: 15,
                  forward: true,
                  color: semantic.onAccentContainer,
                  tooltip: l10n.restTimerMinus15Tooltip,
                  onPressed: () => onAdjust(-15),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: semantic.accent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: l10n.restTimerSkipAction,
                    onPressed: onSkip,
                    icon: Icon(Icons.skip_next, color: semantic.onAccent),
                  ),
                ),
                _SeekSecondsButton(
                  seconds: 15,
                  forward: false,
                  color: semantic.onAccentContainer,
                  tooltip: l10n.restTimerPlus15Tooltip,
                  onPressed: () => onAdjust(15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A player-style "seek ±N seconds" control -- a circular arrow (Material
/// has no built-in glyph for 15 specifically, only `replay_10`/`forward_10`/
/// `_30`, whose forward variants are themselves just the rewind glyph
/// mirrored) with the second count overlaid in its center, the same visual
/// idiom podcast/video players use for skip buttons.
class _SeekSecondsButton extends StatelessWidget {
  const _SeekSecondsButton({
    required this.seconds,
    required this.forward,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final int seconds;

  /// `true` mirrors the rewind glyph into a forward one; `false` leaves it
  /// as the rewind glyph.
  final bool forward;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Transform.flip(
        flipX: forward,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.replay, color: color, size: 26),
            Padding(
              // Nudges the digits down/into the arrow's circular sweep, off
              // its default vertical center -- matching where Material's
              // own `replay_10`/`replay_30` glyphs place their digits.
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '$seconds',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
