import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/units/unit_converter.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/enums.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/measurement_type.dart';
import '../../l10n/app_localizations.dart';
import 'measurement_type_labels.dart';
import 'measurement_value_format.dart';

const _unitConverter = UnitConverter();

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// "Замеры" bulk-entry screen (S-15 alternative, Stage 10, owner-reported):
/// every built-in girth type listed at once with a value field next to it,
/// instead of picking one type at a time from a dropdown before opening the
/// single-entry form. Existing values for the selected date are prefilled
/// (owner-confirmed) so it's visible what's already logged; saving is
/// per-field (not all-or-nothing) so a mistake in one field doesn't block
/// the rest from being saved. Custom types and Weight/% жира keep the
/// single-entry form (`MeasurementFormScreen`) — owner-confirmed this
/// screen is for "Замеры" only.
class MeasurementGirthsBulkEntryScreen extends ConsumerStatefulWidget {
  const MeasurementGirthsBulkEntryScreen({super.key});

  @override
  ConsumerState<MeasurementGirthsBulkEntryScreen> createState() =>
      _MeasurementGirthsBulkEntryScreenState();
}

class _MeasurementGirthsBulkEntryScreenState
    extends ConsumerState<MeasurementGirthsBulkEntryScreen> {
  DateTime _selectedDate = _dateOnly(DateTime.now());
  final Map<String, TextEditingController> _controllers = {};
  Map<String, BodyMeasurement> _existingByType = {};
  Map<String, String> _errors = {};
  bool _isLoadingExisting = true;
  bool _isSubmitting = false;
  bool _hasScheduledInitialLoad = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String typeId) =>
      _controllers.putIfAbsent(typeId, TextEditingController.new);

  Future<void> _loadExisting(List<MeasurementType> girths) async {
    setState(() => _isLoadingExisting = true);
    final repository = ref.read(bodyMeasurementRepositoryProvider);
    final unitSystem =
        ref.read(appSettingsProvider).value?.unitSystem ?? UnitSystem.metric;
    final byType = <String, BodyMeasurement>{};
    for (final type in girths) {
      final existing = await repository.getByTypeAndDate(
        measurementTypeId: type.id,
        date: _selectedDate,
      );
      final controller = _controllerFor(type.id);
      if (existing != null) {
        byType[type.id] = existing;
        controller.text = measurementValueToDisplay(
          existing.valueMetric,
          type.unitKind,
          unitSystem,
        ).toStringAsFixed(1);
      } else {
        controller.text = '';
      }
    }
    if (!mounted) return;
    setState(() {
      _existingByType = byType;
      _errors = {};
      _isLoadingExisting = false;
    });
  }

  Future<void> _pickDate(List<MeasurementType> girths) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _selectedDate = _dateOnly(picked));
    await _loadExisting(girths);
  }

  Future<void> _save(List<MeasurementType> girths) async {
    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(bodyMeasurementServiceProvider);
    final unitSystem =
        ref.read(appSettingsProvider).value?.unitSystem ?? UnitSystem.metric;

    setState(() => _isSubmitting = true);
    final newErrors = <String, String>{};
    var anySaved = false;

    for (final type in girths) {
      final text = _controllerFor(type.id).text.trim();
      if (text.isEmpty) continue;
      final parsed = _unitConverter.parseDecimal(text);
      if (parsed == null) {
        newErrors[type.id] = l10n.measurementValueRequiredError;
        continue;
      }
      final valueMetric = measurementValueToMetric(
        parsed,
        type.unitKind,
        unitSystem,
      );
      final existing = _existingByType[type.id];
      final result = existing != null
          ? await service.update(existing: existing, valueMetric: valueMetric)
          : await service.create(
              measurementTypeId: type.id,
              date: _selectedDate,
              valueMetric: valueMetric,
            );
      result.fold((saved) {
        anySaved = true;
        _existingByType[type.id] = saved;
      }, (_) => newErrors[type.id] = l10n.saveMeasurementError);
    }

    if (!mounted) return;
    setState(() {
      _errors = newErrors;
      _isSubmitting = false;
    });
    if (newErrors.isEmpty) {
      context.pop(anySaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(measurementTypesListProvider(false));
    final unitSystem =
        ref.watch(appSettingsProvider).value?.unitSystem ?? UnitSystem.metric;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.measurementGirthsBulkEntryTitle)),
      body: typesAsync.when(
        data: (types) {
          final girths =
              types
                  .where(
                    (t) =>
                        t.isBuiltIn && t.unitKind == MeasurementUnitKind.length,
                  )
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

          if (!_hasScheduledInitialLoad && girths.isNotEmpty) {
            // Runs exactly once, the first time the type list arrives --
            // `_hasScheduledInitialLoad` (not `_isLoadingExisting`, which
            // `_loadExisting` itself flips back to true) guards against
            // scheduling a second, redundant concurrent load on every
            // rebuild while the first one is still in flight.
            _hasScheduledInitialLoad = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _loadExisting(girths),
            );
          }

          return Column(
            children: [
              ListTile(
                title: Text(l10n.measurementDateFieldLabel),
                subtitle: Text(formatShortDate(_selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () => _pickDate(girths),
              ),
              const Divider(height: 1),
              Expanded(
                child: _isLoadingExisting
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: girths.length,
                        itemBuilder: (context, index) {
                          final type = girths[index];
                          final unit = measurementUnitSuffix(
                            l10n,
                            type.unitKind,
                            unitSystem,
                          );
                          final label = measurementTypeLabel(l10n, type);
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(label)),
                                SizedBox(
                                  width: 100,
                                  child: Semantics(
                                    label: label,
                                    textField: true,
                                    child: TextField(
                                      controller: _controllerFor(type.id),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffixText: unit,
                                        errorText: _errors[type.id],
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: _isLoadingExisting || _isSubmitting
                        ? null
                        : () => _save(girths),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.actionSave),
                  ),
                ),
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
    );
  }
}
