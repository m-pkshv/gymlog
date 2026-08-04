import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../core/app_error.dart';
import '../core/result.dart';

/// Picker + on-disk lifecycle for a user-created exercise's own icon
/// (catalog list, S-06) and large photo (detail card, S-07) -- Stage 12/
/// redesign_v2, owner-requested. Mirrors `UserProfileService`'s avatar
/// handling: all file I/O and the picker call live here, never in the UI
/// (05_AI_INSTRUCTIONS.md, rule 6). Unlike the profile's single fixed
/// `avatarFileName` (only one profile ever exists), the file name here is
/// keyed by exercise id, so every exercise gets its own icon/photo file;
/// re-picking still overwrites that same fixed path rather than
/// accumulating orphans.
class ExerciseImageService {
  ExerciseImageService(this._picker);

  final ImagePicker _picker;

  /// Opens [source] and returns the picked image's raw bytes, already
  /// downsampled to [maxDimensionPx]/[qualityPercent] by the picker itself.
  /// `Ok(null)` means the user cancelled the picker, not an error.
  Future<Result<Uint8List?, AppError>> pickBytes({
    required ImageSource source,
    required int maxDimensionPx,
    required int qualityPercent,
  }) async {
    final XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        maxWidth: maxDimensionPx.toDouble(),
        maxHeight: maxDimensionPx.toDouble(),
        imageQuality: qualityPercent,
      );
    } catch (error) {
      return Err(UnknownError('Failed to open the image picker', error));
    }
    if (picked == null) return const Ok(null);
    try {
      return Ok(await picked.readAsBytes());
    } catch (error) {
      return Err(UnknownError('Failed to read the picked image', error));
    }
  }

  /// Writes [bytes] under `<directory>/<exerciseId>_icon.jpg`, creating
  /// [directory] if it doesn't exist yet, and returns the path.
  Future<String> writeIcon(
    Directory directory,
    String exerciseId,
    Uint8List bytes,
  ) => _write(directory, '${exerciseId}_icon.jpg', bytes);

  /// Writes [bytes] under `<directory>/<exerciseId>_photo.jpg`.
  Future<String> writeImage(
    Directory directory,
    String exerciseId,
    Uint8List bytes,
  ) => _write(directory, '${exerciseId}_photo.jpg', bytes);

  Future<String> _write(
    Directory directory,
    String fileName,
    Uint8List bytes,
  ) async {
    await directory.create(recursive: true);
    final path = '${directory.path}/$fileName';
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  /// Deletes the file at [path], if any -- a no-op for `null` or an
  /// already-missing file. Used both when the owner explicitly removes an
  /// icon/photo and when the exercise itself is deleted (DM 10).
  Future<void> deleteFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
