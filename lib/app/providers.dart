/// Single composition root for dependency injection (03_TECHNICAL_SPEC.md,
/// section 4). UI/services never construct `AppDatabase` or the
/// repository implementations directly — they depend on the interfaces
/// below, wired here.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/logger.dart';
import '../data/database.dart' as drift;
import '../data/repositories_impl/exercise_repository_impl.dart';
import '../data/repositories_impl/workout_repository_impl.dart';
import '../domain/models/exercise.dart';
import '../domain/models/exercise_catalog_filter.dart';
import '../domain/models/workout_details.dart';
import '../domain/models/workout_history_entry.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/workout_repository.dart';
import '../features/workout_editor/controller.dart';
import '../services/exercise_service.dart';
import '../services/workout_service.dart';

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

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService(ref.watch(workoutRepositoryProvider));
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

/// The history list (S-02). Stage 1 has no filters/calendar view yet.
final historyListProvider = StreamProvider<List<WorkoutHistoryEntry>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchHistory();
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
        ref.read(loggerProvider),
      );
    });
