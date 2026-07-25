import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
            gridData: const FlGridData(
              drawVerticalLine: false,
              drawHorizontalLine: false,
            ),
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
                barWidth: 3,
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
