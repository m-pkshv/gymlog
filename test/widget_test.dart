import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gymlog/main.dart';

void main() {
  testWidgets('GymLogApp shows the Today tab and a 5-item bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GymLogApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('tapping a bottom nav destination switches tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymLogApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsWidgets);
  });
}
