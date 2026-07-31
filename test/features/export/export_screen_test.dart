import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/design_tokens.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/core/widgets/grouped_section.dart';
import 'package:gymlog/features/export/export_format_help_screen.dart';
import 'package:gymlog/features/export/export_screen.dart';
import 'package:gymlog/app/theme.dart';
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
      theme: buildLightTheme(),
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
    'shows the export button and format link, with no "Import" stub and no '
    'operations journal (Stage 11, owner-reported: the disabled placeholder '
    'and the journal -- screen, write path, and table -- were both removed '
    'outright, not just hidden)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.text('Export data (CSV)'), findsOneWidget);
      expect(find.text('CSV format description'), findsOneWidget);
      expect(find.text('Import'), findsNothing);
      expect(find.text('Coming in future versions'), findsNothing);
      expect(find.text('Operations log'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'groups only the format-help row into a GroupedSection, with the '
    'backup buttons standalone above it (Stage 10 redesign, Stage 11 '
    'owner-reported restyle + journal removal)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      expect(find.byType(GroupedSection), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'shows the backup export/restore actions as big full-width buttons '
    'above the CSV section, restore styled with the accent color (Stage 11, '
    'owner-reported)',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      final exportButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Export backup'),
          matching: find.byType(FilledButton),
        ),
      );
      final restoreButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Restore from backup'),
          matching: find.byType(FilledButton),
        ),
      );
      // Export uses the app-wide default (no explicit backgroundColor
      // override); restore is explicitly styled with the accent color.
      expect(exportButton.style?.backgroundColor, isNull);
      final semantic = buildLightTheme().extension<AppSemanticColors>()!;
      expect(
        restoreButton.style?.backgroundColor?.resolve({}),
        semantic.accent,
      );

      // Backup buttons appear above the CSV export button in paint order.
      final backupY = tester
          .getTopLeft(find.text('Export backup'))
          .dy;
      final csvY = tester.getTopLeft(find.text('Export data (CSV)')).dy;
      expect(backupY, lessThan(csvY));

      // A divider visually separates the backup buttons from the CSV
      // section (owner-reported), sitting between the restore button and
      // the CSV export button.
      expect(find.byType(Divider), findsOneWidget);
      final restoreY = tester.getTopLeft(find.text('Restore from backup')).dy;
      final dividerY = tester.getTopLeft(find.byType(Divider)).dy;
      expect(dividerY, greaterThan(restoreY));
      expect(dividerY, lessThan(csvY));

      await _unmountAndFlush(tester);
    },
  );

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
  //
  // Same reasoning for the Stage 11 backup buttons: "Export backup" touches
  // `path_provider` the same way, and "Restore from backup" additionally
  // calls `FilePicker.pickFile` -- a real platform channel with no
  // meaningful fake in a plain widget test. `BackupService.exportBackup`/
  // `inspectBackup`/`restoreBackup` already have full coverage against a
  // real (file-backed, not in-memory) database in backup_service_test.dart,
  // with no platform boundary involved.
}
