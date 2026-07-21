import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../measurements/measurement_type_lookup.dart';
import 'widgets/measurement_dynamics_body.dart';
import 'widgets/measurement_type_dynamics_card.dart';

/// S-09 "Статистика" (04_UI_UX_SPEC.md, section 5): "Секции-карточки: Вес
/// тела, % жира, Замеры (выбор типа), Тренировки (число/частота/тоннаж),
/// «Прогресс по упражнению»." This step covers the first three (dynamics
/// charts, reusing Stage 6's `BodyMeasurementRepository` + the new S-09
/// period filter); the workout-count/frequency/tonnage card and the
/// exercise-progress search are a later step.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(measurementTypesListProvider(false));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabStats)),
      body: typesAsync.when(
        data: (types) {
          final weight = firstMeasurementTypeWhere(
            types,
            (t) => t.isBuiltIn && t.unitKind == MeasurementUnitKind.mass,
          );
          final bodyFat = firstMeasurementTypeWhere(
            types,
            (t) => t.isBuiltIn && t.unitKind == MeasurementUnitKind.percent,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (weight != null)
                _DynamicsCard(
                  title: l10n.statsWeightCardTitle,
                  child: MeasurementDynamicsBody(type: weight),
                ),
              if (bodyFat != null) ...[
                const SizedBox(height: 16),
                _DynamicsCard(
                  title: l10n.statsBodyFatCardTitle,
                  child: MeasurementDynamicsBody(type: bodyFat),
                ),
              ],
              const SizedBox(height: 16),
              const MeasurementTypeDynamicsCard(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.measurementsLoadError)),
      ),
    );
  }
}

class _DynamicsCard extends StatelessWidget {
  const _DynamicsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
