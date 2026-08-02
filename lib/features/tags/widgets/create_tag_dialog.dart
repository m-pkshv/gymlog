import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../workout_editor/widgets/workout_tag_chip.dart';

/// Create-tag dialog (DM 6.3). Moved out of the workout tag picker sheet
/// (Stage 10, owner-reported): the app-wide tag management screen (Ещё →
/// Теги) is now the only place a tag can be created — the picker sheet
/// inside a workout only assigns/unassigns existing tags, so create and
/// assign controls don't crowd (and get confused with) one sheet.
class CreateTagDialog extends ConsumerStatefulWidget {
  const CreateTagDialog({super.key});

  @override
  ConsumerState<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends ConsumerState<CreateTagDialog> {
  final _nameController = TextEditingController();
  String _colorHex = workoutTagColorPalette.first;
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
    final result = await ref
        .read(workoutTagServiceProvider)
        .create(name: _nameController.text, colorHex: _colorHex);
    if (!mounted) return;
    result.fold((tag) => Navigator.of(context).pop(tag), (error) {
      setState(() {
        _isSubmitting = false;
        _error = l10n.createTagError;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.createTagTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: WorkoutTagRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.tagNameLabel,
              errorText: _error,
            ),
            onChanged: (_) => setState(() {
              if (_error != null) _error = null;
            }),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final colorHex in workoutTagColorPalette)
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _colorHex = colorHex),
                  child: CircleAvatar(
                    backgroundColor: tagColor(colorHex),
                    radius: 14,
                    // Fixed white, not `Theme.of(context)`, on purpose: the
                    // swatch itself is `colorHex` from the tag palette
                    // (UX-1), not a themed surface -- the checkmark needs
                    // to contrast against that arbitrary fixed color, not
                    // against the current theme.
                    child: _colorHex == colorHex
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
        ],
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
