import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/locale.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('flutterLocale', () {
    test('AppLocale.system maps to null (OS-resolved)', () {
      expect(flutterLocale(AppLocale.system), isNull);
    });

    test('AppLocale.ru maps to Locale("ru")', () {
      expect(flutterLocale(AppLocale.ru), const Locale('ru'));
    });

    test('AppLocale.en maps to Locale("en")', () {
      expect(flutterLocale(AppLocale.en), const Locale('en'));
    });
  });

  group('resolvedLocaleCode', () {
    test('AppLocale.ru resolves to "ru" regardless of the OS locale', () {
      expect(resolvedLocaleCode(AppLocale.ru), 'ru');
    });

    test('AppLocale.en resolves to "en" regardless of the OS locale', () {
      expect(resolvedLocaleCode(AppLocale.en), 'en');
    });

    test('AppLocale.system resolves to "ru" when the OS locale is Russian', () {
      final binding = TestWidgetsFlutterBinding.instance;
      final original = binding.platformDispatcher.locale;
      binding.platformDispatcher.localeTestValue = const Locale('ru');
      addTearDown(() => binding.platformDispatcher.localeTestValue = original);

      expect(resolvedLocaleCode(AppLocale.system), 'ru');
    });

    test(
      'AppLocale.system falls back to "en" for any non-Russian OS locale '
      '(matches l10n.yaml template-arb-file: app_en.arb)',
      () {
        final binding = TestWidgetsFlutterBinding.instance;
        final original = binding.platformDispatcher.locale;
        binding.platformDispatcher.localeTestValue = const Locale('fr');
        addTearDown(
          () => binding.platformDispatcher.localeTestValue = original,
        );

        expect(resolvedLocaleCode(AppLocale.system), 'en');
      },
    );
  });
}
