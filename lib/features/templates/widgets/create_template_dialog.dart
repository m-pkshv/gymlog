import 'package:flutter/material.dart';

import '../../../core/app_error.dart';
import '../../../core/constants.dart';
import '../../../core/result.dart';
import '../../../domain/models/workout_template.dart';
import '../../../l10n/app_localizations.dart';

/// Create-template dialog (name only, DM 6.8), shared by S-12's FAB
/// ("create from scratch", `WorkoutTemplateService.create`), "Создать
/// шаблон" on a workout's "⋮" menu (S-02/S-03, TS 8 section 8,
/// `WorkoutTemplateService.createFromWorkout`), and "Дублировать" on a
/// template's own "⋮" menu (S-12, `WorkoutTemplateService.duplicate`) —
/// all three just need a name and an async function that turns it into a
/// `Result`, so [create] is injected rather than the dialog picking a
/// provider itself. [title] defaults to the generic "New template" wording;
/// "Дублировать" overrides it since "duplicate" isn't quite "new".
class CreateTemplateDialog extends StatefulWidget {
  const CreateTemplateDialog({
    super.key,
    this.initialName = '',
    this.title,
    required this.create,
  });

  final String initialName;
  final String? title;
  final Future<Result<WorkoutTemplate, AppError>> Function(String name) create;

  @override
  State<CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<CreateTemplateDialog> {
  late final TextEditingController _nameController;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    final result = await widget.create(_nameController.text);
    if (!mounted) return;
    result.fold((template) => Navigator.of(context).pop(template), (error) {
      setState(() {
        _isSubmitting = false;
        _error = l10n.createTemplateError;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title ?? l10n.createTemplateTitle),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        maxLength: WorkoutTemplateRules.maxNameLength,
        decoration: InputDecoration(
          labelText: l10n.templateNameLabel,
          errorText: _error,
        ),
        onChanged: (_) => setState(() {
          if (_error != null) _error = null;
        }),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
