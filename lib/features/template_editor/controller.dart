import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../domain/models/template_details.dart';
import '../../domain/models/template_exercise.dart';
import '../../domain/models/template_set.dart';
import '../../domain/repositories/workout_template_repository.dart';

/// Controller for the template editor (S-13) -- the template counterpart
/// of `workout_editor/controller.dart`'s `WorkoutEditorController`, trimmed
/// to what a plan-only aggregate needs: no status transitions, no dates, no
/// facts/completion, no tags, no progression. Same autosave debounce
/// contract as the workout editor (03_TECHNICAL_SPEC.md, section 5):
/// [editSet]/[editName]/[editComment]/[editExerciseComment] apply changes to
/// local state immediately and schedule a debounced write; the matching
/// `flush*` methods force an immediate write.
class TemplateEditorController
    extends StateNotifier<AsyncValue<TemplateDetails>> {
  TemplateEditorController(
    this._templateId,
    this._repository,
    this._logger,
  ) : super(const AsyncValue<TemplateDetails>.loading()) {
    unawaited(_load());
  }

  final String _templateId;
  final WorkoutTemplateRepository _repository;
  final AppLogger _logger;
  final Map<String, Timer> _setDebounceTimers = {};
  Timer? _nameDebounceTimer;
  Timer? _commentDebounceTimer;
  final Map<String, Timer> _exerciseCommentDebounceTimers = {};

  Future<void> _load() async {
    try {
      final details = await _repository.getDetails(_templateId);
      state = details == null
          ? AsyncValue<TemplateDetails>.error(
              StateError('Template $_templateId not found'),
              StackTrace.current,
            )
          : AsyncValue.data(details);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to load template $_templateId',
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncValue<TemplateDetails>.error(error, stackTrace);
    }
  }

  TemplateDetails? get _details => state.value;

  TemplateSet? _findSet(String setId) {
    for (final exercise
        in _details?.exercises ?? const <TemplateExerciseDetails>[]) {
      for (final set in exercise.sets) {
        if (set.id == setId) return set;
      }
    }
    return null;
  }

  TemplateExercise? _findExercise(String templateExerciseId) {
    for (final exercise
        in _details?.exercises ?? const <TemplateExerciseDetails>[]) {
      if (exercise.templateExercise.id == templateExerciseId) {
        return exercise.templateExercise;
      }
    }
    return null;
  }

  void _replaceExercise(TemplateExercise updated) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      TemplateDetails(
        template: details.template,
        exercises: [
          for (final exercise in details.exercises)
            exercise.templateExercise.id == updated.id
                ? TemplateExerciseDetails(
                    templateExercise: updated,
                    exercise: exercise.exercise,
                    sets: exercise.sets,
                  )
                : exercise,
        ],
      ),
    );
  }

  void _replaceSet(TemplateSet updated) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      TemplateDetails(
        template: details.template,
        exercises: [
          for (final exercise in details.exercises)
            exercise.sets.any((set) => set.id == updated.id)
                ? TemplateExerciseDetails(
                    templateExercise: exercise.templateExercise,
                    exercise: exercise.exercise,
                    sets: [
                      for (final set in exercise.sets)
                        set.id == updated.id ? updated : set,
                    ],
                  )
                : exercise,
        ],
      ),
    );
  }

  /// Applies [transform] to set [setId] immediately in local state and
  /// (re)schedules its debounced write.
  void editSet(
    String setId,
    TemplateSet Function(TemplateSet current) transform,
  ) {
    final current = _findSet(setId);
    if (current == null) return;
    _replaceSet(transform(current).copyWith(updatedAt: DateTime.now().toUtc()));
    _setDebounceTimers[setId]?.cancel();
    _setDebounceTimers[setId] = Timer(autosaveDebounce, () => flushSet(setId));
  }

  Future<void> flushSet(String setId) async {
    _setDebounceTimers.remove(setId)?.cancel();
    final set = _findSet(setId);
    if (set == null) return;
    try {
      await _repository.updateTemplateSet(set);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save template set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Warmup toggle writes immediately, like `WorkoutEditorController.setWarmup`.
  Future<void> setWarmup(String setId, {required bool value}) async {
    final current = _findSet(setId);
    if (current == null) return;
    _setDebounceTimers.remove(setId)?.cancel();
    final updated = current.copyWith(
      isWarmup: value,
      updatedAt: DateTime.now().toUtc(),
    );
    _replaceSet(updated);
    try {
      await _repository.updateTemplateSet(updated);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save template set $setId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> addExercise(String exerciseId) async {
    try {
      await _repository.addExercise(
        templateId: _templateId,
        exerciseId: exerciseId,
      );
      await _load();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to add exercise to template $_templateId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> addSet(String templateExerciseId) async {
    try {
      await _repository.addSet(
        templateExerciseId: templateExerciseId,
        isWarmup: false,
      );
      await _load();
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to add set to $templateExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void editName(String value) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      TemplateDetails(
        template: details.template.copyWith(
          name: value,
          updatedAt: DateTime.now().toUtc(),
        ),
        exercises: details.exercises,
      ),
    );
    _nameDebounceTimer?.cancel();
    _nameDebounceTimer = Timer(autosaveDebounce, flushName);
  }

  Future<void> flushName() async {
    _nameDebounceTimer?.cancel();
    _nameDebounceTimer = null;
    final details = _details;
    if (details == null) return;
    try {
      await _repository.update(details.template);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save name for template $_templateId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void editComment(String value) {
    final details = _details;
    if (details == null) return;
    state = AsyncValue.data(
      TemplateDetails(
        template: details.template.copyWith(
          comment: value,
          updatedAt: DateTime.now().toUtc(),
        ),
        exercises: details.exercises,
      ),
    );
    _commentDebounceTimer?.cancel();
    _commentDebounceTimer = Timer(autosaveDebounce, flushComment);
  }

  Future<void> flushComment() async {
    _commentDebounceTimer?.cancel();
    _commentDebounceTimer = null;
    final details = _details;
    if (details == null) return;
    try {
      await _repository.update(details.template);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save comment for template $_templateId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void editExerciseComment(String templateExerciseId, String value) {
    final current = _findExercise(templateExerciseId);
    if (current == null) return;
    _replaceExercise(
      current.copyWith(comment: value, updatedAt: DateTime.now().toUtc()),
    );
    _exerciseCommentDebounceTimers[templateExerciseId]?.cancel();
    _exerciseCommentDebounceTimers[templateExerciseId] = Timer(
      autosaveDebounce,
      () => flushExerciseComment(templateExerciseId),
    );
  }

  Future<void> flushExerciseComment(String templateExerciseId) async {
    _exerciseCommentDebounceTimers.remove(templateExerciseId)?.cancel();
    final exercise = _findExercise(templateExerciseId);
    if (exercise == null) return;
    try {
      await _repository.updateTemplateExercise(exercise);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to save comment for template exercise $templateExerciseId',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> reorderExercises(List<String> orderedTemplateExerciseIds) async {
    final details = _details;
    if (details == null) return;
    final byId = {
      for (final e in details.exercises) e.templateExercise.id: e,
    };
    final reordered = [
      for (final id in orderedTemplateExerciseIds)
        if (byId[id] != null) byId[id]!,
    ];
    state = AsyncValue.data(
      TemplateDetails(template: details.template, exercises: reordered),
    );
    try {
      await _repository.reorderExercises(
        templateId: _templateId,
        orderedTemplateExerciseIds: orderedTemplateExerciseIds,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to reorder exercises for template $_templateId',
        error: error,
        stackTrace: stackTrace,
      );
      await _load();
    }
  }

  Future<void> moveExercise(String templateExerciseId, {required bool up}) async {
    final details = _details;
    if (details == null) return;
    final ids = details.exercises.map((e) => e.templateExercise.id).toList();
    final index = ids.indexOf(templateExerciseId);
    if (index == -1) return;
    final swapWith = up ? index - 1 : index + 1;
    if (swapWith < 0 || swapWith >= ids.length) return;
    final reordered = List<String>.from(ids);
    final tmp = reordered[index];
    reordered[index] = reordered[swapWith];
    reordered[swapWith] = tmp;
    await reorderExercises(reordered);
  }

  /// Flushes every pending debounced write -- screen exit and
  /// `AppLifecycleState.paused` call this (03_TECHNICAL_SPEC.md, section 5).
  Future<void> flushAll() async {
    for (final setId in _setDebounceTimers.keys.toList()) {
      await flushSet(setId);
    }
    if (_nameDebounceTimer != null) await flushName();
    if (_commentDebounceTimer != null) await flushComment();
    for (final id in _exerciseCommentDebounceTimers.keys.toList()) {
      await flushExerciseComment(id);
    }
  }

  @override
  void dispose() {
    for (final entry in _setDebounceTimers.entries) {
      entry.value.cancel();
      final set = _findSet(entry.key);
      if (set != null) unawaited(_repository.updateTemplateSet(set));
    }
    _setDebounceTimers.clear();

    if (_nameDebounceTimer != null || _commentDebounceTimer != null) {
      _nameDebounceTimer?.cancel();
      _commentDebounceTimer?.cancel();
      final details = _details;
      if (details != null) {
        unawaited(_repository.update(details.template));
      }
    }

    for (final entry in _exerciseCommentDebounceTimers.entries) {
      entry.value.cancel();
      final exercise = _findExercise(entry.key);
      if (exercise != null) {
        unawaited(_repository.updateTemplateExercise(exercise));
      }
    }
    _exerciseCommentDebounceTimers.clear();

    super.dispose();
  }
}
