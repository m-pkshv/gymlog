import 'package:drift/drift.dart';

import '../../domain/models/app_settings.dart';
import '../../domain/repositories/app_settings_repository.dart';
import '../database.dart' as drift;
import '../mappers/app_settings_mapper.dart';

const _singletonId = 'singleton';

/// Drift-backed `AppSettingsRepository` (06_DATA_MODEL.md, section 6.12).
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  AppSettingsRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Future<void> ensureInitialized() async {
    final existing = await (_db.select(
      _db.appSettingsTable,
    )..where((t) => t.id.equals(_singletonId))).getSingleOrNull();
    if (existing != null) return;
    await _db
        .into(_db.appSettingsTable)
        .insert(
          drift.AppSettingsTableCompanion.insert(
            id: _singletonId,
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }

  @override
  Stream<AppSettings> watchSettings() {
    final query = _db.select(
      _db.appSettingsTable,
    )..where((t) => t.id.equals(_singletonId));
    return query.watchSingle().map((row) => row.toDomain());
  }

  @override
  Future<void> setShowTags(bool value) async {
    await (_db.update(
      _db.appSettingsTable,
    )..where((t) => t.id.equals(_singletonId))).write(
      drift.AppSettingsTableCompanion(
        showTags: Value(value),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }
}
