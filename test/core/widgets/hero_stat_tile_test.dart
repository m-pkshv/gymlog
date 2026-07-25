import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/core/widgets/hero_stat_tile.dart';

void main() {
  testWidgets('shows the value and label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: HeroStatTile(value: '47 min', label: 'Duration'),
        ),
      ),
    );

    expect(find.text('47 min'), findsOneWidget);
    expect(find.text('Duration'), findsOneWidget);
  });

  testWidgets('shows the icon only when supplied', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: HeroStatTile(
            value: '4',
            label: 'Exercises',
            icon: Icons.fitness_center,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
  });

  testWidgets('omits the icon slot when not supplied', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: HeroStatTile(value: '4', label: 'Exercises'),
        ),
      ),
    );

    expect(find.byType(Icon), findsNothing);
  });
}
