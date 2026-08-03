import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/shine_sweep.dart';

void main() {
  testWidgets(
    'paints a ShaderMask while the sweep is running, then stops (plain '
    'child left behind, not a leftover no-op ShaderMask)',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShineSweep(child: Text('Trophy'))),
        ),
      );

      // Mid-sweep: still actively painting the highlight.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ShaderMask), findsOneWidget);
      expect(find.text('Trophy'), findsOneWidget);

      // A real bounded AnimationController, same as ConfettiOverlay --
      // pumpAndSettle waits it out instead of hanging.
      await tester.pumpAndSettle();
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.text('Trophy'), findsOneWidget);
    },
  );

  testWidgets(
    'waits for [delay] before starting -- no ShaderMask, and no muddy '
    'transparent-black gradient stop, until then',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShineSweep(
              delay: Duration(milliseconds: 500),
              child: Text('Trophy'),
            ),
          ),
        ),
      );

      // Before the delay elapses: no sweep in progress yet.
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(ShaderMask), findsNothing);

      // Past the delay, mid-sweep.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ShaderMask), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ShaderMask), findsNothing);
    },
  );

  testWidgets('never intercepts taps on the wrapped child', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShineSweep(
            child: GestureDetector(
              onTap: () => tapped = true,
              child: const Text('Trophy'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trophy'));
    expect(tapped, isTrue);
  });
}
