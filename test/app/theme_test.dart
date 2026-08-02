import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/design_tokens.dart';
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

  group(
    'button pressed states (design/redesign_v2, owner-supplied mockup: '
    'a solid, noticeably darker/tinted fill on press, not Material\'s '
    'default faint ripple overlay)',
    () {
      test(
        'a filled button (primary) rests at colorScheme.primary, darkens '
        'on press, and dims when disabled',
        () {
          final theme = buildLightTheme();
          final colorScheme = theme.colorScheme;
          final background = theme.filledButtonTheme.style!.backgroundColor!;

          expect(background.resolve({}), colorScheme.primary);
          expect(
            background.resolve({WidgetState.pressed}),
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.18),
              colorScheme.primary,
            ),
          );
          expect(
            background.resolve({WidgetState.disabled}),
            colorScheme.onSurface.withValues(alpha: 0.12),
          );
        },
      );

      test(
        'an outlined button (secondary) stays transparent at rest and '
        'shows a light primary-tinted fill while pressed',
        () {
          final theme = buildLightTheme();
          final colorScheme = theme.colorScheme;
          final background =
              theme.outlinedButtonTheme.style!.backgroundColor!;

          expect(background.resolve({}), Colors.transparent);
          expect(
            background.resolve({WidgetState.pressed}),
            colorScheme.primary.withValues(alpha: 0.12),
          );
        },
      );

      test('the same pressed-state darkening applies in the dark theme too', () {
        final theme = buildDarkTheme();
        final colorScheme = theme.colorScheme;
        final background = theme.filledButtonTheme.style!.backgroundColor!;

        expect(
          background.resolve({WidgetState.pressed}),
          Color.alphaBlend(
            Colors.black.withValues(alpha: 0.18),
            colorScheme.primary,
          ),
        );
      });

      testWidgets(
        'accentFilledButtonStyle (the orange "Таймер / акцент" CTA -- '
        'finishing a workout, restoring a backup) darkens on press the '
        'same way',
        (tester) async {
          late BuildContext capturedContext;
          await tester.pumpWidget(
            MaterialApp(
              theme: buildLightTheme(),
              home: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

          final semantic = Theme.of(
            capturedContext,
          ).extension<AppSemanticColors>()!;
          final style = accentFilledButtonStyle(capturedContext);

          expect(style.backgroundColor!.resolve({}), semantic.accent);
          expect(
            style.backgroundColor!.resolve({WidgetState.pressed}),
            Color.alphaBlend(
              Colors.black.withValues(alpha: 0.18),
              semantic.accent,
            ),
          );
          expect(style.foregroundColor!.resolve({}), semantic.onAccent);
        },
      );
    },
  );
}
