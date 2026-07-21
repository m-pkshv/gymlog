import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/date_format.dart';
import '../../core/duration_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/models/workout_tag.dart';
import '../../l10n/app_localizations.dart';
import 'controller.dart';
import 'status_labels.dart';
import 'widgets/comment_field.dart';
import 'widgets/exercise_card.dart';
import 'widgets/tag_picker_sheet.dart';
import 'widgets/workout_tag_chip.dart';

enum _ActiveWorkoutConflictResolution { finishOther, cancelOther }

/// Shared by the checkbox handler (`_WorkoutEditorScreenState`) and the
/// rest-timer bar's ±15s buttons (`_RestTimerBar`) — wrapped in its own
/// try/catch (Stage 4, TS 7.3): a notification failure must never surface
/// as an error to the owner or interrupt the underlying timer, which
/// already works from anchors regardless.
Future<void> _scheduleRestTimerNotification(
  WidgetRef ref,
  AppLocalizations l10n,
  DateTime endsAtUtc,
) async {
  try {
    await ref
        .read(notificationServiceProvider)
        .scheduleRestTimerEndNotification(
          title: l10n.restTimerNotificationTitle,
          body: l10n.restTimerNotificationBody,
          endsAtUtc: endsAtUtc,
        );
  } catch (error, stackTrace) {
    ref
        .read(loggerProvider)
        .error(
          'Failed to schedule rest timer notification',
          error: error,
          stackTrace: stackTrace,
        );
  }
}

