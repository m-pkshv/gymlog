import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/features/more/screen.dart';
import 'package:gymlog/features/settings/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/more',
    routes: [
      GoRoute(
        path: '/more',
        builder: (_, _) => const MoreScreen(),
        routes: [
          GoRoute(path: 'settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows the menu entries, including Settings (S-17, Stage 9)', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Templates'), findsOneWidget);
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Import/Export'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('tapping "Settings" opens the S-17 settings screen', (
    tester,
  ) async {
    // The settings row must exist before SettingsScreen ever watches it —
    // same reasoning as `main.dart`'s startup call — otherwise the screen
    // sits in its indeterminate loading state forever, which hangs
    // `pumpAndSettle()` (documented CLAUDE.md finding).
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);

    // Let drift's watch-stream unsubscribe timer fire before flutter_test's
    // pending-timer check runs (documented CLAUDE.md finding).
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
