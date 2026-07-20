import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';

/// S-08 form, Stage 1 scope: just a name and a type
/// (02_DEVELOPMENT_PLAN.md, Stage 1). Muscle groups, equipment, effort
/// metric, description and the YouTube link arrive with the full form in
/// Stage 2.
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _nameController = TextEditingController();
  ExerciseType _selectedType = ExerciseType.strength;
  bool _isSubmitting = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.exerciseNameRequiredError);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final created = await ref
          .read(exerciseRepositoryProvider)
          .create(name: name, exerciseType: _selectedType);
      if (mounted) context.pop(created);
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to create exercise',
            error: error,
            stackTrace: stackTrace,
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.createExerciseError)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createExerciseTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: l10n.exerciseNameLabel,
                  errorText: _nameError,
                ),
                onChanged: (_) {
                  setState(() {
                    if (_nameError != null) _nameError = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseType>(
                initialValue: _selectedType,
                decoration: InputDecoration(labelText: l10n.exerciseTypeLabel),
                items: ExerciseType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(exerciseTypeIcon(type), size: 20),
                            const SizedBox(width: 8),
                            Text(exerciseTypeLabel(l10n, type)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (type) {
                  if (type != null) setState(() => _selectedType = type);
                },
              ),
              const Spacer(),
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
          ),
        ),
      ),
    );
  }
}
