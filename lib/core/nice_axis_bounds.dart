import 'dart:math' as math;

/// A Y-axis range and label step for a line chart, chosen so both ends
/// land exactly on a regular label position.
class NiceAxisBounds {
  const NiceAxisBounds({required this.min, required this.max, required this.interval});

  final double min;
  final double max;
  final double interval;
}

/// Rounds [dataMin]/[dataMax] out to the nearest multiple of a "nice" step
/// (1/2/5/10/... scaled to the data's own magnitude), so the chart's axis
/// bounds always coincide with a regular grid label.
///
/// fl_chart always draws an extra label at the *exact* data min/max
/// (`AxisChartData.minIncluded`/`maxIncluded` default `true`, and
/// `LineChartData`'s own constructor doesn't expose them to turn off) on
/// top of whatever regular interval labels it computes on its own --
/// owner-reported: a real weight series (79.8-84.9) rendered "79.8"
/// directly on top of "80" and "84.9" on top of "84"/"85", since those
/// exact values never happened to fall on the same 1-unit grid. Passing
/// this type's [min]/[max]/[interval] straight through to `LineChartData`'s
/// `minY`/`maxY` and `SideTitles.interval` makes the forced edge label and
/// the nearest regular one the *same* position instead of two adjacent,
/// overlapping ones.
NiceAxisBounds niceAxisBounds(double dataMin, double dataMax) {
  if (dataMin == dataMax) {
    // A flat series (including a single point) -- pad by one step on each
    // side so it isn't drawn flush against the chart's own edge.
    final interval = _niceStep(dataMin == 0 ? 1 : dataMin.abs() / 4);
    return NiceAxisBounds(
      min: dataMin - interval,
      max: dataMax + interval,
      interval: interval,
    );
  }
  final interval = _niceStep((dataMax - dataMin) / 4);
  return NiceAxisBounds(
    min: (dataMin / interval).floorToDouble() * interval,
    max: (dataMax / interval).ceilToDouble() * interval,
    interval: interval,
  );
}

/// The classic "nice numbers" step (Heckbert): the closest value in the
/// {1, 2, 5} x 10^n progression to [roughStep], so axis labels read as
/// round numbers ("2", "5", "10") rather than an arbitrary fraction of the
/// data range ("1.766...").
double _niceStep(double roughStep) {
  if (roughStep <= 0) return 1;
  final magnitude = math.pow(10, (math.log(roughStep) / math.ln10).floor())
      .toDouble();
  final residual = roughStep / magnitude;
  final double niceResidual;
  if (residual <= 1) {
    niceResidual = 1;
  } else if (residual <= 2) {
    niceResidual = 2;
  } else if (residual <= 5) {
    niceResidual = 5;
  } else {
    niceResidual = 10;
  }
  return niceResidual * magnitude;
}
