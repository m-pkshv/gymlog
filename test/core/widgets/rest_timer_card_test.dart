import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/core/widgets/rest_timer_card.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({
  required int remainingSeconds,
  int? remainingMilliseconds,
  required int totalMilliseconds,
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
        // Defaults to the whole-second value in ms for tests that don't
        // care about sub-second precision specifically.
        remainingMilliseconds: remainingMilliseconds ?? remainingSeconds * 1000,
        totalMilliseconds: totalMilliseconds,
        onAdjust: onAdjust ?? (_) {},
        onSkip: onSkip ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('shows the remaining time as mm:ss', (tester) async {
    await tester.pumpWidget(
      _appUnderTest(remainingSeconds: 84, totalMilliseconds: 120000),
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
          totalMilliseconds: 120000,
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
          totalMilliseconds: 120000,
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
      await tester.pumpWidget(
        _appUnderTest(remainingSeconds: 84, totalMilliseconds: 120000),
      );

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
        totalMilliseconds: 120000,
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
      _appUnderTest(remainingSeconds: -5, totalMilliseconds: 120000),
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
        _appUnderTest(remainingSeconds: 120, totalMilliseconds: 120000),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(animatedFill.duration, Duration.zero);
    },
  );

  testWidgets(
    'a genuine fresh start (a few ms elapsed, well within the fresh-restart '
    'tolerance) renders the fill as essentially 0% -- not the ~2% a whole '
    'seconds-based calculation used to show immediately '
    '(Stage 12, owner-reported: "число сразу отображает 44" -- the bar '
    'used to already be visibly filled and stuck at the very first frame)',
    (tester) async {
      // 50ms have elapsed out of a 45s timer -- the kind of gap that
      // naturally exists between `startRestTimer`'s DB write and this
      // widget's first read of it, nowhere near a whole second.
      await tester.pumpWidget(
        _appUnderTest(
          remainingSeconds: 45,
          remainingMilliseconds: 44950,
          totalMilliseconds: 45000,
        ),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      // Snapped (not glided), and negligibly close to empty -- not the old
      // whole-second-truncated ~1/45 (≈2.2%).
      expect(animatedFill.duration, Duration.zero);
      expect(animatedFill.tween.begin, lessThan(0.01));
      expect(animatedFill.tween.end, lessThan(0.01));
    },
  );

  testWidgets(
    'a mid-countdown update still animates the fill smoothly',
    (tester) async {
      await tester.pumpWidget(
        _appUnderTest(remainingSeconds: 84, totalMilliseconds: 120000),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      expect(animatedFill.duration, isNot(Duration.zero));
    },
  );

  testWidgets(
    'right before the timer disappears (last displayed second, only '
    'milliseconds truly left) the fill is essentially at the full edge -- '
    'not capped a whole second short '
    '(Stage 12, owner-reported: "не доходит до конца, видно, что остается '
    'ещё место")',
    (tester) async {
      // The label still reads "1" (rounded up), but only 50ms of the 45s
      // timer are truly left.
      await tester.pumpWidget(
        _appUnderTest(
          remainingSeconds: 1,
          remainingMilliseconds: 50,
          totalMilliseconds: 45000,
        ),
      );

      final animatedFill = tester.widget<TweenAnimationBuilder<double>>(
        find.byType(TweenAnimationBuilder<double>),
      );
      // Old whole-second math capped this at (45-1)/45 ≈ 0.978 forever.
      expect(animatedFill.tween.end, greaterThan(0.99));
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
            remainingMilliseconds: 30000,
            totalMilliseconds: 120000,
            onAdjust: (_) {},
            onSkip: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
