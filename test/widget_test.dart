import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymlog/app/providers.dart';
import 'package:gymlog/data/database.dart' as drift;
import 'package:gymlog/data/repositories_impl/active_workout_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/app_settings_repository_impl.dart';
import 'package:gymlog/data/repositories_impl/workout_repository_impl.dart';
import 'package:gymlog/domain/enums.dart';
import 'package:gymlog/domain/models/active_workout_state.dart';
import 'package:gymlog/features/workout_editor/screen.dart';

import 'package:gymlog/main.dart';

/// Same rationale as `exercises_flow_test.dart`: let drift's watch-stream
/// unsubscribe timer fire before flutter_test's pending-timer check runs.
Future<void> _unmountAndFlush(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

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

  testWidgets('GymLogApp shows the Today tab and a 5-item bottom nav', (
    tester,
  ) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.text('Today'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('tapping a bottom nav destination switches tabs', (tester) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsWidgets);

    await _unmountAndFlush(tester);
  });

  testWidgets('no recovery banner when nothing is inProgress', (
    tester,
  ) async {
    await tester.pumpWidget(appUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialBanner), findsNothing);

    await _unmountAndFlush(tester);
  });

  testWidgets(
    'shows a recovery banner when a workout is inProgress, and "Continue" '
    'opens it (Stage 4, TS 7.2 step 5)',
    (tester) async {
      final workout = await WorkoutRepositoryImpl(
        db,
      ).createDraft(date: DateTime(2026, 7, 21));
      await WorkoutRepositoryImpl(
        db,
      ).updateWorkout(workout.copyWith(status: WorkoutStatus.inProgress));
      final startedAt = DateTime.now().toUtc();
      await ActiveWorkoutRepositoryImpl(db).upsert(
        ActiveWorkoutState(
          workoutId: workout.id,
          startedAtUtc: startedAt,
          updatedAt: startedAt,
        ),
      );

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialBanner), findsOneWidget);
      expect(find.textContaining('Workout in progress'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutEditorScreen), findsOneWidget);

      await _unmountAndFlush(tester);
    },
  );

  testWidgets(
    'AppSettings.locale = ru switches the rendered language on the fly '
    '(S-17, Stage 9)',
    (tester) async {
      await AppSettingsRepositoryImpl(db).ensureInitialized();
      await AppSettingsRepositoryImpl(db).setLocale(AppLocale.ru);

      await tester.pumpWidget(appUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Сегодня'), findsWidgets);
      expect(find.text('Today'), findsNothing);

      await _unmountAndFlush(tester);
    },
  );
}
