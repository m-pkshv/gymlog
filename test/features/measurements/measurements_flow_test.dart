import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/core/units/unit_converter.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/body_measurement_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/features/measurements/custom_measurement_type_screen.dart';
import 'package:gymlog/features/measurements/measurement_form_screen.dart';
import 'package:gymlog/features/measurements/measurement_value_format.dart';
import 'package:gymlog/features/measurements/screen.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// Mirrors the `/more/measurements` slice of the real router (S-14/S-15,
/// Stage 6) -- a self-contained harness, same pattern as
/// `templates_flow_test.dart`.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/more/measurements',
    routes: [
      GoRoute(
        path: '/more/measurements',
        builder: (_, _) => const MeasurementsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (_, state) =>
                MeasurementFormScreen(initialTypeId: state.extra as String?),
          ),
          GoRoute(
            path: 'custom/:typeId',
            builder: (_, state) => CustomMeasurementTypeScreen(
              typeId: state.pathParameters['typeId']!,
            ),
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

/// Same rationale as the other feature flow tests: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
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

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await AppSettingsRepositoryImpl(db).ensureInitialized();
    await _seedType(db, id: 'body_weight', unitKind: 'mass', sortOrder: 0);
    await _seedType(db, id: 'body_fat', unitKind: 'percent', sortOrder: 1);
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('the Weight tab shows an empty state with no entries', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No entries yet'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets('the "+" FAB opens the form and creates an entry', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(MeasurementFormScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '82.5');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.byType(MeasurementFormScreen), findsNothing);
    expect(find.textContaining('82.5 kg'), findsOneWidget);
    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a same-day duplicate prompts to replace, and confirming updates the '
    'value (DM 6.9)',
    (tester) async {
      final measurements = BodyMeasurementRepositoryImpl(db);
      await measurements.create(
        measurementTypeId: 'body_weight',
        date: DateTime.now(),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      expect(find.textContaining('80.0 kg'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '81.2');
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.text('Replace existing value?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Replace'));
      await tester.pumpAndSettle();

      expect(find.textContaining('81.2 kg'), findsOneWidget);
      expect(find.textContaining('80.0 kg'), findsNothing);
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the Custom tab lists a newly created custom measurement type',
    (tester) async {
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('No custom measurement types yet'), findsOneWidget);

      await tester.tap(find.text('Add custom measurement…'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'Wrist',
      );
      // The dialog's "Create" is gated on `_isNameValid`, unlike the S-15
      // form's (gated only on a type being selected) -- needs a pump so the
      // TextField's onChanged/setState lands before the tap, or the button
      // is still disabled in the tap's frame (mirrors
      // `templates_flow_test.dart`'s create-dialog pattern).
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      expect(find.text('Wrist'), findsOneWidget);
      expect(find.text('No custom measurement types yet'), findsNothing);
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'archiving a custom type from its detail screen removes it from the '
    'Custom tab list',
    (tester) async {
      // Custom types are user-created (isBuiltIn=false); insert directly.
      await db
          .into(db.measurementTypes)
          .insert(
            MeasurementTypesCompanion.insert(
              id: 'wrist-custom',
              nameCustom: const Value('Wrist'),
              unitKind: 'length',
              isBuiltIn: false,
              sortOrder: 0,
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Custom'));
      await tester.pumpAndSettle();
      expect(find.text('Wrist'), findsOneWidget);

      await tester.tap(find.text('Wrist'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomMeasurementTypeScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      // Back on the Custom tab.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Wrist'), findsNothing);
      expect(find.text('No custom measurement types yet'), findsOneWidget);
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'deleting an entry shows an Undo snackbar and restores it',
    (tester) async {
      final measurements = BodyMeasurementRepositoryImpl(db);
      await measurements.create(
        measurementTypeId: 'body_weight',
        date: DateTime.now(),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      expect(find.textContaining('80.0 kg'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.textContaining('80.0 kg'), findsNothing);
      expect(find.text('Measurement deleted'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.textContaining('80.0 kg'), findsOneWidget);
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'entering a value in lb under the imperial setting stores it correctly '
    'in kg (D-5, end-to-end)',
    (tester) async {
      await (db.update(
        db.appSettingsTable,
      )..where((t) => t.id.equals('singleton'))).write(
        const AppSettingsTableCompanion(unitSystem: Value('imperial')),
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('lb'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, '150');
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();

      final stored = await BodyMeasurementRepositoryImpl(
        db,
      ).getByTypeAndDate(measurementTypeId: 'body_weight', date: DateTime.now());
      expect(stored, isNotNull);
      expect(stored!.valueMetric, closeTo(150 * UnitConverter.kgPerLb, 1e-6));
      // The list re-displays it back in lb, not the raw stored kg.
      expect(find.textContaining('150.0 lb'), findsOneWidget);
      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'switching the unit system (★ verification, D-5) changes display only '
    '-- the stored valueMetric never changes',
    (tester) async {
      final measurements = BodyMeasurementRepositoryImpl(db);
      final created = await measurements.create(
        measurementTypeId: 'body_weight',
        date: DateTime.now(),
        valueMetric: 80,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      expect(find.textContaining('80.0 kg'), findsOneWidget);

      // Same toggle as `more_screen_test.dart`'s "Imperial units" switch —
      // simulated here directly against AppSettingsRepository since this
      // harness doesn't mount MoreScreen too.
      await AppSettingsRepositoryImpl(db).setUnitSystem(UnitSystem.imperial);
      await tester.pumpAndSettle();

      expect(find.textContaining('kg'), findsNothing);
      expect(
        find.textContaining(
          measurementValueToDisplay(
            80,
            MeasurementUnitKind.mass,
            UnitSystem.imperial,
          ).toStringAsFixed(1),
        ),
        findsOneWidget,
      );

      final stillStored = await measurements.getByTypeAndDate(
        measurementTypeId: 'body_weight',
        date: DateTime.now(),
      );
      expect(stillStored!.valueMetric, created.valueMetric);
      expect(stillStored.valueMetric, 80);

      await _unmountAndFlush(tester);
    },
  );
}
