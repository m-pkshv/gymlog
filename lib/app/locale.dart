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
