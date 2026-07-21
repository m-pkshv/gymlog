import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../measurements/measurement_type_labels.dart';
import '../../measurements/measurement_type_lookup.dart';
import 'measurement_dynamics_body.dart';

/// S-09 "Замеры" card: a type dropdown (built-in girths + custom
/// `length`-kind types — `body_weight`/`body_fat` have their own dedicated
/// cards) above the shared chart body. The dropdown's own selection state
/// is kept across period changes and across type switches (same State
/// object, `MeasurementDynamicsBody` isn't recreated with a new key).
class MeasurementTypeDynamicsCard extends ConsumerStatefulWidget {
  const MeasurementTypeDynamicsCard({super.key});

  @override
  ConsumerState<MeasurementTypeDynamicsCard> createState() =>
      _MeasurementTypeDynamicsCardState();
}

class _MeasurementTypeDynamicsCardState
    extends ConsumerState<MeasurementTypeDynamicsCard> {
  String? _selectedTypeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(measurementTypesListProvider(false));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statsMeasurementsCardTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            typesAsync.when(
              data: (types) {
                final candidates =
                    types
                        .where((t) => t.unitKind == MeasurementUnitKind.length)
                        .toList()
                      ..sort((a, b) {
                        if (a.isBuiltIn != b.isBuiltIn) {
                          return a.isBuiltIn ? -1 : 1;
                        }
                        if (a.isBuiltIn) {
                          return a.sortOrder.compareTo(b.sortOrder);
                        }
                        return (a.nameCustom ?? '').toLowerCase().compareTo(
                          (b.nameCustom ?? '').toLowerCase(),
                        );
                      });
                if (candidates.isEmpty) {
                  return Text(l10n.statsEmptyPeriod);
                }
                final currentId =
                    (_selectedTypeId != null &&
                        candidates.any((t) => t.id == _selectedTypeId))
                    ? _selectedTypeId
                    : candidates.first.id;
                final current = firstMeasurementTypeWhere(
                  candidates,
                  (t) => t.id == currentId,
                )!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: currentId,
                      decoration: InputDecoration(
                        labelText: l10n.measurementTypeFieldLabel,
                      ),
                      items: [
                        for (final type in candidates)
                          DropdownMenuItem(
                            value: type.id,
                            child: Text(measurementTypeLabel(l10n, type)),
                          ),
                      ],
                      onChanged: (id) => setState(() => _selectedTypeId = id),
                    ),
                    const SizedBox(height: 8),
                    MeasurementDynamicsBody(type: current),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Text(l10n.measurementsLoadError),
            ),
          ],
        ),
      ),
    );
  }
}
