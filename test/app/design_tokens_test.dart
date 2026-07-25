import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/design_tokens.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/domain/enums.dart';

void main() {
  test('buildLightTheme carries the light semantic color extension', () {
    final theme = buildLightTheme();
    expect(theme.extension<AppSemanticColors>(), AppSemanticColors.light);
  });

  test('buildDarkTheme carries the dark semantic color extension', () {
    final theme = buildDarkTheme();
    expect(theme.extension<AppSemanticColors>(), AppSemanticColors.dark);
  });

  group('workoutStatusColors', () {
    Future<StatusColorSet> colorsFor(
      WidgetTester tester,
      WorkoutStatus status,
      ThemeData theme,
    ) async {
      late StatusColorSet result;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              result = workoutStatusColors(context, status);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('draft and planned share the same neutral colors', (
      tester,
    ) async {
      final theme = buildLightTheme();
      final draft = await colorsFor(tester, WorkoutStatus.draft, theme);
      final planned = await colorsFor(tester, WorkoutStatus.planned, theme);
      expect(draft.container, planned.container);
      expect(draft.onContainer, planned.onContainer);
      expect(draft.border, planned.border);
    });

    testWidgets(
      'inProgress, completed, skipped, and cancelled are all distinct '
      'from each other and from the neutral draft/planned family',
      (tester) async {
        final theme = buildLightTheme();
        final neutral = await colorsFor(tester, WorkoutStatus.draft, theme);
        final inProgress = await colorsFor(
          tester,
          WorkoutStatus.inProgress,
          theme,
        );
        final completed = await colorsFor(
          tester,
          WorkoutStatus.completed,
          theme,
        );
        final skipped = await colorsFor(tester, WorkoutStatus.skipped, theme);
        final cancelled = await colorsFor(
          tester,
          WorkoutStatus.cancelled,
          theme,
        );

        final containers = {
          neutral.container,
          inProgress.container,
          completed.container,
          skipped.container,
          cancelled.container,
        };
        expect(containers, hasLength(5));
      },
    );

    testWidgets('completed uses the light success colors in the light theme', (
      tester,
    ) async {
      final light = await colorsFor(
        tester,
        WorkoutStatus.completed,
        buildLightTheme(),
      );
      expect(light.container, AppSemanticColors.light.successContainer);
      expect(light.onContainer, AppSemanticColors.light.onSuccessContainer);
    });

    testWidgets('completed uses the dark success colors in the dark theme', (
      tester,
    ) async {
      final dark = await colorsFor(
        tester,
        WorkoutStatus.completed,
        buildDarkTheme(),
      );
      expect(dark.container, AppSemanticColors.dark.successContainer);
      expect(dark.onContainer, AppSemanticColors.dark.onSuccessContainer);
    });
  });
}
