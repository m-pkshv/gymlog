import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
    final color = Theme.of(context).colorScheme.primary;
    // Stage 10 redesign, AUDIT.md section 1.4: "the chart is small, cramped
    // by padding". Taller (180 -> 220) with lighter side padding, and no
    // horizontal grid lines -- AUDIT also flagged "an unlabeled dashed
    // average line" on the pre-redesign screenshot, but no code here (or
    // anywhere in `lib/`) ever drew one; the closest candidate is
    // `FlGridData`'s default horizontal grid line, which this removes
    // rather than trying to retroactively label something the app never
    // actually rendered.
    return SizedBox(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 12, 4),
        child: LineChart(
          LineChartData(
            minY: bounds.min,
            maxY: bounds.max,
            gridData: const FlGridData(
              drawVerticalLine: false,
              drawHorizontalLine: false,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
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
                // polyline draws. fl_chart's own default `curveSmoothness`
                // (0.35) barely rounded a real, noisy multi-month weight
                // series -- too many closely-spaced direction changes for a
                // subtle curve to read as anything but "still mostly
                // straight lines" -- so this is bumped to 0.55, matched
                // on-device against the reference image at both a sparse
                // (~13 points) and a dense (~50 points) zoom level.
                // `preventCurveOverShooting` keeps the curve from bulging
                // past a point when its neighbors are close together on
                // screen (fl_chart's own fix for cubic-spline overshoot, not
                // something built here) -- made no visible difference on
                // this data but is the safer default for data shapes that
                // would show it.
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
