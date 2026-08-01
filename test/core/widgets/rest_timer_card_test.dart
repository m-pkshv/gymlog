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

  testWidgets(
    'tapping the fast-forward (⏩) button calls onAdjust with -10 '
    '(Stage 12, owner-reported: tape-deck icons, right side shortens '
    'the wait)',
    (tester) async {
      int? delta;
      await tester.pumpWidget(
        _appUnderTest(
          remainingSeconds: 84,
          totalSeconds: 120,
          onAdjust: (d) => delta = d,
        ),
      );

      await tester.tap(find.byTooltip('-10 s'));
      await tester.pump();

      expect(delta, -10);
    },
  );

  testWidgets(
    'tapping the rewind (⏪) button calls onAdjust with +10 '
    '(Stage 12, owner-reported: tape-deck icons, left side extends '
    'the wait)',
    (tester) async {
      int? delta;
      await tester.pumpWidget(
        _appUnderTest(
          remainingSeconds: 84,
          totalSeconds: 120,
          onAdjust: (d) => delta = d,
        ),
      );

      await tester.tap(find.byTooltip('+10 s'));
      await tester.pump();

      expect(delta, 10);
    },
  );

  testWidgets(
    'the seek buttons use plain fast-forward/rewind icons, no digit '
    'overlay (Stage 12, owner-reported: like old tape/cassette-player '
    'buttons)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(remainingSeconds: 84, totalSeconds: 120));

      expect(find.byIcon(Icons.fast_forward), findsOneWidget);
      expect(find.byIcon(Icons.fast_rewind), findsOneWidget);
      expect(find.text('10'), findsNothing);
      expect(find.text('15'), findsNothing);
    },
  );

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
