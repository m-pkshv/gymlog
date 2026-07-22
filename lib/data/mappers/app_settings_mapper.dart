import '../../core/units/unit_converter.dart';
import '../../domain/enums.dart';
import '../../domain/models/app_settings.dart';
import '../database.dart' as drift;

extension AppSettingsRowMapper on drift.AppSettingsRow {
  AppSettings toDomain() {
    return AppSettings(
      showTags: showTags,
      defaultRestTimerSec: defaultRestTimerSec,
      restTimerAutoStart: restTimerAutoStart,
      unitSystem: UnitSystem.values.byName(unitSystem),
      theme: AppTheme.values.byName(theme),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
