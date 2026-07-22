import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';

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

  test(
    'ensureInitialized creates the singleton row with theme = system by '
    'default (DM 6.12, Stage 9)',
    () async {
      await settings.ensureInitialized();
      final current = await settings.watchSettings().first;
      expect(current.theme, AppTheme.system);
    },
  );

  test('setTheme updates the row, reflected in watchSettings', () async {
    await settings.ensureInitialized();

    await settings.setTheme(AppTheme.dark);
    expect((await settings.watchSettings().first).theme, AppTheme.dark);

    await settings.setTheme(AppTheme.light);
    expect((await settings.watchSettings().first).theme, AppTheme.light);
  });

  test(
    'ensureInitialized creates the singleton row with locale = system by '
    'default (DM 6.12, Stage 9)',
    () async {
      await settings.ensureInitialized();
      final current = await settings.watchSettings().first;
      expect(current.locale, AppLocale.system);
    },
  );

  test('setLocale updates the row, reflected in watchSettings', () async {
    await settings.ensureInitialized();

    await settings.setLocale(AppLocale.ru);
    expect((await settings.watchSettings().first).locale, AppLocale.ru);

    await settings.setLocale(AppLocale.en);
    expect((await settings.watchSettings().first).locale, AppLocale.en);
  });

  test(
    'ensureInitialized creates the singleton row with defaultRestTimerSec = '
    '120 and restTimerAutoStart = true by default (DM 6.12, Q-4)',
    () async {
      await settings.ensureInitialized();
      final current = await settings.watchSettings().first;
      expect(current.defaultRestTimerSec, 120);
      expect(current.restTimerAutoStart, isTrue);
    },
  );

  test(
    'setDefaultRestTimerSec updates the row, reflected in watchSettings',
    () async {
      await settings.ensureInitialized();

      await settings.setDefaultRestTimerSec(90);
      expect(
        (await settings.watchSettings().first).defaultRestTimerSec,
        90,
      );
    },
  );

  test(
    'setRestTimerAutoStart updates the row, reflected in watchSettings',
    () async {
      await settings.ensureInitialized();

      await settings.setRestTimerAutoStart(false);
      expect(
        (await settings.watchSettings().first).restTimerAutoStart,
        isFalse,
      );
    },
  );
}
