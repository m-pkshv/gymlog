import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/app_error.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../core/result.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise_set.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../services/workout_service.dart';
import 'set_field_config.dart';

/// Controller for the workout editor (S-03, Stage 1 minimum:
/// 02_DEVELOPMENT_PLAN.md). Owns the autosave debounce for set fields
/// (03_TECHNICAL_SPEC.md, section 5): [editSet] applies a change to local
/// state immediately (so the UI never flickers or loses keystrokes) and
/// schedules a write [autosaveDebounce] later; [flushSet]/[flushAll] force
/// an immediate write for checkbox toggles, field focus loss, leaving the
/// screen and `AppLifecycleState.paused` — so killing the process loses at
/// most one unflushed debounce interval of one field.
class WorkoutEditorController
    extends StateNotifier<AsyncValue<WorkoutDetails>> {
  WorkoutEditorController(
    this._workoutId,
    this._workoutRepository,
    this._workoutService,
    this._logger,
  ) : super(const AsyncValue<WorkoutDetails>.loading()) {
    unawaited(_load());
  }

  final String _workoutId;
  final WorkoutRepository _workoutRepository;
  final WorkoutService _workoutService;
  final AppLogger _logger;
  final Map<String, Timer> _debounceTimers = {};

  Future<void> _load() async {
    try {
      final details = await _workoutRepository.getDetails(_workoutId);
      state = details == null
          ? AsyncValue<WorkoutDetails>.error(
              StateError('Workout $_workoutId not found'),
              StackTrace.current,
            )
          : AsyncValue.data(details);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load workout $_workoutId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue<WorkoutDetails>.error(error, stackTrace);
    }
  }

  /// Re-reads the whole aggregate — used after structural changes (adding
  /// an exercise or a set) rather than reconciling the tree by hand.
  Future<void> reload() => _load();

  WorkoutDetails? get _details => state.value;

  ExerciseSet? _findSet(String setId) {
    for (final workoutExercise
        in _details?.exercises ?? const <WorkoutExerciseDetails>[]) {
      for (final set in workoutExercise.sets) {
        if (set.id == setId) return set;
      }
    }
    return null;
  }

  void _replaceSet(ExerciseSet updated) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      WorkoutDetails(
        workout: details.workout,
        exercises: [
          for (final workoutExercise in details.exercises)
            workoutExercise.sets.any((set) => set.id == updated.id)
                ? WorkoutExerciseDetails(
                    workoutExercise: workoutExercise.workoutExercise,
                    exercise: workoutExercise.exercise,
                    sets: [
                      for (final set in workoutExercise.sets)
                        set.id == updated.id ? updated : set,
                    ],
                  )
                : workoutExercise,
        ],
      ),
    );
  }

  /// Applies [transform] to set [setId] immediately in local state and
  /// (re)schedules its debounced write.
  void editSet(
    String setId,
    ExerciseSet Function(ExerciseSet current) transform,
  ) {
    final current = _findSet(setId);
    if (current == null) return;
    _replaceSet(transform(current).copyWith(updatedAt: DateTime.now().toUtc()));
    _debounceTimers[setId]?.cancel();
    _debounceTimers[setId] = Timer(
      autosaveDebounce,
      () => flushSet(setId),
    );
  }

  /// Immediate write for set [setId], bypassing the debounce.
  Future<void> flushSet(String setId) async {
    _debounceTimers.remove(setId)?.cancel();
    final set = _findSet(setId);
    if (set == null) return;
    try {
      await _workoutRepository.updateSet(set);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Flushes every set with a pending debounced write — screen exit and
  /// `AppLifecycleState.paused` call this (03_TECHNICAL_SPEC.md, section 5).
  Future<void> flushAll() async {
    for (final setId in _debounceTimers.keys.toList()) {
      await flushSet(setId);
    }
  }

  /// Toggles `isCompleted`; ticking on copies plan into empty facts (DM
  /// 6.7). Checkbox changes write immediately, never debounced.
  Future<void> setCompleted(String setId, {required bool value}) async {
    final current = _findSet(setId);
    if (current == null) return;
    _debounceTimers.remove(setId)?.cancel();
    final now = DateTime.now().toUtc();
    final updated = value
        ? current.markCompleted().copyWith(updatedAt: now)
        : current.copyWith(isCompleted: false, updatedAt: now);
    _replaceSet(updated);
    try {
      await _workoutRepository.updateSet(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> setWarmup(String setId, {required bool value}) async {
    final current = _findSet(setId);
    if (current == null) return;
    _debounceTimers.remove(setId)?.cancel();
    final updated = current.copyWith(
      isWarmup: value,
      updatedAt: DateTime.now().toUtc(),
    );
    _replaceSet(updated);
    try {
      await _workoutRepository.updateSet(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Adds [exerciseId] to the workout ("+ Упражнение", S-03).
  Future<void> addExercise(String exerciseId) async {
    try {
      await _workoutRepository.addExercise(
        workoutId: _workoutId,
        exerciseId: exerciseId,
      );
      await _load();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to add exercise to workout $_workoutId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Adds a working set to [workoutExerciseId] ("+ Подход", S-03).
  Future<void> addSet(String workoutExerciseId) async {
    try {
      await _workoutRepository.addSet(
        workoutExerciseId: workoutExerciseId,
        isWarmup: false,
      );
      await _load();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to add set to $workoutExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// "Копировать показатели прошлого выполнения" (S-03, TS 8): the actual
  /// values of this exercise's most recent *completed* occurrence become
  /// the *planned* values of the current sets, matched by `setNumber`
  /// order. A mismatched count is handled per TS 8: missing sets are
  /// appended (new rows, isWarmup copied from the historical set), extra
  /// current sets are left untouched. Returns `false` (no write attempted)
  /// if this exercise has no completed history yet or the write failed —
  /// the caller decides what to tell the user either way.
  Future<bool> copyLastPerformance(String workoutExerciseId) async {
    final details = _details;
    if (details == null) return false;
    WorkoutExerciseDetails? target;
    for (final workoutExercise in details.exercises) {
      if (workoutExercise.workoutExercise.id == workoutExerciseId) {
        target = workoutExercise;
        break;
      }
    }
    if (target == null) return false;

    try {
      final history = await _workoutRepository.getExerciseHistory(
        target.exercise.id,
      );
      if (history.isEmpty) return false;

      final lastSets = List<ExerciseSet>.from(history.first.sets)
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      final currentSets = List<ExerciseSet>.from(target.sets)
        ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
      final type = target.exercise.exerciseType;

      for (var i = 0; i < lastSets.length; i++) {
        final historical = lastSets[i];
        final destination = i < currentSets.length
            ? currentSets[i]
            : await _workoutRepository.addSet(
                workoutExerciseId: workoutExerciseId,
                isWarmup: historical.isWarmup,
              );
        await _workoutRepository.updateSet(
          copyActualsToPlanned(
            historical,
            destination,
            type,
          ).copyWith(updatedAt: DateTime.now().toUtc()),
        );
      }
      await _load();
      return true;
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to copy last performance for $workoutExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// "Начать тренировку": `draft -> inProgress` via `workout_service`
  /// (Stage 1 scope — no full status menu yet).
  Future<Result<Workout, AppError>> start() =>
      _changeStatus(WorkoutStatus.inProgress);

  /// "Завершить": `inProgress -> completed` via `workout_service`.
  Future<Result<Workout, AppError>> finish() =>
      _changeStatus(WorkoutStatus.completed);

  Future<Result<Workout, AppError>> _changeStatus(
    WorkoutStatus newStatus,
  ) async {
    await flushAll();
    final details = _details;
    if (details == null) {
      return const Err(UnknownError('Workout not loaded'));
    }
    final result = await _workoutService.changeStatus(
      workout: details.workout,
      newStatus: newStatus,
    );
    result.fold((updated) {
      state = AsyncValue.data(
        WorkoutDetails(workout: updated, exercises: details.exercises),
      );
    }, (_) {});
    return result;
  }

  @override
  void dispose() {
    // Force-write on screen leave (03_TECHNICAL_SPEC.md, section 5): the
    // provider is disposed synchronously, so pending writes are fired and
    // forgotten rather than awaited — the repository/database outlive this
    // controller.
    for (final entry in _debounceTimers.entries) {
      entry.value.cancel();
      final set = _findSet(entry.key);
      if (set != null) {
        unawaited(_workoutRepository.updateSet(set));
      }
    }
    _debounceTimers.clear();
    super.dispose();
  }
}
