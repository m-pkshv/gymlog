import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/constants.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/settings/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';
import 'package:gymlog/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';

/// `NotificationService.openNotificationSettings` dispatches through
/// `permission_handler`'s own platform channel -- meaningfully verifying it
/// needs a real device (same accepted-risk category as the rest of
/// `NotificationService`, see `notification_service_test.dart`). Mocked
/// here so these widget tests verify the *screen's* orchestration
/// (status text, button wiring) without ever touching the real plugin.
class MockNotificationService extends Mock implements NotificationService {}

Widget _appUnderTest(AppDatabase db, {NotificationService? notificationService}) {
  return ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      if (notificationService != null)
        notificationServiceProvider.overrideWithValue(notificationService),
    ],
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

  testWidgets(
    'shows the default rest timer (120 s) and auto-start on by default '
    '(DM 6.12, Q-4)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '120',
      );
      final autoStart = tester.widget<SwitchListTile>(
        _switchTile('Auto-start rest timer'),
      );
      expect(autoStart.value, isTrue);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'entering a valid rest timer value and losing focus persists it '
    '(DM 6.12, Q-4)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '90');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Enter a value from 10 to 600 seconds'), findsNothing);
      final row = await (db.select(
        db.appSettingsTable,
      )..where((t) => t.id.equals('singleton'))).getSingle();
      expect(row.defaultRestTimerSec, 90);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'entering an out-of-range rest timer value shows an inline error and '
    "doesn't persist it (DM 6.12, Q-4)",
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a value from 10 to 600 seconds'),
        findsOneWidget,
      );
      final row = await (db.select(
        db.appSettingsTable,
      )..where((t) => t.id.equals('singleton'))).getSingle();
      expect(row.defaultRestTimerSec, 120);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('toggling auto-start persists restTimerAutoStart = false', (
    tester,
  ) async {
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(_switchTile('Auto-start rest timer'));
    await tester.pumpAndSettle();

    final row = await (db.select(
      db.appSettingsTable,
    )..where((t) => t.id.equals('singleton'))).getSingle();
    expect(row.restTimerAutoStart, isFalse);

    await _unmountAndFlush(tester);
  });

  group('notifications (S-17)', () {
    late MockNotificationService notificationService;

    setUp(() {
      notificationService = MockNotificationService();
    });

    testWidgets('shows "Enabled" when notifications are enabled', (
      tester,
    ) async {
      when(
        () => notificationService.areNotificationsEnabled(),
      ).thenAnswer((_) async => true);
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(
        _appUnderTest(db, notificationService: notificationService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enabled'), findsOneWidget);

      await _unmountAndFlush(tester);
    });

    testWidgets('shows "Disabled" when notifications are disabled', (
      tester,
    ) async {
      when(
        () => notificationService.areNotificationsEnabled(),
      ).thenAnswer((_) async => false);
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(
        _appUnderTest(db, notificationService: notificationService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Disabled'), findsOneWidget);

      await _unmountAndFlush(tester);
    });

    testWidgets(
      'tapping "Settings" on the notifications row opens OS settings via '
      'NotificationService, not a real platform call',
      (tester) async {
        when(
          () => notificationService.areNotificationsEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => notificationService.openNotificationSettings(),
        ).thenAnswer((_) async => true);
        // The notifications row is below the default 800x600 test
        // viewport's fold -- a taller viewport is needed to actually hit
        // test the button (documented CLAUDE.md finding).
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        await AppSettingsRepositoryImpl(db).ensureInitialized();
        await tester.pumpWidget(
          _appUnderTest(db, notificationService: notificationService),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Settings'));
        await tester.pumpAndSettle();

        verify(() => notificationService.openNotificationSettings()).called(1);
        expect(find.text("Couldn't open system settings"), findsNothing);

        await _unmountAndFlush(tester);
      },
    );

    testWidgets(
      'shows an error snackbar when opening OS settings fails',
      (tester) async {
        when(
          () => notificationService.areNotificationsEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => notificationService.openNotificationSettings(),
        ).thenAnswer((_) async => false);
        tester.view.physicalSize = const Size(1080, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        await AppSettingsRepositoryImpl(db).ensureInitialized();
        await tester.pumpWidget(
          _appUnderTest(db, notificationService: notificationService),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(TextButton, 'Settings'));
        await tester.pumpAndSettle();

        expect(find.text("Couldn't open system settings"), findsOneWidget);

        await _unmountAndFlush(tester);
      },
    );
  });

  testWidgets(
    'shows the app version and CSV export format version (S-17, D-9)',
    (tester) async {
      // The "About" rows are the last thing on the screen, below the
      // default 800x600 test viewport's fold.
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text(ExportFormat.appVersion), findsOneWidget);
      expect(find.text('${ExportFormat.formatVersion}'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );
}
