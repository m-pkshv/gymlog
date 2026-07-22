import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/settings/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SettingsScreen(),
    ),
  );
}

/// Same rationale as the other flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

Finder _switchTile(String title) => find.widgetWithText(SwitchListTile, title);

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows system theme selected by default (DM 6.12)', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<AppTheme>>(
      find.byType(SegmentedButton<AppTheme>),
    );
    expect(segmented.selected, {AppTheme.system});

    await _unmountAndFlush(tester);
  });

  testWidgets('tapping the "Dark" segment persists theme = dark', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.appSettingsTable,
    )..where((t) => t.id.equals('singleton'))).getSingle();
    expect(row.theme, 'dark');

    await _unmountAndFlush(tester);
  });

  testWidgets('shows system language selected by default (DM 6.12)', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final segmented = tester.widget<SegmentedButton<AppLocale>>(
      find.byType(SegmentedButton<AppLocale>),
    );
    expect(segmented.selected, {AppLocale.system});

    await _unmountAndFlush(tester);
  });

  testWidgets('tapping the "Русский" segment persists locale = ru', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.appSettingsTable,
    )..where((t) => t.id.equals('singleton'))).getSingle();
    expect(row.locale, 'ru');

    await _unmountAndFlush(tester);
  });

  testWidgets('shows the showTags switch on by default (DM 6.12)', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    final tile = tester.widget<SwitchListTile>(_switchTile('Show tags'));
    expect(tile.value, isTrue);

    await _unmountAndFlush(tester);
  });

  testWidgets('toggling the showTags switch persists showTags = false', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(_switchTile('Show tags'));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.appSettingsTable,
    )..where((t) => t.id.equals('singleton'))).getSingle();
    expect(row.showTags, isFalse);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'shows the unit system switch off (metric) by default (D-5, Stage 6)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      final tile = tester.widget<SwitchListTile>(
        _switchTile('Imperial units'),
      );
      expect(tile.value, isFalse);
      expect(find.text('Metric (kg, cm)'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('toggling the unit system switch persists unitSystem = imperial', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(_switchTile('Imperial units'));
    await tester.pumpAndSettle();

    expect(find.text('Imperial (lb, in)'), findsOneWidget);
    final row = await (db.select(
      db.appSettingsTable,
    )..where((t) => t.id.equals('singleton'))).getSingle();
    expect(row.unitSystem, 'imperial');

    await _unmountAndFlush(tester);
  });
}
