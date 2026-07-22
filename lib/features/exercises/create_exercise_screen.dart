import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/reference_data_ids.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';
import 'reference_data_labels.dart';

/// The two locales `ExerciseL10n` supports (DM 12) -- same set the table's
/// `CHECK` constraint enforces, kept as plain strings rather than mapped
/// through `AppLocale` since `system` isn't a valid translation target.
const _supportedLocalizationCodes = ['ru', 'en'];

/// One row in the exercise form's "Add localization" section (S-08,
/// Stage 10): an in-progress or already-saved translation for one locale.
/// Not written until [CreateExerciseScreen] submits -- mirrors the rest of
/// the form, which also only writes on "Create"/"Save".
class _LocalizationEntry {
  _LocalizationEntry({required this.locale, String name = '', String description = ''})
    : nameController = TextEditingController(text: name),
      descriptionController = TextEditingController(text: description);

  String locale;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

/// S-08 form (06_DATA_MODEL.md, section 6.1), full field set: name, type,
/// primary/secondary muscle groups, equipment, effort metric (strength
/// only), description, YouTube link. Only [name] is required.
///
/// Doubles as the S-07 "Edit" form when [exercise] is passed: fields are
/// pre-filled and saving calls `ExerciseService.update` instead of
/// `ExerciseRepository.create`. The exerciseType dropdown is disabled in
/// edit mode once `ExerciseService.canChangeType` says it's locked (DM 6.1:
/// at least one set has been logged against this exercise).
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key, this.exercise});

  /// When set, edits this exercise instead of creating a new one.
  final Exercise? exercise;

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
  bool _typeLocked = false;
  String? _nameError;
  final List<_LocalizationEntry> _localizations = [];
  Set<String> _initialLocales = const {};

  bool get _isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    if (exercise != null) {
      _nameController.text = exercise.name;
      _descriptionController.text = exercise.description ?? '';
      _youtubeUrlController.text = exercise.youtubeUrl ?? '';
      _selectedType = exercise.exerciseType;
      _effortMetric = exercise.effortMetric;
      _primaryMuscleGroupId = exercise.primaryMuscleGroupId;
      _equipmentId = exercise.equipmentId;
      _secondaryMuscleGroupIds.addAll(exercise.secondaryMuscleGroupIds);
      _loadTypeLock(exercise.id);
      _loadLocalizations(exercise.id);
    }
  }

  Future<void> _loadTypeLock(String exerciseId) async {
    final canChange = await ref
        .read(exerciseServiceProvider)
        .canChangeType(exerciseId);
    if (mounted) setState(() => _typeLocked = !canChange);
  }

  Future<void> _loadLocalizations(String exerciseId) async {
    final localizations = await ref
        .read(exerciseRepositoryProvider)
        .getLocalizations(exerciseId);
    if (!mounted) return;
    setState(() {
      _initialLocales = localizations.map((l) => l.locale).toSet();
      _localizations.addAll(
        localizations.map(
          (l) => _LocalizationEntry(
            locale: l.locale,
            name: l.name,
            description: l.description ?? '',
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _youtubeUrlController.dispose();
    for (final entry in _localizations) {
      entry.dispose();
    }
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

  void _addLocalization() {
    final used = _localizations.map((e) => e.locale).toSet();
    final nextLocale = _supportedLocalizationCodes.firstWhere(
      (code) => !used.contains(code),
      orElse: () => _supportedLocalizationCodes.first,
    );
    setState(() => _localizations.add(_LocalizationEntry(locale: nextLocale)));
  }

  void _removeLocalizationEntry(_LocalizationEntry entry) {
    setState(() {
      _localizations.remove(entry);
      entry.dispose();
    });
  }

  /// Upserts every entry with a non-empty name and removes any locale that
  /// was present when the form opened but no longer has one (deleted, or
  /// cleared to empty) -- DM 12. Called after the main exercise
  /// create/update already succeeded, using its (possibly new) id.
  Future<void> _saveLocalizations(String exerciseId) async {
    final repository = ref.read(exerciseRepositoryProvider);
    final currentLocales = <String>{};
    for (final entry in _localizations) {
      final name = entry.nameController.text.trim();
      if (name.isEmpty) continue;
      currentLocales.add(entry.locale);
      await repository.setLocalization(
        exerciseId: exerciseId,
        locale: entry.locale,
        name: name,
        description: entry.descriptionController.text.trim().isEmpty
            ? null
            : entry.descriptionController.text.trim(),
      );
    }
    for (final locale in _initialLocales.difference(currentLocales)) {
      await repository.removeLocalization(
        exerciseId: exerciseId,
        locale: locale,
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.exerciseNameRequiredError);
      return;
    }

    final existing = widget.exercise;
    final description = _descriptionController.text.trim();
    final youtubeUrl = _youtubeUrlController.text.trim();
    final effortMetric = _selectedType == ExerciseType.strength
        ? _effortMetric
        : EffortMetric.none;

    setState(() => _isSubmitting = true);
    try {
      if (existing == null) {
        final created = await ref
            .read(exerciseRepositoryProvider)
            .create(
              name: name,
              exerciseType: _selectedType,
              description: description.isEmpty ? null : description,
              youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
              primaryMuscleGroupId: _primaryMuscleGroupId,
              equipmentId: _equipmentId,
              effortMetric: effortMetric,
              secondaryMuscleGroupIds: _secondaryMuscleGroupIds.toList(),
            );
        await _saveLocalizations(created.id);
        if (mounted) context.pop(created);
        return;
      }

      final result = await ref
          .read(exerciseServiceProvider)
          .update(
            current: existing,
            name: name,
            exerciseType: _selectedType,
            description: description.isEmpty ? null : description,
            youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
            primaryMuscleGroupId: _primaryMuscleGroupId,
            equipmentId: _equipmentId,
            effortMetric: effortMetric,
            secondaryMuscleGroupIds: _secondaryMuscleGroupIds.toList(),
          );
      final updated = result.getOrNull();
      if (updated != null) {
        await _saveLocalizations(updated.id);
      }
      if (!mounted) return;
      result.fold(
        (updated) => context.pop(updated),
        (_) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.editExerciseError))),
      );
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to save exercise',
            error: error,
            stackTrace: stackTrace,
          );
      if (mounted) {
        final message = existing == null
            ? l10n.createExerciseError
            : l10n.editExerciseError;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editExerciseTitle : l10n.createExerciseTitle),
      ),
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
                    isExpanded: true,
                    initialValue: _selectedType,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseTypeLabel,
                      helperText: _typeLocked
                          ? l10n.exerciseTypeLockedHint
                          : null,
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
                    onChanged: _typeLocked
                        ? null
                        : (type) {
                            if (type != null) {
                              setState(() => _selectedType = type);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
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
                    isExpanded: true,
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
                      isExpanded: true,
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
                  const SizedBox(height: 24),
                  Text(
                    l10n.exerciseLocalizationSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final entry in _localizations)
                    _LocalizationEntryCard(
                      key: ObjectKey(entry),
                      entry: entry,
                      // Every other entry's locale is off-limits here so
                      // two entries can never target the same translation.
                      availableLocales: _supportedLocalizationCodes
                          .where(
                            (code) =>
                                code == entry.locale ||
                                !_localizations.any((e) => e.locale == code),
                          )
                          .toList(),
                      onLocaleChanged: (locale) =>
                          setState(() => entry.locale = locale),
                      onRemove: () => _removeLocalizationEntry(entry),
                      onChanged: () => setState(() {}),
                    ),
                  if (_localizations.length < _supportedLocalizationCodes.length)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        onPressed: _addLocalization,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.exerciseAddLocalizationAction),
                      ),
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
                    : Text(_isEditing ? l10n.actionSave : l10n.actionCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _localeLabel(AppLocalizations l10n, String code) {
  switch (code) {
    case 'ru':
      return l10n.settingsLanguageRu;
    case 'en':
      return l10n.settingsLanguageEn;
  }
  return code;
}

/// One row of the exercise form's "Add localization" section (DM 12,
/// Stage 10): a language picker plus that language's name/description,
/// with a button to drop the entry. Not written until the form submits.
class _LocalizationEntryCard extends StatelessWidget {
  const _LocalizationEntryCard({
    super.key,
    required this.entry,
    required this.availableLocales,
    required this.onLocaleChanged,
    required this.onRemove,
    required this.onChanged,
  });

  final _LocalizationEntry entry;
  final List<String> availableLocales;
  final ValueChanged<String> onLocaleChanged;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameMissing = entry.nameController.text.trim().isEmpty;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: entry.locale,
                    decoration: InputDecoration(
                      labelText: l10n.exerciseLocalizationLanguageLabel,
                    ),
                    items: [
                      for (final code in availableLocales)
                        DropdownMenuItem(
                          value: code,
                          child: Text(_localeLabel(l10n, code)),
                        ),
                    ],
                    onChanged: (code) {
                      if (code != null) onLocaleChanged(code);
                    },
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.exerciseRemoveLocalizationAction,
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.nameController,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.exerciseNameLabel,
                helperText: nameMissing
                    ? l10n.exerciseLocalizationNameRequiredError
                    : null,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: entry.descriptionController,
              maxLines: 3,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: l10n.exerciseDescriptionLabel,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
