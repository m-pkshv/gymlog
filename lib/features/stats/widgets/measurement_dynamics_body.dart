import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/stats_period.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../domain/models/body_measurement.dart';
import '../../../domain/models/measurement_type.dart';
import '../../../l10n/app_localizations.dart';
import '../../measurements/measurement_value_format.dart';
import '../../measurements/widgets/measurement_chart.dart';
import 'period_selector.dart';

/// Period selector + chart for one `MeasurementType` (S-09: weight/body-fat/
/// measurement dynamics, 03_TECHNICAL_SPEC.md section 9 — "точка = значение
/// за день; линия по дням с записями, без интерполяции"). No card chrome of
/// its own — the caller supplies the title and wraps this in a `Card`, so
/// the same body works for the fixed-type cards and the "Замеры" card with
/// its own type dropdown above this.
class MeasurementDynamicsBody extends ConsumerStatefulWidget {
  const MeasurementDynamicsBody({super.key, required this.type});

  final MeasurementType type;

  @override
  ConsumerState<MeasurementDynamicsBody> createState() =>
      _MeasurementDynamicsBodyState();
}

class _MeasurementDynamicsBodyState
    extends ConsumerState<MeasurementDynamicsBody> {
  StatsPeriod _period = const StatsPeriod.preset(StatsPeriodPreset.month);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (from, to) = _period.range(DateTime.now());
    final rangeKey = (
      measurementTypeId: widget.type.id,
      from: from,
      to: to,
    );
    final entriesAsync = ref.watch(bodyMeasurementsInRangeProvider(rangeKey));
    final settingsAsync = ref.watch(appSettingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PeriodSelector(
          period: _period,
          onChanged: (period) => setState(() => _period = period),
        ),
        const SizedBox(height: 8),
        settingsAsync.when(
          data: (settings) => entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text(l10n.statsEmptyPeriod)),
                );
              }
              // [entries] arrives newest-first; the chart wants
              // oldest-first so time runs left-to-right.
              final chronological = entries.reversed.toList();
              double display(BodyMeasurement entry) => measurementValueToDisplay(
                entry.valueMetric,
                widget.type.unitKind,
                settings.unitSystem,
              );
              return MeasurementChart(
                entries: chronological,
                displayValue: display,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ErrorRetryState(
              message: l10n.measurementsLoadError,
              onRetry: () =>
                  ref.invalidate(bodyMeasurementsInRangeProvider(rangeKey)),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ErrorRetryState(
            message: l10n.measurementsLoadError,
            onRetry: () => ref.invalidate(appSettingsProvider),
          ),
        ),
      ],
    );
  }
}
