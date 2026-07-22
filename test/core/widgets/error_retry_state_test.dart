import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/core/widgets/error_retry_state.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest({required VoidCallback onRetry}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ErrorRetryState(message: 'Something failed', onRetry: onRetry),
    ),
  );
}

void main() {
  testWidgets('shows the message and a "Retry" button (UX 6)', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(onRetry: () {}));

    expect(find.text('Something failed'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  testWidgets('tapping "Retry" calls onRetry', (tester) async {
    var retried = false;
    await tester.pumpWidget(_appUnderTest(onRetry: () => retried = true));

    await tester.tap(find.widgetWithText(OutlinedButton, 'Retry'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