/// S-03 workout editor: add exercises, add sets, edit plan/fact with
/// autosave, "✓" (DM 6.7), "прошлые результаты"/"копировать показатели
/// прошлого выполнения" (TS 8), the full DM 6.4.1 status menu (Stage 3),
/// moving the date, and the "Завершить/отменить текущую?" conflict dialog
/// when starting/resuming this workout would violate the "at most one
/// inProgress" invariant. Tags, progression, reorder and comments are
/// Stage 3+ scope not yet covered here.
class WorkoutEditorScreen extends ConsumerStatefulWidget {
  const WorkoutEditorScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  ConsumerState<WorkoutEditorScreen> createState() =>
      _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends ConsumerState<WorkoutEditorScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Force-write any pending debounced edit (03_TECHNICAL_SPEC.md,
      // section 5) before the OS may kill the process.
      unawaited(
        ref
            .read(workoutEditorControllerProvider(widget.workoutId).notifier)
            .flushAll(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercise = await context.push<Exercise>(
      '/history/workout/${widget.workoutId}/add-exercise',
    );
    if (exercise == null) return;
    await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .addExercise(exercise.id);
  }

  Future<void> _copyLastPerformance(String workoutExerciseId) async {
    final l10n = AppLocalizations.of(context)!;
    final copied = await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .copyLastPerformance(workoutExerciseId);
    if (!mounted || copied) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.copyLastPerformanceEmpty)));
  }

  Future<void> _changeStatus(WorkoutStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;

    // DM 6.4.1 invariant: at most one workout may be inProgress. Check
    // proactively (rather than reacting to the service's rejection) so we
    // can offer the "Завершить/отменить текущую?" dialog the spec calls
    // for, instead of just a generic error snackbar.
    if (newStatus == WorkoutStatus.inProgress) {
      final conflict = await ref
          .read(workoutRepositoryProvider)
          .getInProgressWorkout();
      if (!mounted) return;
      if (conflict != null && conflict.id != widget.workoutId) {
        final resolved = await _resolveActiveWorkoutConflict(conflict);
        if (!resolved || !mounted) return;
      }
    }

    // TS 7.2 step 6: finishing with unmarked *working* sets (warmups
    // excluded, owner-confirmed 2026-07-21 -- warmups are routinely left
    // unchecked and would make this fire on nearly every finish) asks for
    // confirmation before completing.
    if (newStatus == WorkoutStatus.completed) {
      final details = ref
          .read(workoutEditorControllerProvider(widget.workoutId))
          .value;
      final hasIncompleteWorkingSets =
          details?.exercises.any(
            (exerciseDetails) => exerciseDetails.sets.any(
              (set) => !set.isWarmup && !set.isCompleted,
            ),
          ) ??
          false;
      if (hasIncompleteWorkingSets) {
        final confirmed = await _confirmFinishWithIncompleteSets();
        if (!confirmed || !mounted) return;
      }
    }

    final result = await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .changeStatus(newStatus);
    if (!mounted) return;
    result.fold(
      (_) {
        // TS 7.2 step 6: leaving inProgress cancels any pending rest-timer
        // notification along with deleting ActiveWorkoutState.
        if (newStatus == WorkoutStatus.completed ||
            newStatus == WorkoutStatus.cancelled) {
          unawaited(_cancelRestTimerNotification());
        }
      },
      (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.workoutStatusChangeError)));
      },
    );
  }

  /// TS 7.2 step 2: called after a set is marked done — if that started a
  /// rest timer (`AppSettings.restTimerAutoStart`), requests the
  /// notification permission (contextual, first time only, TS 7.3) and
  /// schedules the "Отдых окончен" notification for it.
  Future<void> _onSetCompletedChanged(String setId, bool value) async {
    await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .setCompleted(setId, value: value);
    if (!value || !mounted) return;

    // A direct repository read, not the cached `activeWorkoutStateProvider`
    // stream value -- right after the write above, that stream may not
    // have propagated the new row yet.
    final endsAt = (await ref
            .read(activeWorkoutRepositoryProvider)
            .getByWorkoutId(widget.workoutId))
        ?.restTimerEndsAtUtc;
    if (endsAt == null || !mounted) return; // autostart off, warmup set, etc.

    await _ensureNotificationPermissionRequested();
    if (!mounted) return;
    await _scheduleRestTimerNotification(ref, AppLocalizations.of(context)!, endsAt);
  }

  /// TS 7.3: shows the app's own explanatory dialog before the system
  /// permission prompt, only the first time ever (tracked by
  /// `NotificationService`, never re-shown automatically afterward).
  Future<void> _ensureNotificationPermissionRequested() async {
    final notificationService = ref.read(notificationServiceProvider);
    try {
      if (await notificationService.hasRequestedPermission()) return;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.notificationPermissionRationaleTitle),
          content: Text(l10n.notificationPermissionRationaleMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.notificationPermissionNotNowAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.notificationPermissionAllowAction),
            ),
          ],
        ),
      );
      await notificationService.markPermissionRequested();
      if (proceed ?? false) {
        await notificationService.requestPermission();
      }
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to request notification permission',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }

  Future<void> _cancelRestTimerNotification() async {
    try {
      await ref.read(notificationServiceProvider).cancelRestTimerEndNotification();
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to cancel rest timer notification',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }

  /// TS 7.2 step 6: "Отметить оставшиеся невыполненными и завершить?" --
  /// shown only when [_changeStatus] found at least one incomplete working
  /// set. No data is written here; unmarked sets already store
  /// `isCompleted = false`, so confirming is purely permission to proceed.
  Future<bool> _confirmFinishWithIncompleteSets() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.finishWithIncompleteSetsTitle),
        content: Text(l10n.finishWithIncompleteSetsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.finishWorkoutAction),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Shows the DM 6.4.1 conflict dialog and, if the owner picks an action,
  /// finishes or cancels [conflict] (a *different* workout, not the one
  /// this screen is editing) via `workout_service` directly — this doesn't
  /// go through [WorkoutEditorController], which is scoped to this screen's
  /// own workout only. Returns whether the conflict was resolved, so the
  /// caller knows it's now safe to retry its own transition.
  Future<bool> _resolveActiveWorkoutConflict(Workout conflict) async {
    final l10n = AppLocalizations.of(context)!;
    final resolution = await showDialog<_ActiveWorkoutConflictResolution>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activeWorkoutConflictTitle),
        content: Text(l10n.activeWorkoutConflictMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(_ActiveWorkoutConflictResolution.cancelOther),
            child: Text(l10n.activeWorkoutConflictCancelOtherAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(_ActiveWorkoutConflictResolution.finishOther),
            child: Text(l10n.activeWorkoutConflictFinishOtherAction),
          ),
        ],
      ),
    );
    if (resolution == null || !mounted) return false;

    final targetStatus = resolution == _ActiveWorkoutConflictResolution.finishOther
        ? WorkoutStatus.completed
        : WorkoutStatus.cancelled;
    final result = await ref
        .read(workoutServiceProvider)
        .changeStatus(workout: conflict, newStatus: targetStatus);
    if (!mounted) return false;
    return result.fold((_) => true, (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.workoutStatusChangeError)));
      return false;
    });
  }

  Future<void> _moveDate(DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .moveDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(
      workoutEditorControllerProvider(widget.workoutId),
    );
    final controller = ref.read(
      workoutEditorControllerProvider(widget.workoutId).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.workoutEditorTitle)),
      body: detailsAsync.when(
        data: (details) => _EditorBody(
          details: details,
          controller: controller,
          onAddExercise: _addExercise,
          onChangeStatus: _changeStatus,
          onCopyLastPerformance: _copyLastPerformance,
          onMoveDate: _moveDate,
          onSetCompletedChanged: _onSetCompletedChanged,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.workoutLoadError)),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.details,
    required this.controller,
    required this.onAddExercise,
    required this.onChangeStatus,
    required this.onCopyLastPerformance,
    required this.onMoveDate,
    required this.onSetCompletedChanged,
  });

  final WorkoutDetails details;
  final WorkoutEditorController controller;
  final VoidCallback onAddExercise;
  final void Function(WorkoutStatus newStatus) onChangeStatus;
  final void Function(String workoutExerciseId) onCopyLastPerformance;
  final void Function(DateTime currentDate) onMoveDate;
  final void Function(String setId, bool value) onSetCompletedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workout = details.workout;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // DM 6.4.1: moving the date is allowed in any status except
              // inProgress.
              if (workout.status == WorkoutStatus.inProgress)
                Text(formatShortDate(workout.date))
              else
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => onMoveDate(workout.date),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(formatShortDate(workout.date)),
                  ),
                ),
              const SizedBox(width: 8),
              _StatusMenu(status: workout.status, onSelected: onChangeStatus),
              const Spacer(),
            ],
          ),
        ),
        if (workout.status == WorkoutStatus.inProgress)
          _ActiveWorkoutTimers(workoutId: workout.id, controller: controller),
        _TagsRow(workoutId: workout.id, tags: details.tags),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: CommentField(
            key: ValueKey('workout-comment-${workout.id}'),
            value: workout.comment,
            label: l10n.workoutCommentLabel,
            maxLength: CommentLengthLimits.workout,
            onChanged: controller.editWorkoutComment,
            onCommit: controller.flushWorkoutComment,
          ),
        ),
        Expanded(
          child: details.exercises.isEmpty
              ? Center(child: Text(l10n.workoutExercisesEmpty))
              : ReorderableListView.builder(
                  // ExerciseCard supplies its own drag handle (04_UI_UX_SPEC.md,
                  // section 5), so the default trailing handle is redundant.
                  buildDefaultDragHandles: false,
                  itemCount: details.exercises.length,
                  // `newIndex` here is already adjusted for the removed
                  // item at `oldIndex` (unlike the deprecated `onReorder`).
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = details.exercises
                        .map((e) => e.workoutExercise.id)
                        .toList();
                    final movedId = ids.removeAt(oldIndex);
                    ids.insert(newIndex, movedId);
                    controller.reorderExercises(ids);
                  },
                  itemBuilder: (context, index) {
                    final exerciseDetails = details.exercises[index];
                    final workoutExerciseId =
                        exerciseDetails.workoutExercise.id;
                    return ExerciseCard(
                      key: ValueKey(workoutExerciseId),
                      details: exerciseDetails,
                      index: index,
                      canMoveUp: index > 0,
                      canMoveDown: index < details.exercises.length - 1,
                      onFieldChanged: (setId, field, actual, value) {
                        controller.editSet(setId, (set) {
                          return actual
                              ? field.setActual(set, value)
                              : field.setPlanned(set, value);
                        });
                      },
                      onFieldCommit: (setId, field, actual) {
                        controller.flushSet(setId);
                      },
                      onWarmupChanged: (setId, value) {
                        controller.setWarmup(setId, value: value);
                      },
                      onCompletedChanged: onSetCompletedChanged,
                      onAddSet: () => controller.addSet(workoutExerciseId),
                      onCopyLastPerformance: () =>
                          onCopyLastPerformance(workoutExerciseId),
                      onMoveUp: () => controller.moveExercise(
                        workoutExerciseId,
                        up: true,
                      ),
                      onMoveDown: () => controller.moveExercise(
                        workoutExerciseId,
                        up: false,
                      ),
                      onCommentChanged: (value) =>
                          controller.editExerciseComment(
                            workoutExerciseId,
                            value,
                          ),
                      onCommentCommit: () =>
                          controller.flushExerciseComment(workoutExerciseId),
                      onSetCommentSaved: (setId, comment) {
                        controller.editSet(
                          setId,
                          (set) => set.copyWith(comment: comment),
                        );
                        controller.flushSet(setId);
                      },
                      onProgressionDecisionChanged: (decision) => controller
                          .setProgressionDecision(workoutExerciseId, decision),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: onAddExercise,
              icon: const Icon(Icons.add),
              label: Text(l10n.addExerciseAction),
            ),
          ),
        ),
      ],
    );
  }
}

