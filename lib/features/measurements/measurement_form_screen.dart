import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/app_error.dart';
import '../../core/constants.dart';
import '../../core/date_format.dart';
import '../../core/result.dart';
import '../../core/units/unit_converter.dart';
import '../../domain/models/body_measurement.dart';
import '../../domain/models/measurement_type.dart';
import '../../l10n/app_localizations.dart';
import 'measurement_type_labels.dart';
import 'measurement_value_format.dart';

const _unitConverter = UnitConverter();

/// S-15 modal form: type, date (default today), value (display unit, D-5),
/// comment. On a same-day duplicate for the chosen type (DM 6.9), prompts
/// "Заменить существующее значение?" before overwriting instead of creating
/// a second entry.
class MeasurementFormScreen extends ConsumerStatefulWidget {
  const MeasurementFormScreen({super.key, this.initialTypeId});

  /// Preselects the type dropdown — e.g. the type of the tab/screen the "+"
  /// was pressed from. Still changeable by the user (04_UI_UX_SPEC.md S-14:
  /// "тип" is a field of the form itself, not fixed by navigation context).
  final String? initialTypeId;

  @override
  ConsumerState<MeasurementFormScreen> createState() =>
      _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends ConsumerState<MeasurementFormScreen> {
  final _valueController = TextEditingController();
  final _commentController = TextEditingController();
  String? _selectedTypeId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  String? _valueError;
  List<MeasurementType> _availableTypes = const [];

  @override
  void initState() {
    super.initState();
    _selectedTypeId = widget.initialTypeId;
    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  MeasurementType? _findType(List<MeasurementType> types, String? id) {
    if (id == null) return null;
    for (final type in types) {
      if (type.id == id) return type;
    }
    return null;
  }

  List<MeasurementType> _sorted(List<MeasurementType> types) {
    final copy = [...types];
    copy.sort((a, b) {
      if (a.isBuiltIn != b.isBuiltIn) return a.isBuiltIn ? -1 : 1;
      if (a.isBuiltIn) return a.sortOrder.compareTo(b.sortOrder);
      return (a.nameCustom ?? '').toLowerCase().compareTo(
        (b.nameCustom ?? '').toLowerCase(),
      );
    });
    return copy;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final type = _findType(_availableTypes, _selectedTypeId);
    if (type == null) return;

    final parsed = _unitConverter.parseDecimal(_valueController.text);
    if (parsed == null) {
      setState(() => _valueError = l10n.measurementValueRequiredError);
      return;
    }
    setState(() => _valueError = null);

    final valueMetric = measurementValueToMetric(
      parsed,
      type.unitKind,
      ref.read(appSettingsProvider).value?.unitSystem ?? UnitSystem.metric,
    );
    final comment = _commentController.text.trim();
    final service = ref.read(bodyMeasurementServiceProvider);

    try {
      // Checked (and, if needed, confirmed by the user) *before* showing any
      // submitting spinner: an indeterminate `CircularProgressIndicator`
      // never stops animating while the confirm dialog waits for the user,
      // which would make a test's `pumpAndSettle()` hang forever waiting for
      // it to settle before it ever gets to tap the dialog's own button.
      final existing = await service.findExistingForDay(
        measurementTypeId: type.id,
        date: _selectedDate,
      );
      if (existing != null) {
        final confirmed = await _confirmReplace(existing, type);
        if (confirmed != true) return;
      }
      if (mounted) setState(() => _isSubmitting = true);

      final result = existing != null
          ? await service.update(
              existing: existing,
              valueMetric: valueMetric,
              comment: comment.isEmpty ? null : comment,
            )
          : await service.create(
              measurementTypeId: type.id,
              date: _selectedDate,
              valueMetric: valueMetric,
              comment: comment.isEmpty ? null : comment,
            );
      _handleResult(result, l10n);
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to save measurement',
            error: error,
            stackTrace: stackTrace,
          );
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveMeasurementError)));
      }
    }
  }

  void _handleResult(
    Result<BodyMeasurement, AppError> result,
    AppLocalizations l10n,
  ) {
    if (!mounted) return;
    result.fold((_) => context.pop(true), (_) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.saveMeasurementError)));
    });
  }

  Future<bool?> _confirmReplace(
    BodyMeasurement existing,
    MeasurementType type,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(appSettingsProvider).value;
    final unitSystem = settings?.unitSystem ?? UnitSystem.metric;
    final oldValue = measurementValueToDisplay(
      existing.valueMetric,
      type.unitKind,
      unitSystem,
    );
    final unit = measurementUnitSuffix(l10n, type.unitKind, unitSystem);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.replaceMeasurementConfirmTitle),
        content: Text(
          l10n.replaceMeasurementConfirmMessage(
            oldValue.toStringAsFixed(1),
            unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.replaceMeasurementConfirmAction),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typesAsync = ref.watch(measurementTypesListProvider(false));
    final settingsAsync = ref.watch(appSettingsProvider);
    final unitSystem = settingsAsync.value?.unitSystem ?? UnitSystem.metric;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.measurementFormTitle)),
      body: SafeArea(
        child: typesAsync.when(
          data: (types) {
            final sorted = _sorted(types);
            _availableTypes = sorted;
            final ids = sorted.map((t) => t.id).toSet();
            final currentTypeId =
                (_selectedTypeId != null && ids.contains(_selectedTypeId))
                ? _selectedTypeId
                : (sorted.isNotEmpty ? sorted.first.id : null);
            final currentType = _findType(sorted, currentTypeId);
            final unit = currentType == null
                ? ''
                : measurementUnitSuffix(l10n, currentType.unitKind, unitSystem);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: currentTypeId,
                        decoration: InputDecoration(
                          labelText: l10n.measurementTypeFieldLabel,
                        ),
                        items: [
                          for (final type in sorted)
                            DropdownMenuItem(
                              value: type.id,
                              child: Text(measurementTypeLabel(l10n, type)),
                            ),
                        ],
                        onChanged: (id) => setState(() => _selectedTypeId = id),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.measurementDateFieldLabel),
                        subtitle: Text(formatShortDate(_selectedDate)),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: _pickDate,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _valueController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.measurementValueFieldLabel,
                          suffixText: unit,
                          errorText: _valueError,
                        ),
                        onChanged: (_) {
                          if (_valueError != null) {
                            setState(() => _valueError = null);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        maxLength: CommentLengthLimits.bodyMeasurement,
                        decoration: InputDecoration(
                          labelText: l10n.measurementCommentFieldLabel,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: FilledButton(
                    onPressed: currentTypeId != null && !_isSubmitting
                        ? _submit
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.actionCreate),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(l10n.measurementsLoadError)),
        ),
      ),
    );
  }
}
