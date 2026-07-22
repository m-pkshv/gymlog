import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/locale.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
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
}
