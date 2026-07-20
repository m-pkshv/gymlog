import '../models/app_settings.dart';

/// Storage contract for the singleton `AppSettings` row (06_DATA_MODEL.md,
/// section 6.12). Minimal for now — only [showTags] (Stage 3 scope); the
/// rest of the row's columns get their own methods once a feature needs
/// them (Stage 9).
abstract class AppSettingsRepository {
  /// Creates the singleton row with table defaults if it doesn't exist yet.
  /// Called once at app startup (`main.dart`), mirroring `SeedRunner` —
  /// [watchSettings] assumes the row already exists.
  Future<void> ensureInitialized();

  Stream<AppSettings> watchSettings();

  Future<void> setShowTags(bool value);
}
