import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/reference_data_ids.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';
import 'reference_data_labels.dart';

/// S-08 form (06_DATA_MODEL.md, section 6.1), full field set: name, type,
/// primary/secondary muscle groups, equipment, effort metric (strength
/// only), description, YouTube link. Only [name] is required. exerciseType
/// re-editing/locking and archive/delete actions belong to the edit flow
/// (S-07), not this create-only form.
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  ExerciseType _selectedType = ExerciseType.strength;
  EffortMetric _effortMetric = EffortMetric.none;
  String? _primaryMuscleGroupId;
  String? _equipmentId;
  final Set<String> _secondaryMuscleGroupIds = {};
  bool _isSubmitting = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  bool get _isNameValid => _nameController.text.trim().isNotEmpty;

  /// DM 6.1: a malformed link is a soft warning, never blocks saving.
  bool get _youtubeUrlLooksValid {
    final input = _youtubeUrlController.text.trim();
    if (input.isEmpty) return true;
    final uri = Uri.tryParse(input);
    if (uri == null || !uri.isScheme('HTTP') && !uri.isScheme('HTTPS')) {
      return false;
    }
    return uri.host == 'youtube.com' ||
        uri.host == 'www.youtube.com' ||
        uri.host == 'youtu.be';
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.exerciseNameRequiredError);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final description = _descriptionController.text.trim();
      final youtubeUrl = _youtubeUrlController.text.trim();
      final created = await ref
          .read(exerciseRepositoryProvider)
          .create(
            name: name,
            exerciseType: _selectedType,
            description: description.isEmpty ? null : description,
            youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
            primaryMuscleGroupId: _primaryMuscleGroupId,
            equipmentId: _equipmentId,
            effortMetric: _selectedType == ExerciseType.strength
                ? _effortMetric
                : EffortMetric.none,
            secondaryMuscleGroupIds: _secondaryMuscleGroupIds.toList(),
          );
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
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
                    decoration: InputDecoration(
                      labelText: l10n.exerciseTypeLabel,
                    ),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: _primaryMuscleGroupId,
                    decoration: InputDecoration(
                      labelText: l10n.exercisePrimaryMuscleLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.exerciseNotSpecified),
                      ),
                      for (final id in muscleGroupIds)
                        DropdownMenuItem(
                          value: id,
                          child: Text(muscleGroupLabel(l10n, id)),
                        ),
                    ],
                    onChanged: (id) =>
                        setState(() => _primaryMuscleGroupId = id),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.exerciseSecondaryMusclesLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final id in muscleGroupIds)
                        FilterChip(
                          label: Text(muscleGroupLabel(l10n, id)),
                          selected: _secondaryMuscleGroupIds.contains(id),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _secondaryMuscleGroupIds.add(id);
                            } else {
                              _secondaryMuscleGroupIds.remove(id);
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    initialValue: _equipmentId,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseEquipmentLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.exerciseNotSpecified),
                      ),
                      for (final id in equipmentIds)
                        DropdownMenuItem(
                          value: id,
                          child: Text(equipmentLabel(l10n, id)),
                        ),
                    ],
                    onChanged: (id) => setState(() => _equipmentId = id),
                  ),
                  if (_selectedType == ExerciseType.strength) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<EffortMetric>(
                      initialValue: _effortMetric,
                      decoration: InputDecoration(
                        labelText: l10n.exerciseEffortMetricLabel,
                      ),
                      items: EffortMetric.values
                          .map(
                            (metric) => DropdownMenuItem(
                              value: metric,
                              child: Text(effortMetricLabel(l10n, metric)),
                            ),
                          )
                          .toList(),
                      onChanged: (metric) {
                        if (metric != null) {
                          setState(() => _effortMetric = metric);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseDescriptionLabel,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _youtubeUrlController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseYoutubeUrlLabel,
                      helperText: _youtubeUrlLooksValid
                          ? null
                          : l10n.exerciseYoutubeUrlWarning,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: _isNameValid && !_isSubmitting ? _submit : null,
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
        ),
      ),
    );
  }
}
