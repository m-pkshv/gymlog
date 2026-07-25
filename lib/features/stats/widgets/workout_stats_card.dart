import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../core/stats_period.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../core/widgets/hero_stat_tile.dart';
import '../../../l10n/app_localizations.dart';
import 'period_selector.dart';
import 'stats_section_card.dart';

/// S-09 "Тренировки" card (03_TECHNICAL_SPEC.md section 9): completed-workout
/// count, frequency, and tonnage for the selected period. Frequency is
/// omitted for the "Всё" preset, which has no defined length to divide by
/// (owner-confirmed 2026-07-21) rather than guessed from the data.
class WorkoutStatsCard extends ConsumerStatefulWidget {
  const WorkoutStatsCard({super.key});

  @override
  ConsumerState<WorkoutStatsCard> createState() => _WorkoutStatsCardState();
}

class _WorkoutStatsCardState extends ConsumerState<WorkoutStatsCard> {
  StatsPeriod _period = const StatsPeriod.preset(StatsPeriodPreset.month);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (from, to) = _period.range(DateTime.now());
    final weeks = _period.weeksInRange(DateTime.now());
    final rangeKey = (from: from, to: to);
    final statsAsync = ref.watch(workoutPeriodStatsProvider(rangeKey));

    return StatsSectionCard(
      title: l10n.statsWorkoutsCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PeriodSelector(
            period: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          const SizedBox(height: AppSpacing.md),
          statsAsync.when(
            data: (stats) {
              if (stats.workoutCount == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                  ),
                  child: Center(child: Text(l10n.statsEmptyPeriod)),
                );
              }
              return Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.lg,
                children: [
                  HeroStatTile(
                    icon: Icons.event_available_outlined,
                    value: stats.workoutCount.toString(),
                    label: l10n.statsWorkoutsCountLabel,
                  ),
                  if (weeks != null)
                    HeroStatTile(
                      icon: Icons.speed_outlined,
                      value: l10n.statsWorkoutsFrequencyValue(
                        (stats.workoutCount / weeks).toStringAsFixed(1),
                      ),
                      label: l10n.statsWorkoutsFrequencyLabel,
                    ),
                  HeroStatTile(
                    icon: Icons.scale_outlined,
                    value: l10n.workoutSummaryTonnageValue(
                      stats.tonnageKg.toStringAsFixed(1),
                    ),
                    label: l10n.workoutSummaryTonnageLabel,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ErrorRetryState(
              message: l10n.measurementsLoadError,
              onRetry: () =>
                  ref.invalidate(workoutPeriodStatsProvider(rangeKey)),
            ),
          ),
        ],
      ),
    );
  }
}
