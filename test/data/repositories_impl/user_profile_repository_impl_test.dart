import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/user_profile_repository_impl.dart';

void main() {
  late AppDatabase db;
  late UserProfileRepositoryImpl profile;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    profile = UserProfileRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'ensureInitialized creates the singleton row with every field empty '
    '(DM 6.15)',
    () async {
      await profile.ensureInitialized();
      final current = await profile.watchProfile().first;
      expect(current.nickname, isNull);
      expect(current.firstName, isNull);
      expect(current.lastName, isNull);
      expect(current.avatarPath, isNull);
    },
  );

  test(
    'ensureInitialized is idempotent (does not overwrite an existing row)',
    () async {
      await profile.ensureInitialized();
      await profile.setNickname('Max');

      await profile.ensureInitialized();

      final current = await profile.watchProfile().first;
      expect(current.nickname, 'Max');
    },
  );

  test('setNickname updates the row, reflected in watchProfile', () async {
    await profile.ensureInitialized();

    await profile.setNickname('Max');
    expect((await profile.watchProfile().first).nickname, 'Max');

    await profile.setNickname(null);
    expect((await profile.watchProfile().first).nickname, isNull);
  });

  test('setFirstName updates the row, reflected in watchProfile', () async {
    await profile.ensureInitialized();

    await profile.setFirstName('Maksim');
    expect((await profile.watchProfile().first).firstName, 'Maksim');
  });

  test('setLastName updates the row, reflected in watchProfile', () async {
    await profile.ensureInitialized();

    await profile.setLastName('Pekshev');
    expect((await profile.watchProfile().first).lastName, 'Pekshev');
  });

  test('setAvatarPath updates the row, reflected in watchProfile', () async {
    await profile.ensureInitialized();

    await profile.setAvatarPath('/tmp/avatar.jpg');
    expect(
      (await profile.watchProfile().first).avatarPath,
      '/tmp/avatar.jpg',
    );

    await profile.setAvatarPath(null);
    expect((await profile.watchProfile().first).avatarPath, isNull);
  });
}
