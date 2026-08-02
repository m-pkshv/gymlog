import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/user_profile.dart';
import '../../l10n/app_localizations.dart';
import '../../services/user_profile_service.dart';

/// User profile screen (Stage 11, 06_DATA_MODEL.md, section 6.15) --
/// nickname/first/last name and an avatar photo, so far only used to
/// personalize a future PDF workout export (not built yet).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: profileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Center(
              // Keyed on `updatedAt`, not just `avatarPath`: re-picking a
              // photo always overwrites the same fixed file
              // (UserProfileService.avatarFileName), so `avatarPath` itself
              // never changes -- Flutter's `Image` widget compares its new
              // `FileImage` against the old one by *value* (same path =
              // "no change") and skips re-resolving entirely, regardless of
              // the `evict()` call below. A changing key forces the avatar
              // subtree to be torn down and rebuilt from scratch instead.
              child: _ProfileAvatar(
                key: ValueKey(profile.updatedAt),
                avatarPath: profile.avatarPath,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProfileNameFields(profile: profile),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.profileLoadError,
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
      ),
    );
  }
}

enum _AvatarAction { choosePhoto, takePhoto, removePhoto }

/// The avatar photo -- tap opens a sheet to choose a new one from the
/// gallery, take a new one with the camera, or (if one is already set)
/// remove it. All file I/O and the picker call itself live in
/// `UserProfileService`, never here (05_AI_INSTRUCTIONS.md, rule 6).
class _ProfileAvatar extends ConsumerWidget {
  const _ProfileAvatar({super.key, required this.avatarPath});

  final String? avatarPath;

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    // The sheet only ever returns *which* action was picked (a plain,
    // synchronous `Navigator.pop(value)`, same idiom as the app's
    // confirmation dialogs) -- the actual async work (file I/O, the
    // picker, the DB write) runs afterward, once the sheet has already
    // fully closed, never interleaved with the sheet's own Navigator.
    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.profileChoosePhotoAction),
                onTap: () => Navigator.of(
                  sheetContext,
                ).pop(_AvatarAction.choosePhoto),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(l10n.profileTakePhotoAction),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_AvatarAction.takePhoto),
              ),
              if (avatarPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.profileRemovePhotoAction),
                  onTap: () => Navigator.of(
                    sheetContext,
                  ).pop(_AvatarAction.removePhoto),
                ),
            ],
          ),
        );
      },
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case _AvatarAction.choosePhoto:
        await _pickPhoto(context, ref, source: ImageSource.gallery);
      case _AvatarAction.takePhoto:
        await _pickPhoto(context, ref, source: ImageSource.camera);
      case _AvatarAction.removePhoto:
        await ref.read(userProfileServiceProvider).removeAvatar(avatarPath);
    }
  }

  Future<void> _pickPhoto(
    BuildContext context,
    WidgetRef ref, {
    required ImageSource source,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final documentsDir = await getApplicationDocumentsDirectory();
    final storageDirectory = Directory('${documentsDir.path}/profile');
    final result = await ref
        .read(userProfileServiceProvider)
        .pickAndSetAvatar(storageDirectory: storageDirectory, source: source);
    if (!context.mounted) return;
    final error = result.errorOrNull();
    if (error != null) {
      ref
          .read(loggerProvider)
          .error('Failed to set the profile avatar', error: error);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.profileAvatarError)));
      return;
    }
    if (result.getOrNull() == true) {
      // Re-picking always overwrites the same fixed file name
      // (UserProfileService.avatarFileName), but Flutter's ImageCache keys
      // a FileImage purely by its path, not by file content/mtime -- left
      // alone, the stale decoded bytes stay cached under that path until
      // the widget happens to get disposed and recreated (e.g. leaving and
      // re-entering this screen), which is the bug the owner reported.
      // Evicting here forces a fresh decode on the very next paint.
      final targetPath =
          '${storageDirectory.path}/${UserProfileService.avatarFileName}';
      await FileImage(File(targetPath)).evict();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showActions(context, ref),
      child: CircleAvatar(
        radius: 48,
        backgroundImage: avatarPath != null
            ? FileImage(File(avatarPath!))
            : null,
        // The stored file could be missing/corrupt (deleted externally, a
        // restored backup that lost it, etc.) -- fail quietly to the
        // background color instead of an uncaught decode error.
        onBackgroundImageError: avatarPath != null
            ? (error, stackTrace) => ref
                  .read(loggerProvider)
                  .error(
                    'Failed to load the profile avatar',
                    error: error,
                    stackTrace: stackTrace,
                  )
            : null,
        child: avatarPath == null
            ? const Icon(Icons.person_outline, size: 48)
            : null,
      ),
    );
  }
}

