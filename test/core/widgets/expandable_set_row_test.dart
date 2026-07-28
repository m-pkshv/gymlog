import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/expandable_set_row.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({
  bool expanded = false,
  VoidCallback? onToggleExpanded,
  Widget? trailing,
  Widget? expandedChild,
  VoidCallback? onDelete,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ExpandableSetRow(
        key: const ValueKey('set-1'),
        setNumber: 1,
        planLabel: 'Plan 80×8',
        valueLabel: '82.5 × 8',
        statusBarColor: Colors.green,
        expanded: expanded,
        onToggleExpanded: onToggleExpanded ?? () {},
        trailing: trailing,
        expandedChild: expandedChild,
        onDelete: onDelete,
      ),
    ),
  );
}

void main() {
  testWidgets('shows the set number, plan label, and value', (tester) async {
    await tester.pumpWidget(_appUnderTest());

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Plan 80×8'), findsOneWidget);
    expect(find.text('82.5 × 8'), findsOneWidget);
  });

  testWidgets('tapping the row calls onToggleExpanded', (tester) async {
    var toggled = false;
    await tester.pumpWidget(
      _appUnderTest(onToggleExpanded: () => toggled = true),
    );

    await tester.tap(find.text('82.5 × 8'));
    await tester.pump();

    expect(toggled, isTrue);
  });

  testWidgets('expandedChild is hidden when expanded is false', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(expandedChild: const Text('Steppers here')),
    );

    expect(find.text('Steppers here'), findsNothing);
  });

  testWidgets('expandedChild is shown when expanded is true', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(expanded: true, expandedChild: const Text('Steppers here')),
    );

    expect(find.text('Steppers here'), findsOneWidget);
  });

  testWidgets('trailing widget renders when supplied', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(trailing: const Icon(Icons.check_circle)),
    );

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets(
    'onDelete supplied shows a non-gesture delete button that calls it',
    (tester) async {
      var deleted = false;
      await tester.pumpWidget(_appUnderTest(onDelete: () => deleted = true));

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(deleted, isTrue);
    },
  );

  testWidgets('omitting onDelete hides the delete button', (tester) async {
    await tester.pumpWidget(_appUnderTest());

    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });
}
