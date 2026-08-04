import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' hide Exercise;
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/exercise.dart';
import 'package:gymlog/features/exercises/create_exercise_screen.dart';
import 'package:gymlog/features/exercises/exercise_detail_screen.dart';
import 'package:gymlog/features/exercises/screen.dart';
import 'package:gymlog/app/theme.dart';
import 'package:gymlog/l10n/app_localizations.dart';

Widget _appUnderTest(AppDatabase db) {
  final router = GoRouter(
    initialLocation: '/exercises',
    routes: [
      GoRoute(path: '/exercises', builder: (_, _) => const ExercisesScreen()),
      GoRoute(
        path: '/exercises/:exerciseId',
        builder: (_, state) => ExerciseDetailScreen(
          exerciseId: state.pathParameters['exerciseId']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (_, state) => MaterialPage(
              key: state.pageKey,
              fullscreenDialog: true,
              child: CreateExerciseScreen(exercise: state.extra as Exercise),
            ),
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

Future<String> _insertExercise(
  AppDatabase db, {
  required String id,
  required String name,
  bool isBuiltIn = false,
  ExerciseType type = ExerciseType.strength,
  String? customImagePath,
}) async {
  await db
      .into(db.exercises)
      .insert(
        ExercisesCompanion.insert(
          id: id,
          name: name,
          exerciseType: type.name,
          isBuiltIn: Value(isBuiltIn),
          customImagePath: Value(customImagePath),
          createdAt: '2026-07-19T00:00:00Z',
          updatedAt: '2026-07-19T00:00:00Z',
        ),
      );
  return id;
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows name, type and an empty history (S-07)', (
    tester,
  ) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    expect(find.text('Barbell Squat'), findsWidgets);
    expect(find.text('Strength'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(
      find.text('No completed workouts with this exercise yet'),
      findsOneWidget,
    );

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a custom photo (Stage 12/redesign_v2, owner-requested) renders as the '
    'detail card\'s big image instead of the placeholder glyph -- same '
    '"path just has to be set, decode doesn\'t need to succeed" approach as '
    'the catalog list icon test',
    (tester) async {
      // `Platform.pathSeparator`, not a hardcoded '/' or a bare POSIX-style
      // path like '/does/not/exist.jpg': a path with no drive letter, or
      // one mixing '/' and '\', made `dart:io` file operations hang
      // indefinitely on Windows in this environment -- a real,
      // reproducible platform quirk (see `profile_screen_test.dart`'s
      // "tapping Remove photo" test for the original investigation), not a
      // flutter_test artifact. The file itself is never created -- only
      // the path needs to be well-formed for Windows, not real.
      final imagePath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'gymlog_exercise_detail_photo_test.jpg';
      await _insertExercise(
        db,
        id: 'squat',
        name: 'Barbell Squat',
        customImagePath: imagePath,
      );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      // Full settle, not a single pump: pushing the detail route both
      // animates the page transition and kicks off `ExerciseDetailScreen`'s
      // own async `getById` load -- a single frame isn't enough for
      // `_AboutTab` (and its Image) to exist in the tree at all yet.
      await tester.pumpAndSettle();

      // `tester.widget<Image>` itself throws if the finder doesn't match
      // exactly one widget -- reaching the next line is the assertion.
      tester.widget<Image>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is FileImage &&
              (widget.image as FileImage).file.path == imagePath,
        ),
      );

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('history tab lists a completed occurrence', (tester) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
    await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: 'w1',
            date: '2026-07-20',
            status: const Value('completed'),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    await db
        .into(db.workoutExercises)
        .insert(
          WorkoutExercisesCompanion.insert(
            id: 'we1',
            workoutId: 'w1',
            exerciseId: 'squat',
            orderIndex: 0,
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );
    await db
        .into(db.exerciseSets)
        .insert(
          ExerciseSetsCompanion.insert(
            id: 's1',
            workoutExerciseId: 'we1',
            setNumber: 1,
            actualWeightKg: const Value(80),
            actualReps: const Value(5),
            createdAt: '2026-07-19T00:00:00Z',
            updatedAt: '2026-07-19T00:00:00Z',
          ),
        );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('20.07.2026'), findsOneWidget);
    expect(find.textContaining('80.0 kg'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('archiving updates the badge and menu label', (tester) async {
    await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archived'), findsOneWidget);
    final exercise = await (db.select(
      db.exercises,
    )..where((e) => e.id.equals('squat'))).getSingle();
    expect(exercise.isArchived, isTrue);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Unarchive'), findsOneWidget);

    await _unmountAndFlush(tester);
  });

  testWidgets('a built-in exercise has no Delete action', (tester) async {
    await _insertExercise(
      db,
      id: 'squat',
      name: 'Barbell Squat',
      isBuiltIn: true,
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Delete'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'a used user-created exercise has no Delete action either',
    (tester) async {
      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: 'squat',
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'deleting an unused user-created exercise removes it and pops back',
    (tester) async {
      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete this exercise?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(await (db.select(db.exercises)).get(), isEmpty);
      expect(find.text('No exercises yet'), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets('a built-in exercise has no Edit action', (tester) async {
    await _insertExercise(
      db,
      id: 'squat',
      name: 'Barbell Squat',
      isBuiltIn: true,
    );

    await tester.pumpWidget(_appUnderTest(db));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Barbell Squat'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'editing a user-created exercise pre-fills the form and saves changes',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit exercise'), findsOneWidget);
      final nameField = tester.widget<TextField>(
        find.byType(TextField).first,
      );
      expect(nameField.controller!.text, 'Barbell Squat');

      await tester.enterText(find.byType(TextField).first, 'Front Squat');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Front Squat'), findsWidgets);
      final exercise = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals('squat'))).getSingle();
      expect(exercise.name, 'Front Squat');

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'editing an exercise with an existing icon offers "Remove photo", and '
    'tapping it clears the preview back to the placeholder (Stage 12/'
    'redesign_v2, owner-requested) -- deliberately stops short of tapping '
    '"Save": that would run `ExerciseImageService.deleteFile`\'s real '
    '`File(...).exists()` check, which this environment has shown can hang '
    'indefinitely inside a widget test (a real, reproducible Windows quirk, '
    'not a bug in the removal logic itself -- confirmed separately via '
    'trace prints, and not the same "mixed path separator" cause already '
    'on record in `profile_screen_test.dart`, since the path here was '
    'already well-formed). The DB-level "customIconPath cleared when the '
    'caller omits it" guarantee this would otherwise have exercised end to '
    'end is already covered without any widget/platform boundary by '
    'exercise_repository_impl_test.dart\'s own `update` test.',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Well-formed-for-Windows temp path, not a bare POSIX-style one --
      // see the "custom photo" test above for why.
      final iconPath =
          '${Directory.systemTemp.path}${Platform.pathSeparator}'
          'gymlog_exercise_edit_remove_icon_test.jpg';
      await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              id: 'squat',
              name: 'Barbell Squat',
              exerciseType: ExerciseType.strength.name,
              customIconPath: Value(iconPath),
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // By key, not by the placeholder icon -- an existing icon renders as
      // an Image, not the Icons.image_outlined placeholder, so the icon
      // finder would find nothing here (unlike the create-mode test above).
      await tester.tap(find.byKey(const Key('exercise-icon-slot')));
      await tester.pumpAndSettle();
      expect(find.text('Remove photo'), findsOneWidget);
      await tester.tap(find.text('Remove photo'));
      await tester.pumpAndSettle();

      // The slot now falls back to the placeholder glyph instead of the
      // Image -- confirms the tap actually flipped `_iconRemoved` in local
      // state, without going anywhere near disk.
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'the type dropdown is locked once a set has been logged (DM 6.1)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await _insertExercise(db, id: 'squat', name: 'Barbell Squat');
      await db
          .into(db.workouts)
          .insert(
            WorkoutsCompanion.insert(
              id: 'w1',
              date: '2026-07-20',
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.workoutExercises)
          .insert(
            WorkoutExercisesCompanion.insert(
              id: 'we1',
              workoutId: 'w1',
              exerciseId: 'squat',
              orderIndex: 0,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );
      await db
          .into(db.exerciseSets)
          .insert(
            ExerciseSetsCompanion.insert(
              id: 's1',
              workoutExerciseId: 'we1',
              setNumber: 1,
              createdAt: '2026-07-19T00:00:00Z',
              updatedAt: '2026-07-19T00:00:00Z',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Barbell Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(
        find.text("Can't be changed: this exercise already has logged sets"),
        findsOneWidget,
      );
      final dropdown = tester.widget<DropdownButtonFormField<ExerciseType>>(
        find.byType(DropdownButtonFormField<ExerciseType>),
      );
      expect(dropdown.onChanged, isNull);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'removing an existing localization entry while editing clears it on save '
    '(Stage 10, DM 12, "Add localization")',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 5000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final id = await _insertExercise(db, id: 'squat', name: 'Squat');
      await db
          .into(db.exerciseL10n)
          .insert(
            ExerciseL10nCompanion.insert(
              exerciseId: id,
              locale: 'ru',
              name: 'Приседания',
            ),
          );

      await tester.pumpWidget(_appUnderTest(db));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Squat'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Приседания'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      final localizations = await (db.select(
        db.exerciseL10n,
      )..where((l) => l.exerciseId.equals(id))).get();
      expect(localizations, isEmpty);

      await _unmountAndFlush(tester);
    },
  );
}
