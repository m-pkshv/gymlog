import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/core/widgets/rest_timer_card.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({
  required int remainingSeconds,
  required int totalSeconds,
  ValueChanged<int>? onAdjust,
  VoidCallback? onSkip,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: RestTimerCard(
        remainingSeconds: remainingSeconds,
        totalSeconds: totalSeconds,
        onAdjust: onAdjust ?? (_) {},
        onSkip: onSkip ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the remaining time as mm:ss', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(remainingSeconds: 84, totalSeconds: 120),
    );

    expect(find.text('01:24'), findsOneWidget);
  });

  testWidgets('tapping "-15 s" calls onAdjust with -15', (tester) async {
    int? delta;
    await tester.pumpWidget(
      _appUnderTest(
        remainingSeconds: 84,
        totalSeconds: 120,
        onAdjust: (d) => delta = d,
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();

    expect(delta, -15);
  });

  testWidgets('tapping "+15 s" calls onAdjust with +15', (tester) async {
    int? delta;
    await tester.pumpWidget(
      _appUnderTest(
        remainingSeconds: 84,
        totalSeconds: 120,
        onAdjust: (d) => delta = d,
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(delta, 15);
  });

  testWidgets('tapping the skip button calls onSkip', (tester) async {
    var skipped = false;
    await tester.pumpWidget(
      _appUnderTest(
        remainingSeconds: 84,
        totalSeconds: 120,
        onSkip: () => skipped = true,
      ),
    );

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();

    expect(skipped, isTrue);
  });

  testWidgets('a negative remaining time clamps its display to 00:00', (
    tester,
  ) async {
    await tester.pumpWidget(
      _appUnderTest(remainingSeconds: -5, totalSeconds: 120),
    );

    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets(
    'a fresh restart (elapsed close to zero) skips the fill animation '
    '(Stage 10, owner-reported: completing another set restarts the rest '
    'timer from a filled position, and that reset should snap, not '
    'glide backwards)',
    (tester) async {
      await tester.pumpWidget(
        _appUnderTest(remainingSeconds: 120, totalSeconds: 120),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(animatedFill.duration, Duration.zero);
    },
  );

  testWidgets(
    'a mid-countdown update still animates the fill smoothly',
    (tester) async {
      await tester.pumpWidget(
        _appUnderTest(remainingSeconds: 84, totalSeconds: 120),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(animatedFill.duration, isNot(Duration.zero));
    },
  );

  testWidgets('renders under the dark theme without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RestTimerCard(
            remainingSeconds: 30,
            totalSeconds: 120,
            onAdjust: (_) {},
            onSkip: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
