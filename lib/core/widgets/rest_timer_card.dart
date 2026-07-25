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
    final elapsed = totalSeconds > 0
        ? (totalSeconds - remainingSeconds).clamp(0, totalSeconds) /
              totalSeconds
        : 0.0;

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
              child: FractionallySizedBox(
                widthFactor: elapsed,
                heightFactor: 1,
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
                IconButton(
                  tooltip: l10n.restTimerMinus15Tooltip,
                  onPressed: () => onAdjust(-15),
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: semantic.onAccentContainer,
                  ),
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
                IconButton(
                  tooltip: l10n.restTimerPlus15Tooltip,
                  onPressed: () => onAdjust(15),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: semantic.onAccentContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
