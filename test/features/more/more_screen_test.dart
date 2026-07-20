import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/features/more/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MoreScreen(),
    ),
  );
}

/// Same rationale as the other flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'shows the showTags switch on by default (DM 6.12)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isTrue);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'toggling the switch persists showTags = false',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      final tile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(tile.value, isFalse);

      final row = await (db.select(
        db.appSettingsTable,
      )..where((t) => t.id.equals('singleton'))).getSingle();
      expect(row.showTags, isFalse);

      await _unmountAndFlush(tester);
    },
  );
}
