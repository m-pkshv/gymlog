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
import 'package:gymlog/features/tags/screen.dart';
import 'package:gymlog/app/theme.dart';
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
          GoRoute(path: 'tags', builder: (_, _) => const TagListScreen()),
        ],
      ),
    ],
  );
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      theme: buildLightTheme(),
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
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Measurements'), findsOneWidget);
    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets(
    'groups the menu into "Data"/"Configuration" sections with a subtitle '
    'under each item (Stage 10 redesign, AUDIT.md 1.5)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Data'), findsOneWidget);
      expect(find.text('Configuration'), findsOneWidget);
      expect(find.text('Reusable workout blueprints'), findsOneWidget);
      expect(find.text('Manage workout tags'), findsOneWidget);
      expect(find.text('Weight, body fat, and body measurements'), findsOneWidget);
      expect(find.text('Backup and export your data'), findsOneWidget);
      expect(find.text('Theme, language, units'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping "Tags" opens the tag management screen (Stage 10, '
    'owner-reported)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tags'));
      await tester.pumpAndSettle();

      expect(find.byType(TagListScreen), findsOneWidget);

      // Let drift's watch-stream unsubscribe timer fire before flutter_test's
      // pending-timer check runs (documented CLAUDE.md finding).
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

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
