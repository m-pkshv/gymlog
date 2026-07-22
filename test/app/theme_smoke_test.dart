import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/main.dart';

/// Same rationale as `test/widget_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

/// 02_DEVELOPMENT_PLAN.md, Stage 9 acceptance criteria: "widget-тесты
/// критичных экранов в обеих темах (smoke)". Not a visual/contrast check
/// (nothing here can assert "readable" -- that's the accepted ★-risk, same
/// as Stage 7's "графики читаемы в тёмной теме") -- this only proves each
/// of the 5 bottom-nav tabs renders without throwing under both
/// `AppTheme.light` and `AppTheme.dark`, on an otherwise-empty database (the
/// harder case: every screen has to fall back to its empty state, not real
/// data).
void main() {
  late drift.AppDatabase db;

  setUp(() {
    db = drift.AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget appUnderTest() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const GymLogApp(),
    );
  }

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('all 5 tabs render without error under ${theme.name} theme', (
      tester,
    ) async {
      final settingsRepository = AppSettingsRepositoryImpl(db);
      await settingsRepository.ensureInitialized();
      await settingsRepository.setTheme(theme);

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      final expectedBrightness = theme == AppTheme.dark
          ? Brightness.dark
          : Brightness.light;
      expect(
        Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        expectedBrightness,
      );

      for (final tabLabel in [
        'Today',
        'History',
        'Exercises',
        'Stats',
        'More',
      ]) {
        // Some screens repeat their tab's label as an AppBar title (e.g.
        // "Today"), so `find.text(tabLabel)` alone is ambiguous -- scope
        // the tap to the bottom nav bar specifically.
        await tester.tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(tabLabel),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }

      await _unmountAndFlush(tester);
    });
  }
}
