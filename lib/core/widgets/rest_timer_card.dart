import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';
import '../../core/duration_format.dart';
import '../../l10n/app_localizations.dart';

/// Pinned, high-emphasis rest-timer display (Stage 10 redesign, AUDIT.md
/// section 1.6-доп.: the old `_RestTimerBar` was "the most time-sensitive
/// row on the screen, but also the most cramped ... no color/progress
/// indication at all"). Purely presentational -- [remainingSeconds],
/// [remainingMilliseconds], [totalMilliseconds], and the three callbacks
/// are all the caller needs to supply; the workout editor screen still owns
/// querying `ActiveWorkoutTimerService`/rescheduling the notification
/// (Stage 4, TS 7.2/7.3), same as `_RestTimerBar` already did. Keeps all
/// three existing controls (±10 с/Пропустить) rather than the mockup's
/// single button -- dropping any of them would be a functional regression
/// nobody asked for, the mockup's simplification there reads as a space
/// constraint of the static image, not a deliberate cut.
///
/// [remainingSeconds] (whole seconds, rounded up -- see
/// `ActiveWorkoutTimerService.remainingRestSeconds`) only drives the mm:ss
/// label; the fill is driven separately by [remainingMilliseconds]/
/// [totalMilliseconds] (Stage 12, owner-reported: whole-second granularity
/// made the fill start visibly non-empty and stall for up to a second, and
/// never quite reach the far edge before the card disappeared -- the label
/// and the fill deliberately use different precision now).
class RestTimerCard extends StatelessWidget {
  const RestTimerCard({
    super.key,
    required this.remainingSeconds,
    required this.remainingMilliseconds,
    required this.totalMilliseconds,
    required this.onAdjust,
    required this.onSkip,
  });

  final int remainingSeconds;
  final int remainingMilliseconds;
  final int totalMilliseconds;

  /// Called with a signed delta in seconds (-10 or +10).
  final ValueChanged<int> onAdjust;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final elapsedMs = (totalMilliseconds - remainingMilliseconds).clamp(
      0,
      totalMilliseconds,
    );
    final elapsed = totalMilliseconds > 0 ? elapsedMs / totalMilliseconds : 0.0;
    // Owner-reported: completing another set restarts the rest timer from
    // full duration even if the previous one hadn't run out yet, so the
    // fill can be jumping down from anywhere -- e.g. mostly full -- back to
    // (almost) empty. `elapsedMs` is only ever this close to zero
    // structurally right when `startRestTimer` just wrote a fresh deadline
    // (`elapsed = total - remaining ≈ 0` by construction); a ±10с
    // adjustment or an ordinary tick essentially never lands here (the
    // narrow exception -- adjusting past a nearly-just-started timer -- has
    // nothing visible to animate anyway, the bar's already near empty).
    // That reset should snap instantly, not glide backwards. 500ms (not 0)
    // absorbs the real DB-write -> stream -> rebuild delay between
    // `startRestTimer` and this widget's first read of the fresh deadline,
    // without risking a false positive later -- `elapsedMs` only ever
    // grows from here on, by roughly a full second per ordinary tick, so it
    // can't wander back under the threshold on its own.
    final isFreshRestart = elapsedMs <= 500;

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
              // of our own. The same interpolation also covers a ±10с
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
                // Tape-deck layout, left-to-right along the timeline: ⏪ on
                // the left rewinds (adds time back, `endsAt` moves later),
                // ⏩ on the right fast-forwards (cuts the wait short,
                // `endsAt` moves earlier) -- owner-reported, replacing the
                // earlier circular-arrow-with-digit icons (Stage 12), which
                // also swaps which side does which relative to that
                // earlier layout.
                _SeekButton(
                  icon: Icons.fast_rewind,
                  color: semantic.onAccentContainer,
                  tooltip: l10n.restTimerPlus10Tooltip,
                  onPressed: () => onAdjust(10),
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
                _SeekButton(
                  icon: Icons.fast_forward,
                  color: semantic.onAccentContainer,
                  tooltip: l10n.restTimerMinus10Tooltip,
                  onPressed: () => onAdjust(-10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A tape-deck-style seek control -- plain double-triangle rewind/
/// fast-forward glyphs (owner-reported: like old cassette/tape-player
/// buttons), no digit overlay -- the amount is described by [tooltip]
/// alone, the same way a real tape deck's ⏪/⏩ buttons carry no printed
/// number either.
class _SeekButton extends StatelessWidget {
  const _SeekButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 26),
    );
  }
}