/// Nickname/first/last name -- same "flush on blur, no per-keystroke
/// debounce" convention as `_RestTimerSecondsField` on the Settings screen:
/// this is an infrequently-edited settings-like field, not workout data
/// under TS 5's autosave requirement, so a plain commit-on-blur is enough.
/// All three fields share one commit (`UserProfileService.updateProfile`
/// always writes all three together), so losing focus on any one of them
/// flushes the current state of all three.
class _ProfileNameFields extends ConsumerStatefulWidget {
  const _ProfileNameFields({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_ProfileNameFields> createState() =>
      _ProfileNameFieldsState();
}

class _ProfileNameFieldsState extends ConsumerState<_ProfileNameFields> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final FocusNode _nicknameFocus;
  late final FocusNode _firstNameFocus;
  late final FocusNode _lastNameFocus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(
      text: widget.profile.nickname ?? '',
    );
    _firstNameController = TextEditingController(
      text: widget.profile.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.profile.lastName ?? '',
    );
    // Each node checks its *own* current focus, not `_anyFocused` -- by the
    // time any focus-change listener fires, the whole focus tree has
    // already updated, so tabbing from one field straight into the next
    // (nickname -> first name via "next") would otherwise see the *next*
    // field already focused and skip the commit entirely.
    _nicknameFocus = FocusNode()
      ..addListener(() {
        if (!_nicknameFocus.hasFocus) _commit();
      });
    _firstNameFocus = FocusNode()
      ..addListener(() {
        if (!_firstNameFocus.hasFocus) _commit();
      });
    _lastNameFocus = FocusNode()
      ..addListener(() {
        if (!_lastNameFocus.hasFocus) _commit();
      });
  }

  bool get _anyFocused =>
      _nicknameFocus.hasFocus ||
      _firstNameFocus.hasFocus ||
      _lastNameFocus.hasFocus;

  @override
  void didUpdateWidget(covariant _ProfileNameFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_anyFocused) return;
    if (widget.profile.nickname != oldWidget.profile.nickname) {
      _nicknameController.text = widget.profile.nickname ?? '';
    }
    if (widget.profile.firstName != oldWidget.profile.firstName) {
      _firstNameController.text = widget.profile.firstName ?? '';
    }
    if (widget.profile.lastName != oldWidget.profile.lastName) {
      _lastNameController.text = widget.profile.lastName ?? '';
    }
  }

  Future<void> _commit() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await ref
        .read(userProfileServiceProvider)
        .updateProfile(
          nickname: _nicknameController.text,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
        );
    if (!mounted) return;
    setState(() {
      _error = result.errorOrNull() != null
          ? l10n.profileNameLengthError
          : null;
    });
  }

  @override
  void dispose() {
    // `FocusNode.dispose()` already clears its own listeners -- no matching
    // `removeListener` needed for the anonymous closures added in
    // `initState`.
    _nicknameFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _nicknameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: TextField(
            controller: _nicknameController,
            focusNode: _nicknameFocus,
            maxLength: UserProfileRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.profileNicknameLabel),
            textInputAction: TextInputAction.next,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: TextField(
            controller: _firstNameController,
            focusNode: _firstNameFocus,
            maxLength: UserProfileRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.profileFirstNameLabel,
            ),
            textInputAction: TextInputAction.next,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: TextField(
            controller: _lastNameController,
            focusNode: _lastNameFocus,
            maxLength: UserProfileRules.maxNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.profileLastNameLabel,
              errorText: _error,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
          ),
        ),
      ],
    );
  }
}
