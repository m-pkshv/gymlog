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
import '../../domain/models/workout_exercise.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../services/active_workout_timer_service.dart';
import '../../services/progression_service.dart';
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
    this._progressionService,
    this._activeWorkoutTimerService,
    this._logger,
  ) : super(const AsyncValue<WorkoutDetails>.loading()) {
    unawaited(_load());
  }

  final String _workoutId;
  final WorkoutRepository _workoutRepository;
  final WorkoutService _workoutService;
  final ProgressionService _progressionService;
  final ActiveWorkoutTimerService _activeWorkoutTimerService;
  final AppLogger _logger;
  final Map<String, Timer> _debounceTimers = {};
  Timer? _workoutCommentDebounceTimer;
  final Map<String, Timer> _exerciseCommentDebounceTimers = {};

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

  String? _findExerciseIdForSet(String setId) {
    for (final workoutExercise
        in _details?.exercises ?? const <WorkoutExerciseDetails>[]) {
      if (workoutExercise.sets.any((set) => set.id == setId)) {
        return workoutExercise.exercise.id;
      }
    }
    return null;
  }

  /// DM 6.10/6.11 trigger: editing a set of an *already-completed* workout
  /// changes that exercise's completed-occurrence history, so the D-7
  /// stagnation counter needs a recompute. A no-op otherwise (the workout
  /// isn't part of anyone's completed history yet).
  Future<void> _recomputeIfCompleted(String? exerciseId) async {
    if (exerciseId == null) return;
    if (_details?.workout.status != WorkoutStatus.completed) return;
    await _progressionService.recompute(exerciseId);
  }

  WorkoutExercise? _findWorkoutExercise(String workoutExerciseId) {
    for (final workoutExercise
        in _details?.exercises ?? const <WorkoutExerciseDetails>[]) {
      if (workoutExercise.workoutExercise.id == workoutExerciseId) {
        return workoutExercise.workoutExercise;
      }
    }
    return null;
  }

  void _replaceWorkoutExercise(WorkoutExercise updated) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      WorkoutDetails(
        workout: details.workout,
        tags: details.tags,
        exercises: [
          for (final workoutExercise in details.exercises)
            workoutExercise.workoutExercise.id == updated.id
                ? WorkoutExerciseDetails(
                    workoutExercise: updated,
                    exercise: workoutExercise.exercise,
                    sets: workoutExercise.sets,
                  )
                : workoutExercise,
        ],
      ),
    );
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
      await _recomputeIfCompleted(_findExerciseIdForSet(setId));
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Flushes every set/comment with a pending debounced write — screen
  /// exit and `AppLifecycleState.paused` call this (03_TECHNICAL_SPEC.md,
  /// section 5).
  Future<void> flushAll() async {
    for (final setId in _debounceTimers.keys.toList()) {
      await flushSet(setId);
    }
    if (_workoutCommentDebounceTimer != null) {
      await flushWorkoutComment();
    }
    for (final workoutExerciseId
        in _exerciseCommentDebounceTimers.keys.toList()) {
      await flushExerciseComment(workoutExerciseId);
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
      await _recomputeIfCompleted(_findExerciseIdForSet(setId));
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
      await _recomputeIfCompleted(_findExerciseIdForSet(setId));
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

  /// Changes the workout's status via `workout_service` (the status menu,
  /// S-03 — every DM 6.4.1 transition, not just draft -> inProgress ->
  /// completed). The service rejects anything not on
  /// `WorkoutService.allowedTransitions`; the UI only ever offers allowed
  /// targets, but this doesn't re-check that itself — the service is the
  /// single point of truth.
  Future<Result<Workout, AppError>> changeStatus(
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
        WorkoutDetails(
          workout: updated,
          exercises: details.exercises,
          tags: details.tags,
        ),
      );
    }, (_) {});
    return result;
  }

  /// Pauses the workout timer (TS 7.1) — the only manual control the owner
  /// has over it. A no-op if there's no active timer or it's already
  /// paused (`ActiveWorkoutTimerService.pause`).
  Future<void> pauseTimer() => _activeWorkoutTimerService.pause(_workoutId);

  /// Resumes a paused workout timer. A no-op if there's no active timer or
  /// it isn't paused.
  Future<void> resumeTimer() => _activeWorkoutTimerService.resume(_workoutId);

  /// Assigns exactly [tagIds] to this workout (S-03 tag picker/create
  /// dialog), replacing whatever was assigned before. No debounce — tag
  /// membership is a discrete toggle, like [setWarmup]/[setCompleted].
  Future<void> setTags(List<String> tagIds) async {
    try {
      await _workoutRepository.setWorkoutTags(
        workoutId: _workoutId,
        tagIds: tagIds,
      );
      await _load();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to set tags for workout $_workoutId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// "Перенос на другую дату" (DM 6.4.1: allowed in any status except
  /// `inProgress` — the UI only wires up the date tap in that case, this
  /// doesn't re-check it). A plain field write, not a status transition, so
  /// it doesn't go through `workout_service`.
  Future<void> moveDate(DateTime newDate) async {
    final details = _details;
    if (details == null) return;
    try {
      final updated = details.workout.copyWith(
        date: newDate,
        updatedAt: DateTime.now().toUtc(),
      );
      await _workoutRepository.updateWorkout(updated);
      state = AsyncValue.data(
        WorkoutDetails(
          workout: updated,
          exercises: details.exercises,
          tags: details.tags,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to move workout $_workoutId to $newDate',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Edits the workout-level comment (S-03), same debounce/flush contract
  /// as [editSet]/[flushSet] (03_TECHNICAL_SPEC.md, section 5).
  void editWorkoutComment(String value) {
    final details = _details;
    if (details == null) return;
    final updated = details.workout.copyWith(
      comment: value,
      updatedAt: DateTime.now().toUtc(),
    );
    state = AsyncValue.data(
      WorkoutDetails(
        workout: updated,
        exercises: details.exercises,
        tags: details.tags,
      ),
    );
    _workoutCommentDebounceTimer?.cancel();
    _workoutCommentDebounceTimer = Timer(autosaveDebounce, flushWorkoutComment);
  }

  /// Immediate write of the workout comment, bypassing the debounce.
  Future<void> flushWorkoutComment() async {
    _workoutCommentDebounceTimer?.cancel();
    _workoutCommentDebounceTimer = null;
    final details = _details;
    if (details == null) return;
    try {
      await _workoutRepository.updateWorkout(details.workout);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save comment for workout $_workoutId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Edits an exercise's comment (S-03), same debounce/flush contract as
  /// [editSet]/[flushSet].
  void editExerciseComment(String workoutExerciseId, String value) {
    final current = _findWorkoutExercise(workoutExerciseId);
    if (current == null) return;
    _replaceWorkoutExercise(
      current.copyWith(comment: value, updatedAt: DateTime.now().toUtc()),
    );
    _exerciseCommentDebounceTimers[workoutExerciseId]?.cancel();
    _exerciseCommentDebounceTimers[workoutExerciseId] = Timer(
      autosaveDebounce,
      () => flushExerciseComment(workoutExerciseId),
    );
  }

  /// Immediate write of an exercise's comment, bypassing the debounce.
  Future<void> flushExerciseComment(String workoutExerciseId) async {
    _exerciseCommentDebounceTimers.remove(workoutExerciseId)?.cancel();
    final workoutExercise = _findWorkoutExercise(workoutExerciseId);
    if (workoutExercise == null) return;
    try {
      await _workoutRepository.updateWorkoutExercise(workoutExercise);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save comment for exercise $workoutExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Sets an exercise's manual progression decision (S-03 segment
  /// —/↑/=/↓). Purely a user annotation (DM 6.11: "на счётчик не влияет")
  /// — never touches the D-7 stagnation counter, so no recompute here.
  /// Immediate write, like [setWarmup]/[setCompleted] — a discrete choice,
  /// not continuous typing.
  Future<void> setProgressionDecision(
    String workoutExerciseId,
    ProgressionDecision decision,
  ) async {
    final current = _findWorkoutExercise(workoutExerciseId);
    if (current == null) return;
    final updated = current.copyWith(
      progressionDecision: decision,
      updatedAt: DateTime.now().toUtc(),
    );
    _replaceWorkoutExercise(updated);
    try {
      await _workoutRepository.updateWorkoutExercise(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save progression decision for $workoutExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Full reorder from the drag handle (S-03): rewrites every
  /// `orderIndex` to match [orderedWorkoutExerciseIds]' order. Applied to
  /// local state immediately (so the dropped card doesn't snap back while
  /// the write is in flight); a failed write re-syncs from the database
  /// instead of leaving local and stored order diverged.
  Future<void> reorderExercises(List<String> orderedWorkoutExerciseIds) async {
    final details = _details;
    if (details == null) return;
    final byId = {
      for (final e in details.exercises) e.workoutExercise.id: e,
    };
    final reordered = [
      for (final id in orderedWorkoutExerciseIds)
        if (byId[id] != null) byId[id]!,
    ];
    state = AsyncValue.data(
      WorkoutDetails(
        workout: details.workout,
        exercises: reordered,
        tags: details.tags,
      ),
    );
    try {
      await _workoutRepository.reorderExercises(
        workoutId: _workoutId,
        orderedWorkoutExerciseIds: orderedWorkoutExerciseIds,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to reorder exercises for workout $_workoutId',
        error: error,
        stackTrace: stackTrace,
      );
      await _load();
    }
  }

  /// "⋮ → Вверх/Вниз" (S-03) — the gesture-free alternative to dragging:
  /// swaps [workoutExerciseId] with its immediate neighbor. A no-op at
  /// either end of the list (the UI only offers the direction that's
  /// actually available, but this doesn't re-check that itself).
  Future<void> moveExercise(
    String workoutExerciseId, {
    required bool up,
  }) async {
    final details = _details;
    if (details == null) return;
    final ids = details.exercises.map((e) => e.workoutExercise.id).toList();
    final index = ids.indexOf(workoutExerciseId);
    if (index == -1) return;
    final swapWith = up ? index - 1 : index + 1;
    if (swapWith < 0 || swapWith >= ids.length) return;
    final reordered = List<String>.from(ids);
    final tmp = reordered[index];
    reordered[index] = reordered[swapWith];
    reordered[swapWith] = tmp;
    await reorderExercises(reordered);
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

    if (_workoutCommentDebounceTimer != null) {
      _workoutCommentDebounceTimer!.cancel();
      _workoutCommentDebounceTimer = null;
      final details = _details;
      if (details != null) {
        unawaited(_workoutRepository.updateWorkout(details.workout));
      }
    }

    for (final entry in _exerciseCommentDebounceTimers.entries) {
      entry.value.cancel();
      final workoutExercise = _findWorkoutExercise(entry.key);
      if (workoutExercise != null) {
        unawaited(_workoutRepository.updateWorkoutExercise(workoutExercise));
      }
    }
    _exerciseCommentDebounceTimers.clear();

    super.dispose();
  }
}
