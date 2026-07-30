import 'package:drift/drift.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../database.dart' as drift;
import '../mappers/user_profile_mapper.dart';

const _singletonId = 'singleton';

/// Drift-backed `UserProfileRepository` (06_DATA_MODEL.md, section 6.15).
class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._db);

  final drift.AppDatabase _db;

  @override
  Future<void> ensureInitialized() async {
    final existing = await (_db.select(
      _db.userProfileTable,
    )..where((t) => t.id.equals(_singletonId))).getSingleOrNull();
    if (existing != null) return;
    await _db
        .into(_db.userProfileTable)
        .insert(
          drift.UserProfileTableCompanion.insert(
            id: _singletonId,
            updatedAt: DateTime.now().toUtc().toIso8601String(),
          ),
        );
  }

  @override
  Stream<UserProfile> watchProfile() {
    final query = _db.select(
      _db.userProfileTable,
    )..where((t) => t.id.equals(_singletonId));
    return query.watchSingle().map((row) => row.toDomain());
  }

  @override
  Future<void> setNickname(String? value) => _write(
    drift.UserProfileTableCompanion(nickname: Value(value)),
  );

  @override
  Future<void> setFirstName(String? value) => _write(
    drift.UserProfileTableCompanion(firstName: Value(value)),
  );

  @override
  Future<void> setLastName(String? value) => _write(
    drift.UserProfileTableCompanion(lastName: Value(value)),
  );

  @override
  Future<void> setAvatarPath(String? value) => _write(
    drift.UserProfileTableCompanion(avatarPath: Value(value)),
  );

  Future<void> _write(drift.UserProfileTableCompanion partial) async {
    await (_db.update(
      _db.userProfileTable,
    )..where((t) => t.id.equals(_singletonId))).write(
      partial.copyWith(
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }
}
