import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/core/widgets/status_badge.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(WorkoutStatus status, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? buildLightTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: StatusBadge(status: status)),
  );
}

void main() {
  testWidgets('shows the localized label for each status', (tester) async {
    await tester.pumpWidget(_appUnderTest(WorkoutStatus.inProgress));
    expect(find.text('In progress'), findsOneWidget);
  });

  testWidgets('completed and cancelled render with different colors', (
    tester,
  ) async {
    Color decoratedColorFor(WorkoutStatus status) {
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const ValueKey('status-badge-decoration')),
                  )
                  .decoration
              as BoxDecoration;
      return decoration.color!;
    }

    await tester.pumpWidget(_appUnderTest(WorkoutStatus.completed));
    final completedColor = decoratedColorFor(WorkoutStatus.completed);

    await tester.pumpWidget(_appUnderTest(WorkoutStatus.cancelled));
    final cancelledColor = decoratedColorFor(WorkoutStatus.cancelled);

    expect(completedColor, isNot(cancelledColor));
  });

  testWidgets('draft and planned share the same color', (tester) async {
    Color decoratedColorFor(WorkoutStatus status) {
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.byKey(const ValueKey('status-badge-decoration')),
                  )
                  .decoration
              as BoxDecoration;
      return decoration.color!;
    }

    await tester.pumpWidget(_appUnderTest(WorkoutStatus.draft));
    final draftColor = decoratedColorFor(WorkoutStatus.draft);

    await tester.pumpWidget(_appUnderTest(WorkoutStatus.planned));
    final plannedColor = decoratedColorFor(WorkoutStatus.planned);

    expect(draftColor, plannedColor);
  });

  testWidgets('renders under the dark theme without error', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(WorkoutStatus.completed, theme: buildDarkTheme()),
    );
    expect(tester.takeException(), isNull);
  });
}
