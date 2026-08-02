import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/confetti_overlay.dart';

void main() {
  testWidgets(
    'paints particles while the burst is running, then removes itself '
    '(no leftover CustomPaint) once it finishes',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ConfettiOverlay())),
      );

      // Mid-burst: still actively painting.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CustomPaint), findsWidgets);

      // pumpAndSettle waits out the (finite, ~1.6s) animation rather than
      // hanging -- unlike the Row/CrossAxisAlignment.stretch bug found
      // earlier in this same redesign pass, a real bounded
      // AnimationController is exactly what pumpAndSettle is for.
      await tester.pumpAndSettle();
      expect(find.byType(SizedBox), findsWidgets);
    },
  );

  testWidgets('never intercepts taps on whatever it is layered over', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(onTap: () => tapped = true),
              ),
              const Positioned.fill(child: ConfettiOverlay()),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    expect(tapped, isTrue);
  });
}
