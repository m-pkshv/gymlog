import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/stats_period.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../l10n/app_localizations.dart';
import 'period_selector.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsWorkoutsCardTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PeriodSelector(
              period: _period,
              onChanged: (period) => setState(() => _period = period),
            ),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) {
                if (stats.workoutCount == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.statsEmptyPeriod)),
                  );
                }
                return Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  children: [
                    _StatTile(
                      icon: Icons.event_available_outlined,
                      value: stats.workoutCount.toString(),
                      label: l10n.statsWorkoutsCountLabel,
                    ),
                    if (weeks != null)
                      _StatTile(
                        icon: Icons.speed_outlined,
                        value: l10n.statsWorkoutsFrequencyValue(
                          (stats.workoutCount / weeks).toStringAsFixed(1),
                        ),
                        label: l10n.statsWorkoutsFrequencyLabel,
                      ),
                    _StatTile(
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
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
