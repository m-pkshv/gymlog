import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  group('flutterThemeMode', () {
    test('AppTheme.system maps to ThemeMode.system', () {
      expect(flutterThemeMode(AppTheme.system), ThemeMode.system);
    });

    test('AppTheme.light maps to ThemeMode.light', () {
      expect(flutterThemeMode(AppTheme.light), ThemeMode.light);
    });

    test('AppTheme.dark maps to ThemeMode.dark', () {
      expect(flutterThemeMode(AppTheme.dark), ThemeMode.dark);
    });
  });
}
