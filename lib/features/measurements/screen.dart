import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import 'measurement_type_labels.dart';
import 'measurement_type_lookup.dart';
import 'widgets/create_measurement_type_dialog.dart';
import 'widgets/measurement_type_detail.dart';

/// S-14: tabs for Weight / Body fat % / Measurements (girths) / Custom
/// (04_UI_UX_SPEC.md, section 5). The girths tab needs a sub-selector among
/// the 13 built-in length types; "Свои" also hosts "Добавить замер…" (DM
/// 5.3, custom-type management). "+" opens the S-15 form, preselecting the
/// type implied by the active tab/selection — still changeable there.
class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedGirthId;
  String? _weightTypeId;
  String? _bodyFatTypeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addEntry(String? initialTypeId) {
    return context.push('/more/measurements/new', extra: initialTypeId);
  }

  /// "Замеры" tab (Stage 10, owner-reported): "+" opens the bulk-entry
  /// screen (every girth type at once) instead of the single-entry form
  /// preselected to whichever girth the dropdown happened to have selected.
  Future<void> _addGirthEntries() {
    return context.push('/more/measurements/girths');
  }

  Future<void> _addCustomType() async {
    final service = ref.read(measurementTypeServiceProvider);
    await showDialog<bool>(
      context: context,
      builder: (context) => CreateMeasurementTypeDialog(
        onCreate: (name, unitKind) async {
          final result = await service.create(
            nameCustom: name,
            unitKind: unitKind,
          );
          return result.isOk;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(measurementTypesListProvider(false));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.measurementsTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.measurementsTabWeight),
            Tab(text: l10n.measurementsTabBodyFat),
            Tab(text: l10n.measurementsTabMeasurements),
            Tab(text: l10n.measurementsTabCustom),
          ],
        ),
      ),
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
          _weightTypeId = weight?.id;
          _bodyFatTypeId = bodyFat?.id;
          final girths =
              types
                  .where(
                    (t) =>
                        t.isBuiltIn && t.unitKind == MeasurementUnitKind.length,
                  )
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final customTypes = types.where((t) => !t.isBuiltIn).toList();
          final selectedGirth =
              firstMeasurementTypeWhere(girths, (t) => t.id == _selectedGirthId) ??
              (girths.isNotEmpty ? girths.first : null);

          return TabBarView(
            controller: _tabController,
            children: [
              weight == null
                  ? const SizedBox.shrink()
                  : MeasurementTypeDetail(type: weight),
              bodyFat == null
                  ? const SizedBox.shrink()
                  : MeasurementTypeDetail(type: bodyFat),
              Column(
                children: [
                  if (girths.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: selectedGirth?.id,
                        decoration: InputDecoration(
                          labelText: l10n.measurementGirthSelectorLabel,
                        ),
                        items: [
                          for (final girth in girths)
                            DropdownMenuItem(
                              value: girth.id,
                              child: Text(measurementTypeLabel(l10n, girth)),
                            ),
                        ],
                        onChanged: (id) =>
                            setState(() => _selectedGirthId = id),
                      ),
                    ),
                  if (selectedGirth != null)
                    Expanded(child: MeasurementTypeDetail(type: selectedGirth)),
                ],
              ),
              ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: Text(l10n.addCustomMeasurementTypeAction),
                    onTap: _addCustomType,
                  ),
                  if (customTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(l10n.measurementsCustomEmptyState),
                      ),
                    ),
                  for (final type in customTypes)
                    ListTile(
                      title: Text(measurementTypeLabel(l10n, type)),
                      subtitle: Text(
                        measurementUnitKindLabel(l10n, type.unitKind),
                      ),
                      onTap: () =>
                          context.push('/more/measurements/custom/${type.id}'),
                    ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.measurementsLoadError,
          onRetry: () => ref.invalidate(measurementTypesListProvider(false)),
        ),
      ),
      floatingActionButton: _tabController.index == 3
          ? null
          : FloatingActionButton(
              onPressed: _tabController.index == 2
                  ? _addGirthEntries
                  : () => _addEntry(switch (_tabController.index) {
                      0 => _weightTypeId,
                      1 => _bodyFatTypeId,
                      _ => null,
                    }),
              tooltip: l10n.addMeasurementEntryAction,
              child: const Icon(Icons.add),
            ),
    );
  }
}
