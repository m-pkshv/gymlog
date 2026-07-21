import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/features/measurements/widgets/measurement_chart.dart';
import 'package:gymlog/features/stats/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StatsScreen(),
    ),
  );
}

Future<void> _seedType(
  AppDatabase db, {
  required String id,
  required String unitKind,
  int sortOrder = 0,
}) {
  return db
      .into(db.measurementTypes)
      .insert(
        MeasurementTypesCompanion.insert(
          id: id,
          unitKind: unitKind,
          isBuiltIn: true,
          sortOrder: sortOrder,
        ),
      );
}

/// Same rationale as the other feature flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await _seedType(db, id: 'body_weight', unitKind: 'mass', sortOrder: 0);
    await _seedType(db, id: 'body_fat', unitKind: 'percent', sortOrder: 1);
    await _seedType(db, id: 'neck', unitKind: 'length', sortOrder: 2);
    await _seedType(db, id: 'waist', unitKind: 'length', sortOrder: 3);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('the Weight card shows an empty state with no entries', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Body weight'), findsOneWidget);
    expect(find.text('No entries in this period'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('the Weight card defaults to the Month period', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final monthChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Month').first,
    );
    expect(monthChip.selected, isTrue);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'switching the period reveals an entry the default Month period '
    'excludes',
    (tester) async {
      await BodyMeasurementRepositoryImpl(db).create(
        measurementTypeId: 'body_weight',
        date: DateTime.now().subtract(const Duration(days: 200)),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      // Scoped to the Weight card specifically -- S-09 has several
      // independent period selectors on screen, each with its own "All".
      // The body only ever draws a chart (no per-point value text), so the
      // observable signal is the empty-state text vs. a rendered chart.
      final weightCard = find.ancestor(
        of: find.text('Body weight'),
        matching: find.byType(Card),
      );
      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: weightCard, matching: find.byType(MeasurementChart)),
        findsNothing,
      );

      await tester.tap(
        find.descendant(
          of: weightCard,
          matching: find.widgetWithText(ChoiceChip, 'All'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: weightCard,
          matching: find.text('No entries in this period'),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: weightCard, matching: find.byType(MeasurementChart)),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('the Measurements card lets you pick among girth types', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Measurements'), findsOneWidget);
    // Defaults to the first candidate by sortOrder (neck).
    expect(find.text('Neck'), findsWidgets);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Waist').last);
    await tester.pumpAndSettle();

    expect(find.text('Waist'), findsWidgets);

    await _unmountAndFlush(tester);
  });
}
