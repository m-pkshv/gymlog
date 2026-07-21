import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/import_export_operation_repository_impl.dart';
import 'package:gymlog/domain/models/import_export_operation.dart';
import 'package:gymlog/features/export/export_format_help_screen.dart';
import 'package:gymlog/features/export/export_screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/more/export` (+ `format`) slice of the real router (Stage
/// 8, S-16).
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/more/export',
    routes: [
      GoRoute(
        path: '/more/export',
        builder: (_, _) => const ExportScreen(),
        routes: [
          GoRoute(
            path: 'format',
            builder: (_, _) => const ExportFormatHelpScreen(),
          ),
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
    'shows the export button, format link, and a disabled "Import" stub',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Export data (CSV)'), findsOneWidget);
      expect(find.text('CSV format description'), findsOneWidget);

      final importTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Import'),
      );
      expect(importTile.enabled, isFalse);
      expect(find.text('Coming in future versions'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('shows an empty journal state with no operations', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No operations yet'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'renders a successful journal entry with status and counts',
    (tester) async {
      final operations = ImportExportOperationRepositoryImpl(db);
      final operation = await operations.startExport(formatVersion: 1);
      await operations.markSuccess(
        operationId: operation.id,
        counts: const ImportExportOperationCounts(
          workouts: 12,
          sets: 340,
          measurements: 56,
          exercises: 199,
        ),
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('No operations yet'), findsNothing);
      expect(
        find.textContaining(
          'Success · 12 workouts · 340 sets · 56 measurements · 199 exercises',
        ),
        findsOneWidget,
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('renders a failed journal entry with a Failed status', (
    tester,
  ) async {
    final operations = ImportExportOperationRepositoryImpl(db);
    final operation = await operations.startExport(formatVersion: 1);
    await operations.markFailed(
      operationId: operation.id,
      errorSummary: 'Disk full',
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.textContaining('Failed'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'tapping the format link opens the help screen with each file\'s '
    'column headers',
    (tester) async {
      // The help screen's intro paragraph + three sections don't fit the
      // default test viewport (Stage 2 finding: a ListView only builds
      // widgets within the viewport).
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CSV format description'));
      await tester.pumpAndSettle();

      expect(find.byType(ExportFormatHelpScreen), findsOneWidget);
      expect(find.text('workouts.csv'), findsOneWidget);
      expect(find.text('measurements.csv'), findsOneWidget);
      expect(find.text('exercises.csv'), findsOneWidget);
      expect(find.textContaining('exercise_name, exercise_id'), findsOneWidget);
      expect(find.textContaining('date, type, custom_type_name'), findsOneWidget);
      expect(find.textContaining('exercise_id, name, type'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  // Deliberately not testing "tap Export -> real file written -> real share
  // sheet" here. Unlike mobile, `path_provider_windows`/`share_plus`'s
  // desktop backends call the Win32 API directly rather than going through
  // a Flutter platform channel -- so in a plain `flutter test` run on this
  // Windows host, `getTemporaryDirectory()` actually succeeds (writing a
  // real file to the real temp directory) instead of throwing the
  // MissingPluginException a mobile target would give, and `share_plus`
  // could just as easily try to summon a real OS share dialog. Either way
  // that's real I/O/OS interaction a unit-style widget test shouldn't
  // trigger. The pipeline this button calls (ExportService.export) already
  // has full coverage against a real in-memory DB and a real temp
  // directory in export_service_test.dart, with no platform boundary
  // involved -- the same "can't meaningfully test the real plugin without
  // a device" boundary already accepted for NotificationService.
}
