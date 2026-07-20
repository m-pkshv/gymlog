import '../../domain/models/app_settings.dart';
import '../database.dart' as drift;

extension AppSettingsRowMapper on drift.AppSettingsRow {
  AppSettings toDomain() {
    return AppSettings(showTags: showTags, updatedAt: DateTime.parse(updatedAt));
  }
}
