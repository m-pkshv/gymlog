import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/core/widgets/completion_toggle.dart';

Widget _appUnderTest({required bool value, ValueChanged<bool>? onChanged}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: CompletionToggle(
        value: value,
        onChanged: onChanged ?? (_) {},
        semanticLabel: 'Done',
      ),
    ),
  );
}

void main() {
  testWidgets('shows a checkmark icon when done, none when not', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(value: true));
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pumpWidget(_appUnderTest(value: false));
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('tapping toggles the value through onChanged', (tester) async {
    bool? toggled;
    await tester.pumpWidget(
      _appUnderTest(value: false, onChanged: (v) => toggled = v),
    );

    await tester.tap(find.byType(CompletionToggle));
    await tester.pump();

    expect(toggled, isTrue);
  });

  testWidgets('exposes the semantic label as a toggled button', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_appUnderTest(value: true));

    expect(
      tester.getSemantics(find.byType(CompletionToggle)),
      matchesSemantics(
        label: 'Done',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    handle.dispose();
  });

  testWidgets('renders under the dark theme without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: CompletionToggle(
            value: false,
            onChanged: (_) {},
            semanticLabel: 'Done',
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
