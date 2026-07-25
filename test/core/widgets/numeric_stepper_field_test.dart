import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/numeric_stepper_field.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({
  required double value,
  required ValueChanged<double> onChanged,
  double step = 1,
  int decimals = 0,
  double min = 0,
  double? max,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: NumericStepperField(
        label: 'Weight, kg',
        value: value,
        onChanged: onChanged,
        step: step,
        decimals: decimals,
        min: min,
        max: max,
      ),
    ),
  );
}

void main() {
  testWidgets('shows the label and rounded value when decimals is 0', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(value: 80, onChanged: (_) {}));

    expect(find.text('Weight, kg'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
  });

  testWidgets('shows fixed decimals when decimals > 0', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(value: 82.5, onChanged: (_) {}, decimals: 1),
    );

    expect(find.text('82.5'), findsOneWidget);
  });

  testWidgets('tapping "+" increases the value by step', (tester) async {
    double? result;
    await tester.pumpWidget(
      _appUnderTest(value: 80, step: 2.5, onChanged: (v) => result = v),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(result, 82.5);
  });

  testWidgets('tapping "-" decreases the value by step', (tester) async {
    double? result;
    await tester.pumpWidget(
      _appUnderTest(value: 80, step: 2.5, onChanged: (v) => result = v),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(result, 77.5);
  });

  testWidgets('decrementing below min clamps at min', (tester) async {
    double? result;
    await tester.pumpWidget(
      _appUnderTest(value: 0, min: 0, onChanged: (v) => result = v),
    );

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    expect(result, 0);
  });

  testWidgets('incrementing above max clamps at max', (tester) async {
    double? result;
    await tester.pumpWidget(
      _appUnderTest(value: 10, max: 10, onChanged: (v) => result = v),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(result, 10);
  });

  testWidgets(
    'tapping the value opens a precise-entry dialog that reports the typed number',
    (tester) async {
      double? result;
      await tester.pumpWidget(
        _appUnderTest(value: 80, onChanged: (v) => result = v),
      );

      await tester.tap(find.text('80'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '92.5');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(result, 92.5);
    },
  );

  testWidgets('cancelling the precise-entry dialog does not call onChanged', (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(
      _appUnderTest(value: 80, onChanged: (_) => called = true),
    );

    await tester.tap(find.text('80'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(called, isFalse);
  });
}
