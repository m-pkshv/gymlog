import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart';
import 'package:gymlog/features/tags/screen.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/l10n/app_localizations.dart';

/// App-wide tag management screen (Ещё → Теги, Stage 10, owner-reported):
/// create/delete tags, split out of the workout tag picker sheet (covered
/// separately in `workout_editor_flow_test.dart`) because the picker's
/// delete "x" on a chip used to be confused with unassigning the tag from
/// that one workout.
Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/tags',
    routes: [GoRoute(path: '/tags', builder: (_, _) => const TagListScreen())],
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

Future<void> _seedTag(
  AppDatabase db, {
  String id = 'tag1',
  String name = 'Leg day',
  String colorHex = '#4C7BD9',
}) {
  return db
      .into(db.workoutTags)
      .insert(
        WorkoutTagsCompanion.insert(
          id: id,
          name: name,
          colorHex: Value(colorHex),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
}

Future<void> _seedWorkoutWithTag(
  AppDatabase db, {
  required String workoutId,
  required String tagId,
}) async {
  await db
      .into(db.workouts)
      .insert(
        WorkoutsCompanion.insert(
          id: workoutId,
          date: '2026-07-19',
          status: const Value('completed'),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
  await db
      .into(db.workoutTagLinks)
      .insert(WorkoutTagLinksCompanion.insert(workoutId: workoutId, tagId: tagId));
}

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
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

  testWidgets('shows an empty state with a "Create tag" action when no tag exists', (
    tester,
  ) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('No tags yet'), findsOneWidget);
    expect(find.text('Create tag'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('shows every existing tag with its color', (tester) async {
    await _seedTag(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('the FAB creates a new tag that appears in the list', (tester) async {
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Push',
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.text('Push'), findsOneWidget);
    final tags = await db.select(db.workoutTags).get();
    expect(tags.single.name, 'Push');

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'deleting a tag asks for confirmation with the assigned-workout count, '
    'and confirming removes it for good (DM 10 -- no Undo)',
    (tester) async {
      await _seedTag(db);
      await _seedWorkoutWithTag(db, workoutId: 'w1', tagId: 'tag1');
      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete tag?'), findsOneWidget);
      expect(
        find.text('This tag will be removed from 1 workout.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Leg day'), findsNothing);
      expect(find.text('No tags yet'), findsOneWidget);
      final tags = await db.select(db.workoutTags).get();
      expect(tags.single.isDeleted, isTrue, reason: 'soft-deleted, not gone');
      final links = await db.select(db.workoutTagLinks).get();
      expect(links, isEmpty);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('cancelling the delete confirmation leaves the tag untouched', (
    tester,
  ) async {
    await _seedTag(db);
    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Leg day'), findsOneWidget);
    final tags = await db.select(db.workoutTags).get();
    expect(tags, hasLength(1));
    expect(tags.single.isDeleted, isFalse);

    await _unmountAndFlush(tester);
  });
}
