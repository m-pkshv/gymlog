import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../core/app_error.dart';
import '../core/constants.dart';
import '../core/result.dart';
import '../domain/repositories/user_profile_repository.dart';

/// Validation + avatar-file lifecycle for the singleton `UserProfile` row
/// (06_DATA_MODEL.md, section 6.15). The repository's setters just write
/// whatever they're given; this is the one place that enforces the name
/// length cap and owns the avatar file on disk -- no file I/O or picker
/// call happens in the UI layer (05_AI_INSTRUCTIONS.md, rule 6).
class UserProfileService {
  UserProfileService(this._repository, this._picker);

  final UserProfileRepository _repository;
  final ImagePicker _picker;

  /// Fixed name so re-picking always overwrites the same file instead of
  /// accumulating orphaned copies under [Directory.documents]/`profile/`.
  static const avatarFileName = 'avatar.jpg';

  /// DM 6.15: each field is optional, 0-60 chars. An empty/whitespace-only
  /// value is normalized to `null`, the same "empty is valid" convention
  /// already used for `Workout.name` (`WorkoutNameRules`).
  Future<Result<void, AppError>> updateProfile({
    String? nickname,
    String? firstName,
    String? lastName,
  }) async {
    final normalizedNickname = _normalize(nickname);
    final normalizedFirstName = _normalize(firstName);
    final normalizedLastName = _normalize(lastName);
    for (final value in [
      normalizedNickname,
      normalizedFirstName,
      normalizedLastName,
    ]) {
      if (value != null && value.length > UserProfileRules.maxNameLength) {
        return const Err(
          ValidationError(
            'Each name field must be at most '
            '${UserProfileRules.maxNameLength} characters',
          ),
        );
      }
    }
    await _repository.setNickname(normalizedNickname);
    await _repository.setFirstName(normalizedFirstName);
    await _repository.setLastName(normalizedLastName);
    return const Ok(null);
  }

  String? _normalize(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Opens the gallery/camera picker (per [source]) and, if the user picked
  /// something, copies it into [storageDirectory] under [avatarFileName] and
  /// stores that path. Returns `Ok(false)` (not an error) if the user
  /// cancelled the picker.
  Future<Result<bool, AppError>> pickAndSetAvatar({
    required Directory storageDirectory,
    required ImageSource source,
  }) async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: UserProfileRules.avatarMaxDimensionPx.toDouble(),
        maxHeight: UserProfileRules.avatarMaxDimensionPx.toDouble(),
        imageQuality: UserProfileRules.avatarQualityPercent,
      );
    } catch (error) {
      return Err(UnknownError('Failed to open the image picker', error));
    }
    if (picked == null) return const Ok(false);
    try {
      await storageDirectory.create(recursive: true);
      final targetPath = '${storageDirectory.path}/$avatarFileName';
      final bytes = await picked.readAsBytes();
      await File(targetPath).writeAsBytes(bytes, flush: true);
      await _repository.setAvatarPath(targetPath);
      return const Ok(true);
    } catch (error) {
      return Err(UnknownError('Failed to save the avatar image', error));
    }
  }

  /// Deletes the avatar file at [currentAvatarPath] (if it exists) and
  /// clears the stored path.
  Future<void> removeAvatar(String? currentAvatarPath) async {
    if (currentAvatarPath != null) {
      final file = File(currentAvatarPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _repository.setAvatarPath(null);
  }
}
