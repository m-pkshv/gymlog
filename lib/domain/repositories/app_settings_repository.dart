import '../../core/units/unit_converter.dart';
import '../enums.dart';
import '../models/app_settings.dart';

/// Storage contract for the singleton `AppSettings` row (06_DATA_MODEL.md,
/// section 6.12). [showTags] (Stage 3), [setUnitSystem] (Stage 6),
/// [setTheme] and [setLocale] (Stage 9, S-17) each have a writer.
abstract class AppSettingsRepository {
  /// Creates the singleton row with table defaults if it doesn't exist yet.
  /// Called once at app startup (`main.dart`), mirroring `SeedRunner` —
  /// [watchSettings] assumes the row already exists.
  Future<void> ensureInitialized();

  Stream<AppSettings> watchSettings();

  Future<void> setShowTags(bool value);

  Future<void> setUnitSystem(UnitSystem value);

  Future<void> setTheme(AppTheme value);

  Future<void> setLocale(AppLocale value);
}
