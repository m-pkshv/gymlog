import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../domain/models/body_measurement.dart';
import '../../../domain/models/measurement_type.dart';
import '../../../l10n/app_localizations.dart';
import '../measurement_type_labels.dart';
import '../measurement_value_format.dart';
import 'measurement_chart.dart';

/// Chart + dated entry list for one `MeasurementType` (S-14): reused for
/// the Weight/Body fat/Measurements tabs and the custom-type detail screen.
/// Values are shown in the unit system from `AppSettings.unitSystem` (D-5).
class MeasurementTypeDetail extends ConsumerWidget {
  const MeasurementTypeDetail({super.key, required this.type});

  final MeasurementType type;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    BodyMeasurement entry,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(bodyMeasurementRepositoryProvider);
    await repository.delete(entry.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.measurementEntryDeletedMessage),
        duration: undoSnackbarDuration,
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: () => repository.restore(entry.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(bodyMeasurementsByTypeProvider(type.id));
    final settingsAsync = ref.watch(appSettingsProvider);

    return settingsAsync.when(
      data: (settings) => entriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(child: Text(l10n.measurementsEmptyState));
          }
          // [entries] arrives newest-first (list display); the chart wants
          // oldest-first so time runs left-to-right.
          final chronological = entries.reversed.toList();
          double display(BodyMeasurement entry) => measurementValueToDisplay(
            entry.valueMetric,
            type.unitKind,
            settings.unitSystem,
          );
          final unit = measurementUnitSuffix(
            l10n,
            type.unitKind,
            settings.unitSystem,
          );
          return Column(
            children: [
              if (chronological.length > 1)
                MeasurementChart(entries: chronological, displayValue: display),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final value = display(entry);
                    return ListTile(
                      title: Text('${value.toStringAsFixed(1)} $unit'),
                      subtitle: Text(
                        entry.comment == null
                            ? formatShortDate(entry.date)
                            : '${formatShortDate(entry.date)} — ${entry.comment}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: l10n.deleteMeasurementEntryAction,
                        onPressed: () => _delete(context, ref, entry),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.measurementsLoadError,
          onRetry: () =>
              ref.invalidate(bodyMeasurementsByTypeProvider(type.id)),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorRetryState(
        message: l10n.measurementsLoadError,
        onRetry: () => ref.invalidate(appSettingsProvider),
      ),
    );
  }
}
