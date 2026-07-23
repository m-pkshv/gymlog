import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/features/workout_editor/widgets/set_number_field.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets(
    'decimals: 0 (e.g. reps) shows an integer keyboard, no decimal point '
    '(Stage 10, owner-reported)',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SetNumberField(
            value: null,
            decimals: 0,
            onChanged: (_) {},
            onCommit: () {},
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, const TextInputType.numberWithOptions());
    },
  );

  testWidgets(
    'decimals > 0 (e.g. weight) shows a decimal keyboard',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          SetNumberField(
            value: null,
            decimals: 1,
            onChanged: (_) {},
            onCommit: () {},
          ),
        ),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(
        field.keyboardType,
        const TextInputType.numberWithOptions(decimal: true),
      );
    },
  );
}
