import '../../core/units/unit_converter.dart';
import '../models/app_settings.dart';

/// Storage contract for the singleton `AppSettings` row (06_DATA_MODEL.md,
/// section 6.12). Minimal for now — [showTags] (Stage 3) and [setUnitSystem]
/// (Stage 6, temporary toggle on the "More" placeholder so the D-5 ★
/// verification can actually be run before the real S-17 settings screen
/// exists — `ASSUMPTION(temp-unit-system-toggle)`); the rest of the row's
/// columns get their own methods once a feature needs them (Stage 9).
abstract class AppSettingsRepository {
  /// Creates the singleton row with table defaults if it doesn't exist yet.
  /// Called once at app startup (`main.dart`), mirroring `SeedRunner` —
  /// [watchSettings] assumes the row already exists.
  Future<void> ensureInitialized();

  Stream<AppSettings> watchSettings();

  Future<void> setShowTags(bool value);

  Future<void> setUnitSystem(UnitSystem value);
}
