import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../measurement_type_labels.dart';

/// "Добавить замер…" dialog (S-14, DM 5.3): name + unit kind for a new
/// custom `MeasurementType`. [onCreate] is injected so this widget doesn't
/// depend on a provider directly, mirroring `CreateTemplateDialog`.
class CreateMeasurementTypeDialog extends StatefulWidget {
  const CreateMeasurementTypeDialog({super.key, required this.onCreate});

  final Future<bool> Function(String name, MeasurementUnitKind unitKind)
  onCreate;

  @override
  State<CreateMeasurementTypeDialog> createState() =>
      _CreateMeasurementTypeDialogState();
}

class _CreateMeasurementTypeDialogState
    extends State<CreateMeasurementTypeDialog> {
  final _nameController = TextEditingController();
  MeasurementUnitKind _unitKind = MeasurementUnitKind.length;
  String? _error;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final success = await widget.onCreate(_nameController.text, _unitKind);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isSubmitting = false;
      _error = l10n.createMeasurementTypeError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.createMeasurementTypeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: MeasurementTypeRules.maxNameLength,
            decoration: InputDecoration(
              labelText: l10n.measurementTypeNameLabel,
              errorText: _error,
            ),
            onChanged: (_) => setState(() {
              if (_error != null) _error = null;
            }),
          ),
          DropdownButtonFormField<MeasurementUnitKind>(
            initialValue: _unitKind,
            decoration: InputDecoration(
              labelText: l10n.measurementTypeUnitKindLabel,
            ),
            items: MeasurementUnitKind.values
                .map(
                  (kind) => DropdownMenuItem(
                    value: kind,
                    child: Text(measurementUnitKindLabel(l10n, kind)),
                  ),
                )
                .toList(),
            onChanged: (kind) {
              if (kind != null) setState(() => _unitKind = kind);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _isNameValid && !_isSubmitting ? _submit : null,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.actionCreate),
        ),
      ],
    );
  }
}
