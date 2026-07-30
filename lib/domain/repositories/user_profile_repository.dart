import '../models/user_profile.dart';

/// Storage contract for the singleton `UserProfile` row (06_DATA_MODEL.md,
/// section 6.15). Mirrors `AppSettingsRepository`'s one-setter-per-field
/// convention -- each setter always writes exactly the value it's given
/// (including `null`, to clear a field), so there's no `copyWith`
/// null-vs-omitted ambiguity to worry about.
abstract class UserProfileRepository {
  /// Creates the singleton row (all fields empty) if it doesn't exist yet.
  /// Called once at app startup (`main.dart`), mirroring
  /// `AppSettingsRepository.ensureInitialized` -- [watchProfile] assumes the
  /// row already exists.
  Future<void> ensureInitialized();

  Stream<UserProfile> watchProfile();

  Future<void> setNickname(String? value);

  Future<void> setFirstName(String? value);

  Future<void> setLastName(String? value);

  Future<void> setAvatarPath(String? value);
}
