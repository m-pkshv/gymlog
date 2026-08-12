import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/body_measurement.dart';
import 'package:gymlog/features/measurements/widgets/measurement_chart.dart';

BodyMeasurement _entry(String id, double value) {
  final now = DateTime.utc(2026, 1, 1);
  return BodyMeasurement(
    id: id,
    measurementTypeId: 'body_weight',
    date: now,
    valueMetric: value,
    source: MeasurementSource.manual,
    createdAt: now,
    updatedAt: now,
    isDeleted: false,
  );
}

/// The Y-axis labels a `LineChart` actually rendered, as parsed numbers --
/// filters out anything that isn't a plain number (chip labels, etc.
/// shouldn't be in this subtree at all, but this stays robust either way).
List<double> _renderedAxisValues(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(MeasurementChart),
          matching: find.byType(Text),
        ),
      )
      .map((t) => double.tryParse(t.data ?? ''))
      .whereType<double>()
      .toList();
}

void main() {
  testWidgets(
    'owner-reported: the exact data min/max used to render its own label '
    'directly on top of the nearest regular grid label ("79.8" over "80", '
    '"84.9" over "84"/"85") -- axis bounds now round out to the same grid '
    'the regular labels sit on',
    (tester) async {
      final entries = [
        _entry('1', 79.8),
        _entry('2', 81.3),
        _entry('3', 82.5),
        _entry('4', 84.9),
        _entry('5', 83.6),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MeasurementChart(
              entries: entries,
              displayValue: (e) => e.valueMetric,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final values = _renderedAxisValues(tester)..sort();
      expect(
        values,
        isNotEmpty,
        reason: 'the chart should have rendered at least one axis label',
      );

      // No two labels within a hair of each other -- that's what visual
      // overlap looks like numerically. The chart's own chosen interval
      // isn't exposed here, so this checks against a generic "labels are
      // spread out, not clustered" bar instead of a specific number.
      for (var i = 1; i < values.length; i++) {
        final gap = values[i] - values[i - 1];
        expect(
          gap,
          greaterThan(0.5),
          reason:
              'labels $values are too close together (${values[i - 1]} '
              'and ${values[i]}) -- they would visually overlap',
        );
      }
    },
  );

  testWidgets('renders without error for a single entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MeasurementChart(
            entries: [_entry('1', 82.5)],
            displayValue: (e) => e.valueMetric,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
