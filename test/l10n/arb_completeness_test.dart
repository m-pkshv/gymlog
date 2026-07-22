import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards against ARB drift -- 02_DEVELOPMENT_PLAN.md, Stage 9 acceptance
/// criteria: "тест полноты ARB (все ключи есть в обоих файлах)".
/// `app_en.arb` also carries `@key` metadata entries (descriptions) that
/// `app_ru.arb` intentionally omits (project convention: en is the source
/// of truth with descriptions, ru is a plain key-value translation file) --
/// both those and the `@@locale` header are excluded from the comparison.
Set<String> _translationKeys(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  return json.keys
      .where((key) => key != '@@locale' && !key.startsWith('@'))
      .toSet();
}

void main() {
  test('every ARB translation key exists in both app_en.arb and app_ru.arb', () {
    final enKeys = _translationKeys('lib/l10n/app_en.arb');
    final ruKeys = _translationKeys('lib/l10n/app_ru.arb');

    expect(
      enKeys.difference(ruKeys),
      isEmpty,
      reason: 'keys present in app_en.arb but missing from app_ru.arb',
    );
    expect(
      ruKeys.difference(enKeys),
      isEmpty,
      reason: 'keys present in app_ru.arb but missing from app_en.arb',
    );
  });
}
