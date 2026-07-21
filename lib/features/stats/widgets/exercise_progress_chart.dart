import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/stats_period.dart';
import '../../../domain/models/exercise_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../exercise_progress_series.dart';
import 'period_selector.dart';

/// One S-10 progress chart: its own period switcher (04_UI_UX_SPEC.md,
/// section 5: "Каждый график: переключатель периода" -- same "each chart
/// gets an independent period" rule the S-09 dynamics cards already follow)
/// over [history], reduced to one point per workout by [seriesBuilder].
/// [isEstimated] shows the "«расчётный»" badge next to the title, for the
/// 1RM chart.
class ExerciseProgressChart extends StatefulWidget {
  const ExerciseProgressChart({
    super.key,
    required this.title,
    required this.history,
    required this.seriesBuilder,
    this.isEstimated = false,
  });

  final String title;
  final List<ExerciseHistoryEntry> history;
  final List<ExerciseProgressPoint> Function(List<ExerciseHistoryEntry>)
  seriesBuilder;
  final bool isEstimated;

  @override
  State<ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends State<ExerciseProgressChart> {
  StatsPeriod _period = const StatsPeriod.preset(StatsPeriodPreset.month);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (from, to) = _period.range(DateTime.now());
    final filteredHistory = widget.history.where((entry) {
      final date = entry.workout.date;
      if (from != null && date.isBefore(from)) return false;
      if (to != null && date.isAfter(to)) return false;
      return true;
    }).toList();
    final points = widget.seriesBuilder(filteredHistory);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                if (widget.isEstimated) ...[
                  const SizedBox(width: 8),
                  Text(
                    l10n.statsEstimatedBadge,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            PeriodSelector(
              period: _period,
              onChanged: (period) => setState(() => _period = period),
            ),
            const SizedBox(height: 8),
            if (points.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(l10n.statsEmptyPeriod)),
              )
            else
              _Chart(points: points),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.points});

  final List<ExerciseProgressPoint> points;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].value),
    ];
    final color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: 180,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, reservedSize: 44),
              ),
            ),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: color,
                barWidth: 2,
                dotData: const FlDotData(),
                belowBarData: BarAreaData(
                  show: true,
                  color: color.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
