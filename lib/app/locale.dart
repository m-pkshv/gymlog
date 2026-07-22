import 'package:flutter/widgets.dart';

import '../domain/enums.dart';

/// Maps the domain [AppLocale] setting (Flutter-free, so the settings layer
/// stays testable without `package:flutter`) to the `Locale` that
/// `MaterialApp.router` actually consumes. `null` tells Flutter to resolve
/// the locale itself from the OS against `AppLocalizations.supportedLocales`
/// (04_UI_UX_SPEC.md, section 12 — same behavior as before Stage 9, when
/// this was implicit).
Locale? flutterLocale(AppLocale locale) {
  switch (locale) {
    case AppLocale.system:
      return null;
    case AppLocale.ru:
      return const Locale('ru');
    case AppLocale.en:
      return const Locale('en');
  }
}

/// Same resolution as [flutterLocale], but always returns a concrete
/// `'ru'`/`'en'` code -- for call sites that need the *effective* language
/// (e.g. picking a row from `ExerciseL10n`) rather than a `Locale?` to hand
/// to `MaterialApp`. `system` mirrors `template-arb-file: app_en.arb`
/// (`l10n.yaml`): the OS locale wins only if it's Russian, English is the
/// fallback for every other language. Reads through `WidgetsBinding` (not
/// the bare `dart:ui PlatformDispatcher.instance`) so it honors
/// `TestWidgetsFlutterBinding`'s `localeTestValue` override in tests.
String resolvedLocaleCode(AppLocale locale) {
  switch (locale) {
    case AppLocale.system:
      return WidgetsBinding.instance.platformDispatcher.locale.languageCode ==
              'ru'
          ? 'ru'
          : 'en';
    case AppLocale.ru:
      return 'ru';
    case AppLocale.en:
      return 'en';
  }
}
