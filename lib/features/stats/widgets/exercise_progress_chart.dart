import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../core/chart_date_ticks.dart';
import '../../../core/nice_axis_bounds.dart';
import '../../../core/stats_period.dart';
import '../../../domain/models/exercise_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../exercise_progress_series.dart';
import 'period_selector.dart';
import 'stats_section_card.dart';

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

    return StatsSectionCard(
      title: widget.title,
      titleTrailing: widget.isEstimated
          ? Text(
              l10n.statsEstimatedBadge,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PeriodSelector(
            period: _period,
            onChanged: (period) => setState(() => _period = period),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (points.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: Text(l10n.statsEmptyPeriod)),
            )
          else
            _Chart(points: points),
        ],
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
    final values = spots.map((s) => s.y);
    final bounds = niceAxisBounds(
      values.reduce(math.min),
      values.reduce(math.max),
    );
    final dates = [for (final point in points) point.date];
    final ticks = dateAxisTicks(dates);
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;
    final gridColor = scheme.outlineVariant;
    // Same size/margin/grid/X-axis-date-tick treatment as `MeasurementChart`
    // (Stage 10 redesign, AUDIT.md section 1.4; redesign_v3 for the grid and
    // ticks) -- kept as a separate, near-identical widget rather than merged
    // into one shared chart component (an already-made call, Stage 7 Step
    // 6: not worth the risk of touching a tested, working widget to save
    // ~30 lines).
    return SizedBox(
      height: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 12, 4),
        child: LineChart(
          LineChartData(
            minY: bounds.min,
            maxY: bounds.max,
            gridData: FlGridData(
              drawHorizontalLine: true,
              horizontalInterval: bounds.interval,
              getDrawingHorizontalLine: (value) =>
                  FlLine(color: gridColor, strokeWidth: 1),
              drawVerticalLine: true,
              // See `MeasurementChart`'s identical comment -- without this,
              // fl_chart only offers its own auto-computed candidate
              // positions to `checkToShowVerticalLine`, not every index.
              verticalInterval: 1,
              checkToShowVerticalLine: (value) =>
                  ticks.indexes.contains(value.round()),
              getDrawingVerticalLine: (value) =>
                  FlLine(color: gridColor, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.round();
                    if (index < 0 ||
                        index >= dates.length ||
                        !ticks.indexes.contains(index)) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        formatDateTick(
                          dates[index],
                          monthly: ticks.monthly,
                          locale: locale,
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  interval: bounds.interval,
                ),
              ),
            ),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: color,
                barWidth: 3,
                // Same smoothing as `MeasurementChart` (owner-supplied
                // reference image) -- see that file's comment for why
                // 0.55 and `preventCurveOverShooting` specifically.
                isCurved: true,
                curveSmoothness: 0.55,
                preventCurveOverShooting: true,
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
