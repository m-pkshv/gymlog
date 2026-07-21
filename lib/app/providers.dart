/// Single composition root for dependency injection (03_TECHNICAL_SPEC.md,
/// section 4). UI/services never construct `AppDatabase` or the
/// repository implementations directly — they depend on the interfaces
/// below, wired here.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/logger.dart';
import '../data/database.dart' as drift;
import '../data/repositories_impl/active_workout_repository_impl.dart';
import '../data/repositories_impl/app_settings_repository_impl.dart';
import '../data/repositories_impl/exercise_repository_impl.dart';
import '../data/repositories_impl/progression_repository_impl.dart';
import '../data/repositories_impl/workout_repository_impl.dart';
import '../data/repositories_impl/workout_tag_repository_impl.dart';
import '../domain/models/active_workout_state.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/exercise.dart';
import '../domain/models/exercise_catalog_filter.dart';
import '../domain/models/exercise_progression_state.dart';
import '../domain/models/workout_details.dart';
import '../domain/models/workout_history_entry.dart';
import '../domain/models/workout_history_filter.dart';
import '../domain/models/workout_tag.dart';
import '../domain/repositories/active_workout_repository.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/progression_repository.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/repositories/workout_tag_repository.dart';
import '../features/workout_editor/controller.dart';
import '../services/active_workout_timer_service.dart';
import '../services/exercise_service.dart';
import '../services/progression_service.dart';
import '../services/workout_service.dart';
import '../services/workout_tag_service.dart';

final loggerProvider = Provider<AppLogger>((ref) => AppLogger());

final appDatabaseProvider = Provider<drift.AppDatabase>((ref) {
  final db = drift.AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(appDatabaseProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.watch(appDatabaseProvider));
});

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  return ProgressionRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The D-7 stagnation-counter algorithm (03_TECHNICAL_SPEC.md, section 9.4).
final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(exerciseRepositoryProvider),
    ref.watch(progressionRepositoryProvider),
  );
});

final activeWorkoutRepositoryProvider = Provider<ActiveWorkoutRepository>((ref) {
  return ActiveWorkoutRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The workout timer (03_TECHNICAL_SPEC.md, section 7.1).
final activeWorkoutTimerServiceProvider = Provider<ActiveWorkoutTimerService>((ref) {
  return ActiveWorkoutTimerService(ref.watch(activeWorkoutRepositoryProvider));
});

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(progressionServiceProvider),
    ref.watch(activeWorkoutTimerServiceProvider),
  );
});

final workoutTagRepositoryProvider = Provider<WorkoutTagRepository>((ref) {
  return WorkoutTagRepositoryImpl(ref.watch(appDatabaseProvider));
});

final workoutTagServiceProvider = Provider<WorkoutTagService>((ref) {
  return WorkoutTagService(ref.watch(workoutTagRepositoryProvider));
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The single point of truth for the catalog's archive/delete rules and
/// exerciseType lock (DM 10, DM 6.1).
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService(ref.watch(exerciseRepositoryProvider));
});

/// The exercise catalog list (S-06), keyed by the active search/filters
/// (`emptyExerciseCatalogFilter` for "no filtering" — e.g. the add-exercise
/// picker in the workout editor, which doesn't have its own filter UI yet).
final exercisesListProvider = StreamProvider.family<
  List<Exercise>,
  ExerciseCatalogFilter
>((ref, filter) {
  return ref.watch(exerciseRepositoryProvider).watchAll(filter: filter);
});

/// The history list (S-02), keyed by the active filters
/// (`emptyWorkoutHistoryFilter` for "the Stage 1 default" — completed only,
/// no other criteria — e.g. the copy-source picker, which always wants
/// exactly that regardless of History's own filter state).
final historyListProvider = StreamProvider.family<
  List<WorkoutHistoryEntry>,
  WorkoutHistoryFilter
>((ref, filter) {
  return ref.watch(workoutRepositoryProvider).watchHistory(filter: filter);
});

/// All non-deleted workout tags (S-03 tag picker).
final workoutTagsListProvider = StreamProvider<List<WorkoutTag>>((ref) {
  return ref.watch(workoutTagRepositoryProvider).watchAll();
});

/// The singleton app settings row — currently only `showTags` (Stage 3) has
/// a reader/writer; `AppSettingsRepositoryImpl.ensureInitialized` is called
/// once in `main.dart` before this is ever watched.
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(appSettingsRepositoryProvider).watchSettings();
});

/// The D-7 stagnation counter for one exercise (S-03 "N без роста" hint) —
/// `null` if it has no completed occurrences yet.
final progressionStateProvider = StreamProvider.family<
  ExerciseProgressionState?,
  String
>((ref, exerciseId) {
  return ref.watch(progressionRepositoryProvider).watchState(exerciseId);
});

/// The workout editor (S-03) controller, one instance per workout. Owns the
/// autosave debounce (TS 5) and the in-progress/completed transitions
/// (`workout_service`); disposed when the editor screen is popped.
final workoutEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<WorkoutEditorController, AsyncValue<WorkoutDetails>, String>((
      ref,
      workoutId,
    ) {
      return WorkoutEditorController(
        workoutId,
        ref.read(workoutRepositoryProvider),
        ref.read(workoutServiceProvider),
        ref.read(progressionServiceProvider),
        ref.read(activeWorkoutTimerServiceProvider),
        ref.read(loggerProvider),
      );
    });

/// The workout timer's live state (TS 7.1), keyed by workout id — `null`
/// while the workout isn't `inProgress` (no row exists, DM 6.14).
final activeWorkoutStateProvider = StreamProvider.family<ActiveWorkoutState?, String>((
  ref,
  workoutId,
) {
  return ref.watch(activeWorkoutRepositoryProvider).watch(workoutId);
});