/// Status chip with a menu of the transitions currently allowed from
/// [status] (S-03, DM 6.4.1 — "статус-чип с меню переходов (только
/// разрешённые)"). Every status has at least one allowed transition, so the
/// menu is never empty.
class _StatusMenu extends StatelessWidget {
  const _StatusMenu({required this.status, required this.onSelected});

  final WorkoutStatus status;
  final void Function(WorkoutStatus newStatus) onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<WorkoutStatus>(
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final target in allowedNextStatuses(status))
          PopupMenuItem(
            value: target,
            child: Text(workoutTransitionActionLabel(l10n, status, target)),
          ),
      ],
      child: Chip(
        label: Text(workoutStatusLabel(l10n, status)),
        avatar: const Icon(Icons.arrow_drop_down, size: 18),
      ),
    );
  }
}

/// Wraps the workout timer row and rest timer bar (S-03/S-04, Stage 4)
/// under a single once-a-second ticker, instead of each owning its own
/// `Timer.periodic` — two independent periodic timers made
/// `tester.pumpAndSettle()` pathologically slow in widget tests (it never
/// found a quiet moment where neither was about to fire), and it's wasted
/// work in production too. Both children stay plain `ConsumerWidget`s that
/// just read the current anchors fresh on every rebuild this ticker causes.
class _ActiveWorkoutTimers extends StatefulWidget {
  const _ActiveWorkoutTimers({required this.workoutId, required this.controller});

