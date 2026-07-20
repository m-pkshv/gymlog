import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';

void main() {
  late AppDatabase db;
  late AppSettingsRepositoryImpl settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = AppSettingsRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  test(
    'ensureInitialized creates the singleton row with showTags on by '
    'default (DM 6.12)',
    () async {
      await settings.ensureInitialized();
      final current = await settings.watchSettings().first;
      expect(current.showTags, isTrue);
    },
  );

  test('ensureInitialized is idempotent (does not overwrite an existing row)', () async {
    await settings.ensureInitialized();
    await settings.setShowTags(false);

    await settings.ensureInitialized();

    final current = await settings.watchSettings().first;
    expect(current.showTags, isFalse);
  });

  test('setShowTags updates the row, reflected in watchSettings', () async {
    await settings.ensureInitialized();

    await settings.setShowTags(false);
    expect((await settings.watchSettings().first).showTags, isFalse);

    await settings.setShowTags(true);
    expect((await settings.watchSettings().first).showTags, isTrue);
  });
}
