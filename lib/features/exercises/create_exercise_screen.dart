import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/reference_data_ids.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../l10n/app_localizations.dart';
import '../../services/exercise_image_service.dart';
import 'exercise_type_labels.dart';
import 'reference_data_labels.dart';

/// Bottom-sheet actions for the icon/photo picker (Stage 12/redesign_v2,
/// owner-requested): gallery/camera pick a fresh image, "remove" clears
/// whatever's currently set (existing saved path or a not-yet-saved pick).
enum _PhotoPickAction { gallery, camera, remove }

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
/// `ExerciseService.create`. The exerciseType dropdown is disabled in
/// edit mode once `ExerciseService.canChangeType` says it's locked (DM 6.1:
/// at least one set has been logged against this exercise).
///
/// In create mode, [ownRoute] (this screen's own full path -- see
/// `AddExerciseScreen.addExerciseRoute`'s identical rationale) enables the
/// "Скопировать из..." button (S-08, Stage 10, owner-reported): pushes a
/// picker over any exercise, built-in or user-created, and prefills every
/// field from it, so a user who just wants a tweaked variant doesn't start
/// from a blank form. `null` simply hides that button (edit mode never
/// needs it).
class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key, this.exercise, this.ownRoute});

  /// When set, edits this exercise instead of creating a new one.
  final Exercise? exercise;

  /// This screen's own full route path, e.g. `/exercises/new` or
  /// `/workout/$id/add-exercise/new` -- create mode only, see the class doc.
  final String? ownRoute;

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

  // Icon/photo (Stage 12/redesign_v2, owner-requested): mirrors the rest of
  // the form -- nothing is written to disk or the DB until "Create"/"Save"
  // (see [_submit]). `_pickedIconBytes`/`_pickedImageBytes` hold a freshly
  // picked replacement not yet persisted; `_iconRemoved`/`_imageRemoved`
  // record an explicit "Remove photo" tap; `_existingIconPath`/
  // `_existingImagePath` are whatever was already saved (edit mode only).
  // A picked replacement always wins over "removed", which always wins
  // over the existing path -- exactly one of the three states applies at
  // save time (see [_resolveIconPath]/[_resolveImagePath]).
  Uint8List? _pickedIconBytes;
  bool _iconRemoved = false;
  String? _existingIconPath;
  Uint8List? _pickedImageBytes;
  bool _imageRemoved = false;
  String? _existingImagePath;

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
      _existingIconPath = exercise.customIconPath;
      _existingImagePath = exercise.customImagePath;
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

  /// Opens [ExerciseCopySourcePickerScreen] and, if the owner picks one,
  /// prefills every field from it (S-08, Stage 10, owner-reported) -- the
  /// same fields [initState] copies for edit mode, just triggered by a
  /// button instead of automatically at open. Localizations are
  /// deliberately not copied (a brand-new exercise doesn't inherit the
  /// source's translations); `_typeLocked` stays `false`, as it always is
  /// in create mode, so the type dropdown remains editable. Icon/photo
  /// (Stage 12/redesign_v2) aren't copied either, for the same reason --
  /// left untouched here, so a "tweaked variant" of an exercise starts
  /// with no image of its own rather than silently sharing the source's
  /// file.
  Future<void> _copyFrom() async {
    final ownRoute = widget.ownRoute;
    if (ownRoute == null) return;
    final source = await context.push<Exercise>('$ownRoute/copy-source');
    if (source == null || !mounted) return;
    setState(() {
      _nameController.text = source.name;
      _descriptionController.text = source.description ?? '';
      _youtubeUrlController.text = source.youtubeUrl ?? '';
      _selectedType = source.exerciseType;
      _effortMetric = source.effortMetric;
      _primaryMuscleGroupId = source.primaryMuscleGroupId;
      _equipmentId = source.equipmentId;
      _secondaryMuscleGroupIds
        ..clear()
        ..addAll(source.secondaryMuscleGroupIds);
      _nameError = null;
    });
  }

  /// Opens a bottom sheet (gallery/camera, plus "remove" when there's
  /// something to remove) for one of the two image slots and applies the
  /// result to local state via [onPicked]/[onRemoved] -- nothing touches
  /// disk or the DB here, matching the rest of the form (see the state
  /// fields' doc comment above).
  Future<void> _pickPhoto({
    required String title,
    required bool hasExisting,
    required int maxDimensionPx,
    required ValueChanged<Uint8List> onPicked,
    required VoidCallback onRemoved,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<_PhotoPickAction>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.exerciseChooseFromGalleryAction),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoPickAction.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.exerciseTakePhotoAction),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoPickAction.camera),
              ),
              if (hasExisting)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.exerciseRemovePhotoAction),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(_PhotoPickAction.remove),
                ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    if (action == _PhotoPickAction.remove) {
      onRemoved();
      return;
    }
    final source = action == _PhotoPickAction.gallery
        ? ImageSource.gallery
        : ImageSource.camera;
    final result = await ref
        .read(exerciseImageServiceProvider)
        .pickBytes(
          source: source,
          maxDimensionPx: maxDimensionPx,
          qualityPercent: ExerciseImageRules.qualityPercent,
        );
    if (!mounted) return;
    final error = result.errorOrNull();
    if (error != null) {
      ref
          .read(loggerProvider)
          .error('Failed to pick an exercise image', error: error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exercisePhotoError)));
      return;
    }
    final bytes = result.getOrNull();
    if (bytes != null) onPicked(bytes);
  }

  Future<void> _pickIcon() => _pickPhoto(
    title: AppLocalizations.of(context)!.exerciseIconLabel,
    hasExisting:
        _pickedIconBytes != null ||
        (!_iconRemoved && _existingIconPath != null),
    maxDimensionPx: ExerciseImageRules.iconMaxDimensionPx,
    onPicked: (bytes) => setState(() {
      _pickedIconBytes = bytes;
      _iconRemoved = false;
    }),
    onRemoved: () => setState(() {
      _pickedIconBytes = null;
      _iconRemoved = true;
    }),
  );

  Future<void> _pickImage() => _pickPhoto(
    title: AppLocalizations.of(context)!.exerciseImageLabel,
    hasExisting:
        _pickedImageBytes != null ||
        (!_imageRemoved && _existingImagePath != null),
    maxDimensionPx: ExerciseImageRules.imageMaxDimensionPx,
    onPicked: (bytes) => setState(() {
      _pickedImageBytes = bytes;
      _imageRemoved = false;
    }),
    onRemoved: () => setState(() {
      _pickedImageBytes = null;
      _imageRemoved = true;
    }),
  );

  /// A tappable, rounded-square image slot -- picked bytes (not yet saved)
  /// take priority over an explicit removal, which takes priority over
  /// whatever was already saved; a missing/corrupt existing file falls
  /// back to the placeholder icon instead of an uncaught decode error
  /// (same principle as the profile avatar's `onBackgroundImageError`).
  Widget _photoSlot({
    required Uint8List? pickedBytes,
    required bool removed,
    required String? existingPath,
    required double size,
    required IconData placeholderIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    Widget child;
    if (pickedBytes != null) {
      child = Image.memory(
        pickedBytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
      );
    } else if (!removed && existingPath != null) {
      child = Image.file(
        File(existingPath),
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            Icon(placeholderIcon, size: size * 0.45, color: scheme.onSurfaceVariant),
      );
    } else {
      child = Icon(placeholderIcon, size: size * 0.45, color: scheme.onSurfaceVariant);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        color: scheme.surfaceContainerHighest,
        child: child,
      ),
    );
  }

  /// Resolves what [customIconPath]/[customImagePath] should be saved as,
  /// applying exactly one of: a freshly picked replacement (written to
  /// disk under [exerciseId], evicting the image cache so a same-path
  /// overwrite shows up immediately -- the same fix already applied to
  /// the profile avatar, Stage 11), an explicit removal (deletes the old
  /// file, if any), or leaving [existingPath] untouched. [resolveImagesDir]
  /// is only actually called (and so only ever touches
  /// `getApplicationDocumentsDirectory()`) when there's a fresh image to
  /// write -- the overwhelming majority of saves touch neither slot, and
  /// shouldn't pay for a directory lookup they don't need.
  Future<String?> _resolveImagePath({
    required ExerciseImageService imageService,
    required Future<Directory> Function() resolveImagesDir,
    required String exerciseId,
    required Uint8List? pickedBytes,
    required bool removed,
    required String? existingPath,
    required Future<String> Function(Directory, String, Uint8List) write,
  }) async {
    if (pickedBytes != null) {
      final imagesDir = await resolveImagesDir();
      final path = await write(imagesDir, exerciseId, pickedBytes);
      await FileImage(File(path)).evict();
      return path;
    }
    if (removed) {
      await imageService.deleteFile(existingPath);
      return null;
    }
    return existingPath;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l10n.exerciseNameRequiredError);
      return;
    }

    final existing = widget.exercise;
    final service = ref.read(exerciseServiceProvider);
    // Proactive inline check (Stage 10, owner-reported: "проверять среди
    // всех") -- `create`/`update` re-validate the same rule server-side
    // regardless, this just avoids a round-trip through the generic error
    // snackbar for the single most likely failure.
    if (await service.isNameTaken(name, excludeId: existing?.id)) {
      if (mounted) setState(() => _nameError = l10n.exerciseNameDuplicateError);
      return;
    }

    final description = _descriptionController.text.trim();
    final youtubeUrl = _youtubeUrlController.text.trim();
    final effortMetric = _selectedType == ExerciseType.strength
        ? _effortMetric
        : EffortMetric.none;

    setState(() => _isSubmitting = true);
    try {
      // Computed once here rather than left to the repository (Stage 12/
      // redesign_v2): a freshly picked icon/photo needs the exercise's
      // final id *before* create() returns, to name the file on disk.
      final exerciseId = existing?.id ?? const Uuid().v4();
      final imageService = ref.read(exerciseImageServiceProvider);
      Directory? imagesDirCache;
      Future<Directory> resolveImagesDir() async {
        return imagesDirCache ??= Directory(
          '${(await getApplicationDocumentsDirectory()).path}/exercise_images',
        );
      }

      final iconPath = await _resolveImagePath(
        imageService: imageService,
        resolveImagesDir: resolveImagesDir,
        exerciseId: exerciseId,
        pickedBytes: _pickedIconBytes,
        removed: _iconRemoved,
        existingPath: _existingIconPath,
        write: imageService.writeIcon,
      );
      final imagePath = await _resolveImagePath(
        imageService: imageService,
        resolveImagesDir: resolveImagesDir,
        exerciseId: exerciseId,
        pickedBytes: _pickedImageBytes,
        removed: _imageRemoved,
        existingPath: _existingImagePath,
        write: imageService.writeImage,
      );

      final result = existing == null
          ? await service.create(
              id: exerciseId,
              name: name,
              exerciseType: _selectedType,
              description: description.isEmpty ? null : description,
              youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
              primaryMuscleGroupId: _primaryMuscleGroupId,
              equipmentId: _equipmentId,
              effortMetric: effortMetric,
              secondaryMuscleGroupIds: _secondaryMuscleGroupIds.toList(),
              customIconPath: iconPath,
              customImagePath: imagePath,
            )
          : await service.update(
              current: existing,
              name: name,
              exerciseType: _selectedType,
              description: description.isEmpty ? null : description,
              youtubeUrl: youtubeUrl.isEmpty ? null : youtubeUrl,
              primaryMuscleGroupId: _primaryMuscleGroupId,
              equipmentId: _equipmentId,
              effortMetric: effortMetric,
              secondaryMuscleGroupIds: _secondaryMuscleGroupIds.toList(),
              customIconPath: iconPath,
              customImagePath: imagePath,
            );
      final saved = result.getOrNull();
      if (saved != null) {
        await _saveLocalizations(saved.id);
      }
      if (!mounted) return;
      result.fold(
        (saved) => context.pop(saved),
        (_) {
          final message = existing == null
              ? l10n.createExerciseError
              : l10n.editExerciseError;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
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
                    textCapitalization: TextCapitalization.words,
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
                  if (!_isEditing && widget.ownRoute != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _copyFrom,
                        icon: const Icon(Icons.content_copy),
                        label: Text(l10n.exerciseCopyFromAction),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            key: const Key('exercise-icon-slot'),
                            onTap: _pickIcon,
                            child: _photoSlot(
                              pickedBytes: _pickedIconBytes,
                              removed: _iconRemoved,
                              existingPath: _existingIconPath,
                              size: 56,
                              placeholderIcon: Icons.image_outlined,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.exerciseIconLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          GestureDetector(
                            key: const Key('exercise-image-slot'),
                            onTap: _pickImage,
                            child: _photoSlot(
                              pickedBytes: _pickedImageBytes,
                              removed: _imageRemoved,
                              existingPath: _existingImagePath,
                              size: 96,
                              placeholderIcon: Icons.landscape_outlined,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.exerciseImageLabel,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ],
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
                    textCapitalization: TextCapitalization.sentences,
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
              textCapitalization: TextCapitalization.words,
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
              textCapitalization: TextCapitalization.sentences,
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