  final String workoutId;
  final WorkoutEditorController controller;

  @override
  State<_ActiveWorkoutTimers> createState() => _ActiveWorkoutTimersState();
}

class _ActiveWorkoutTimersState extends State<_ActiveWorkoutTimers> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WorkoutTimerRow(workoutId: widget.workoutId),
        _RestTimerBar(workoutId: widget.workoutId, controller: widget.controller),
      ],
    );
  }
}

/// Workout timer (S-03, Stage 4, TS 7.1): shown only while `inProgress`
/// (`ActiveWorkoutState` exists only then, DM 6.14). The elapsed value is
/// always recomputed from UTC anchors, never accumulated in memory, so a
/// missed tick (backgrounded app) never desyncs the displayed time. Pause
/// is the only manual control (rest timer is a separate, independent
/// countdown below).
class _WorkoutTimerRow extends ConsumerWidget {
  const _WorkoutTimerRow({required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(activeWorkoutStateProvider(workoutId));

    return stateAsync.maybeWhen(
      data: (state) {
        if (state == null) return const SizedBox.shrink();
        final timerService = ref.read(activeWorkoutTimerServiceProvider);
        final controller = ref.read(
          workoutEditorControllerProvider(workoutId).notifier,
        );
        final elapsed = timerService.elapsedSeconds(state);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Text(
                formatElapsedTime(elapsed),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: state.isPaused
                    ? l10n.workoutTimerResumeAction
                    : l10n.workoutTimerPauseAction,
                icon: Icon(state.isPaused ? Icons.play_arrow : Icons.pause),
                onPressed: state.isPaused
                    ? controller.resumeTimer
                    : controller.pauseTimer,
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Rest timer bar (S-04, Stage 4, TS 7.2 step 2): shown only while a rest
/// timer is running (`ActiveWorkoutState.restTimerEndsAtUtc != null`),
/// started automatically when a set is marked done (if
/// `AppSettings.restTimerAutoStart` — see
/// `_WorkoutEditorScreenState._onSetCompletedChanged`). "±15 с"
/// adjusts the running countdown and reschedules its notification
/// (TS 7.2 step 3: "отмена/перезапуск таймера — отмена/перепланирование
/// уведомления"); "Пропустить" cancels both the timer and the
/// notification. Once the remaining time goes negative this just shows
/// `00:00` until skipped or a new set starts a fresh timer.
class _RestTimerBar extends ConsumerWidget {
  const _RestTimerBar({required this.workoutId, required this.controller});

  final String workoutId;
  final WorkoutEditorController controller;

  Future<void> _adjust(BuildContext context, WidgetRef ref, int deltaSec) async {
    final l10n = AppLocalizations.of(context)!;
    await controller.adjustRestTimer(deltaSec);
    // A direct repository read, not the cached `activeWorkoutStateProvider`
    // stream value -- right after the write above, that stream may not
    // have propagated the new row yet.
    final endsAt = (await ref
            .read(activeWorkoutRepositoryProvider)
            .getByWorkoutId(workoutId))
        ?.restTimerEndsAtUtc;
    if (endsAt == null) return;
    await _scheduleRestTimerNotification(ref, l10n, endsAt);
  }

  Future<void> _skip(WidgetRef ref) async {
    await controller.skipRestTimer();
    try {
      await ref
          .read(notificationServiceProvider)
          .cancelRestTimerEndNotification();
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to cancel rest timer notification',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(activeWorkoutStateProvider(workoutId));

    return stateAsync.maybeWhen(
      data: (state) {
        if (state == null || state.restTimerEndsAtUtc == null) {
          return const SizedBox.shrink();
        }
        final timerService = ref.read(activeWorkoutTimerServiceProvider);
        final remaining = timerService.remainingRestSeconds(state) ?? 0;
        final notificationsEnabled = ref
            .watch(notificationsEnabledProvider)
            .maybeWhen(data: (enabled) => enabled, orElse: () => true);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.restTimerLabel),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.restTimerMinus15Tooltip,
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _adjust(context, ref, -15),
                  ),
                  Text(
                    formatElapsedTime(remaining),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    tooltip: l10n.restTimerPlus15Tooltip,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _adjust(context, ref, 15),
                  ),
                  TextButton(
                    onPressed: () => _skip(ref),
                    child: Text(l10n.restTimerSkipAction),
                  ),
                ],
              ),
              // TS 7.3: "ненавязчивая пометка «Уведомления выключены»" --
              // no settings deep-link (would need a new package beyond the
              // ones approved for this step), just an informational note.
              if (!notificationsEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    l10n.notificationsOffHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Assigned-tags row (S-03: "теги (чипы + «+»)") — read-only chips for each
/// tag plus a trailing "+" that opens [TagPickerSheet]. Hidden entirely
/// when `AppSettings.showTags` is off (S-17: "выключение скрывает чипы и
/// фильтр тегов, данные не меняются") — this only affects visibility, the
/// workout's tag links are untouched.
class _TagsRow extends ConsumerWidget {
  const _TagsRow({required this.workoutId, required this.tags});

  final String workoutId;
  final List<WorkoutTag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;
    if (!showTags) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final tag in tags) WorkoutTagChip(tag: tag),
          ActionChip(
            avatar: const Icon(Icons.add, size: 18),
            label: Text(l10n.workoutTagsAddAction),
            visualDensity: VisualDensity.compact,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => TagPickerSheet(workoutId: workoutId),
            ),
          ),
        ],
      ),
    );
  }
}
