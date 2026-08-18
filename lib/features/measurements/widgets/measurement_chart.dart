import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/chart_date_ticks.dart';
import '../../../core/nice_axis_bounds.dart';
import '../../../domain/models/body_measurement.dart';

/// Line chart of one measurement type's entries (S-14 "график сверху").
/// [entries] must already be sorted oldest-first; [displayValue] converts
/// each entry's stored metric value to the unit shown (D-5).
class MeasurementChart extends StatelessWidget {
  const MeasurementChart({
    super.key,
    required this.entries,
    required this.displayValue,
  });

  final List<BodyMeasurement> entries;
  final double Function(BodyMeasurement entry) displayValue;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), displayValue(entries[i])),
    ];
    final values = spots.map((s) => s.y);
    final bounds = niceAxisBounds(
      values.reduce(math.min),
      values.reduce(math.max),
    );
    final dates = [for (final entry in entries) entry.date];
    final ticks = dateAxisTicks(dates);
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;
    final gridColor = scheme.outlineVariant;
    // Stage 10 redesign, AUDIT.md section 1.4: "the chart is small, cramped
    // by padding" -- taller (180 -> 220, then 240 once the X axis grew its
    // own row of date labels below) with lighter side padding. Grid lines
    // and X-axis date ticks (redesign_v3, owner-supplied reference image)
    // replace the earlier "no grid at all" call, which was really just
    // working around AUDIT.md's *other* complaint -- an unlabeled dashed
    // average line no code here ever actually drew -- not a considered
    // decision against having a grid.
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
              // Without an explicit `verticalInterval`, fl_chart only ever
              // offers `checkToShowVerticalLine` its own auto-computed
              // "efficient interval" candidate positions -- usually not the
              // (irregularly spaced) tick indexes this chart actually wants
              // a line at. `1` makes every index a candidate, same as the
              // bottom titles' own `interval: 1` right above.
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
              // Monday ticks for a span of a month or less, first-of-month
              // ticks for anything longer (owner-supplied reference image
              // + explicit rule, redesign_v3) -- `dateAxisTicks` decides
              // which dates qualify, this only hides/shows the label
              // fl_chart would otherwise draw at every single index
              // (`interval: 1`) down to that decision.
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
                // Owner-supplied reference image: smooth curves through each
                // point instead of the sharp per-point corners a plain
                // polyline draws. Started at fl_chart's default
                // `curveSmoothness` (0.35), then bumped to 0.55 to make the
                // curve read as more than "still mostly straight lines" on a
                // real multi-month weight series -- but that overshot: on a
                // near-flat run (day-to-day weight noise, no real trend),
                // 0.55 draws visibly bulging humps between points that sit on
                // essentially the same line (owner-reported, redesign_v3).
                // `preventCurveOverShooting`/`preventCurveOvershootingThreshold`
                // (fl_chart's own cubic-spline overshoot guard) does *not*
                // fix this -- verified experimentally (threshold 10 vs. 60
                // rendered identically) -- because it compares each pair of
                // neighboring points' *signed* pixel-space delta against a
                // positive threshold, so it only ever suppresses bulging on
                // one side of a rising/falling run, never on a flat one.
                // `curveSmoothness` is the only lever that actually helps:
                // dropped to 0.15, which flattens near-flat runs back to
                // essentially straight lines while still drawing a visibly
                // curved arc through real peaks/troughs (verified against a
                // synthetic 52-point two-cycle sine+noise series matching the
                // shape of real weight data, plus the sparse/dense reference
                // zoom levels from the original 0.55 pass). The overshoot
                // guard is left on at its default threshold -- harmless, and
                // still a reasonable safety clamp for a single large outlier
                // even though it isn't what fixed the reported bug.
                isCurved: true,
                curveSmoothness: 0.15,
                preventCurveOverShooting: true,
                preventCurveOvershootingThreshold: 10,
                // fl_chart's default dot radius (4) reads as an oversized
                // bulb next to a 3px line -- owner-reported (redesign_v3):
                // shrink it to just a bit thicker than the line itself.
                dotData: FlDotData(
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(radius: 2.5, color: color),
                ),
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
