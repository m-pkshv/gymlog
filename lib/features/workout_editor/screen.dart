import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/constants.dart';
import '../../core/date_format.dart';
import '../../core/duration_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/rest_timer_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../../core/widgets/workout_status_menu.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout_details.dart';
import '../../domain/models/workout_tag.dart';
import '../../l10n/app_localizations.dart';
import '../history/active_workout_conflict.dart';
import '../history/copy_workout_flow.dart';
import '../history/create_template_from_workout_flow.dart';
import 'controller.dart';
import 'export_workout_pdf_flow.dart';
import 'status_labels.dart';
import 'widgets/comment_field.dart';
import 'widgets/exercise_card.dart';
import 'widgets/tag_picker_sheet.dart';
import 'widgets/workout_tag_chip.dart';

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
  // Owner-reported (Stage 10, TS 11.6, 2026-07-28): a stutter right as this
  // screen slides in -- e.g. after creating a workout from a template. Root
  // cause found via on-device profiling: building the full exercise list
  // (each card costing real, unavoidable time -- see `CLAUDE.md`, Stage
  // 10/Step 25) happens synchronously as part of this widget's very first
  // build, which Flutter must run *before* it can paint even the first
  // frame of the push transition -- so the transition's own `Animation`
  // never gets a chance to render a single real frame while blocked; by
  // the time the block clears, the animation's internal clock (driven by
  // real elapsed time) already reads `completed`, since more wall-clock
  // time passed during the block than the whole transition's duration.
  // Listening for `AnimationStatus.completed` therefore fires immediately
  // and changes nothing (confirmed via device logging, not guessed).
  // Instead: keep the very first build cheap (a spinner) unconditionally,
  // let that first frame paint, then wait out the route's own configured
  // `transitionDuration` before switching to the real content -- by then
  // the transition has had genuine real frames to animate across, and the
  // expensive build happens once the screen is already at rest.
  bool _transitionSettled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_deferUntilTransitionSettles);
  }

  void _deferUntilTransitionSettles(Duration _) {
    final duration =
        ModalRoute.of(context)?.transitionDuration ?? Duration.zero;
    Future.delayed(duration, () {
      if (mounted) setState(() => _transitionSettled = true);
    });
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
      '/workout/${widget.workoutId}/add-exercise',
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

  /// "Удалить" a set (S-03 set menu, Stage 10, owner-reported): soft-delete
  /// + 5s Undo snackbar, same pattern as workout/measurement deletion
  /// (DM 10) — the confirmation dialog other deletions use (tags) doesn't
  /// apply here, since a set is trivially cheap to re-add if the Undo
  /// window is missed.
  Future<void> _deleteSet(String setId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(
      workoutEditorControllerProvider(widget.workoutId).notifier,
    );
    final deleted = await controller.deleteSet(setId);
    if (!mounted || !deleted) return;
    showUndoSnackbar(
      context,
      message: l10n.setDeletedMessage,
      actionLabel: l10n.undoAction,
      onUndo: () => controller.restoreSet(setId),
    );
  }

  /// "Удалить упражнение" (S-03 exercise card menu, Stage 10, owner-
  /// reported: no way to remove an exercise added by mistake, or drop one
  /// from a workout copied/created from a template without touching the
  /// source). Same soft-delete + 5s Undo snackbar shape as [_deleteSet].
  Future<void> _deleteExercise(String workoutExerciseId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(
      workoutEditorControllerProvider(widget.workoutId).notifier,
    );
    final deleted = await controller.deleteExercise(workoutExerciseId);
    if (!mounted || !deleted) return;
    showUndoSnackbar(
      context,
      message: l10n.exerciseDeletedMessage,
      actionLabel: l10n.undoAction,
      onUndo: () => controller.restoreExercise(workoutExerciseId),
    );
  }

  /// "Редактировать упражнение" (S-03 exercise card menu, Stage 10, owner-
  /// reported: a plain rename wasn't enough -- the owner wanted the same
  /// full edit form the catalog offers, without leaving the workout).
  /// Pushes the *same* `CreateExerciseScreen` widget the catalog's own
  /// "⋮ → Edit" uses (in edit mode), just registered at a second route
  /// nested under this already-top-level `/workout/:workoutId` (see
  /// `app/router.dart`'s top comment for why that placement matters) --
  /// no new form, no new perf cost beyond a screen push already exercised
  /// by "+ Добавить упражнение → Создать новое" from this same editor.
  /// Mirrors `ExerciseDetailScreen._edit()`: [exercise] (from `details`)
  /// may carry DM 12 localized text, so the canonical record is re-fetched
  /// before handing it to the form, and the controller is reloaded
  /// afterwards since a write through a different aggregate
  /// (`ExerciseRepository`, not this screen's `WorkoutRepository`) never
  /// triggers one on its own. Only ever reachable for a user-created
  /// exercise (the menu hides this item for a built-in one, DM 10).
  Future<void> _editExercise(Exercise exercise) async {
    final canonical = await ref
        .read(exerciseRepositoryProvider)
        .getById(exercise.id);
    if (canonical == null || !mounted) return;
    final updated = await context.push<Exercise>(
      '/workout/${widget.workoutId}/edit-exercise/${exercise.id}',
      extra: canonical,
    );
    if (updated != null && mounted) {
      ref
          .read(workoutEditorControllerProvider(widget.workoutId).notifier)
          .reload();
    }
  }

  Future<void> _changeStatus(WorkoutStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    // Captured before the write below (after it, the controller's cached
    // status already reads as `newStatus`) -- only used to recognize the
    // draft -> planned transition specifically (see the "Schedule" pop
    // below), not skipped/cancelled -> planned ("Вернуть в план"), which
    // reaches `planned` too but isn't part of this owner report.
    final fromStatus = ref
        .read(workoutEditorControllerProvider(widget.workoutId))
        .value
        ?.workout
        .status;

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
        final resolved = await resolveActiveWorkoutConflict(
          context,
          ref,
          conflict,
        );
        if (!resolved || !mounted) return;
      }
    }

    // TS 7.2 step 6: finishing with unmarked sets asks for confirmation
    // before completing (Stage 10, 2026-07-23: the warm-up concept was
    // removed -- every set now counts).
    if (newStatus == WorkoutStatus.completed) {
      final details = ref
          .read(workoutEditorControllerProvider(widget.workoutId))
          .value;
      final hasIncompleteSets =
          details?.exercises.any(
            (exerciseDetails) =>
                exerciseDetails.sets.any((set) => !set.isCompleted),
          ) ??
          false;
      if (hasIncompleteSets) {
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
        // TS 7.2 step 6: "... → итоговый экран" (S-05). A replacement, not
        // an additional push, so "back" from the summary lands wherever
        // "back" would have from the editor -- whichever tab/screen it was
        // opened from (`app/router.dart`'s top comment).
        if (newStatus == WorkoutStatus.completed) {
          context.pushReplacement('/workout/${widget.workoutId}/summary');
        } else if (fromStatus == WorkoutStatus.draft &&
            newStatus == WorkoutStatus.planned) {
          // Owner-reported: tapping the new "Запланировать" secondary CTA
          // (a fresh draft's only other option besides "Начать", DM 6.4.1)
          // should leave the editor too, same as finishing does -- the
          // owner is done with this workout for now.
          context.pop();
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
    final endsAt =
        (await ref
                .read(activeWorkoutRepositoryProvider)
                .getByWorkoutId(widget.workoutId))
            ?.restTimerEndsAtUtc;
    if (endsAt == null || !mounted) return; // autostart off, etc.

    await _ensureNotificationPermissionRequested();
    if (!mounted) return;
    await _ensureExactAlarmPermissionRequested();
    if (!mounted) return;
    await _scheduleRestTimerNotification(
      ref,
      AppLocalizations.of(context)!,
      endsAt,
    );
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

  /// Same contextual, asked-once pattern as
  /// [_ensureNotificationPermissionRequested], for the "Alarms & reminders"
  /// special access `AndroidScheduleMode.alarmClock` needs (Stage 12,
  /// owner-reported: without it, `scheduleRestTimerEndNotification` throws
  /// `PlatformException(exact_alarms_not_permitted)` on Android 14+ — see
  /// `NotificationService`/`AndroidManifest.xml` for how that was
  /// diagnosed). Checks live OS state first (unlike the notifications flow,
  /// this one is auto-granted on many devices/OS versions, so there's often
  /// nothing to ask for at all) and only shows the app's own rationale
  /// before sending the user to the OS settings screen -- there is no
  /// runtime dialog for this permission.
  Future<void> _ensureExactAlarmPermissionRequested() async {
    final notificationService = ref.read(notificationServiceProvider);
    try {
      if (await notificationService.hasExactAlarmPermission()) return;
      if (await notificationService.hasRequestedExactAlarmPermission()) return;
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.exactAlarmPermissionRationaleTitle),
          content: Text(l10n.exactAlarmPermissionRationaleMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.notificationPermissionNotNowAction),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.exactAlarmPermissionOpenSettingsAction),
            ),
          ],
        ),
      );
      await notificationService.markExactAlarmPermissionRequested();
      if (proceed ?? false) {
        await notificationService.requestExactAlarmPermission();
      }
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to request exact alarm permission',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }

  Future<void> _cancelRestTimerNotification() async {
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

  /// "⋮ → Создать шаблон" (Stage 10, owner-reported): any workout can be
  /// saved as a template right from the editor, not only from a History
  /// card -- `createTemplateFromWorkoutFlow` already only ever copies
  /// exercises/order/planned values, never actuals or completion marks
  /// (`WorkoutTemplateRepository.createFromWorkout`'s doc comment), so
  /// there's nothing extra to reset here for a still-`inProgress` or
  /// `completed` workout with marked-off sets.
  Future<void> _saveAsTemplate() async {
    final workout = ref
        .read(workoutEditorControllerProvider(widget.workoutId))
        .value
        ?.workout;
    if (workout == null) return;
    await createTemplateFromWorkoutFlow(context, ref, workout);
  }

  /// "⋮ → Экспортировать в PDF" (Stage 11) -- available regardless of
  /// status, same as "Создать шаблон" above.
  Future<void> _exportPdf() async {
    final details = ref
        .read(workoutEditorControllerProvider(widget.workoutId))
        .value;
    if (details == null) return;
    await exportWorkoutPdfFlow(context, ref, details);
  }

  /// Secondary bottom CTA for a completed workout, next to "Возобновить"
  /// (Stage 12/redesign_v2, owner-reported): "Копировать" already existed,
  /// but only from History's own card "⋮" menu -- open the workout first
  /// to confirm it's the right one, then copy it to a new date with one
  /// button right here, no trip back to History needed. Reuses the exact
  /// same [copyWorkoutFlow] History's own menu calls, so the date prompt/
  /// error handling/opening the copy can't drift out of sync between the
  /// two entry points.
  ///
  /// `replaceCurrentRoute: true` (owner-reported follow-up): this editor
  /// is itself already pushed on top of Today/History, so a plain `push`
  /// for the copy would leave *this* (the source) editor sitting in the
  /// stack underneath it -- scheduling/finishing/deleting the copy would
  /// then just pop back onto the source workout instead of all the way
  /// out to whichever tab root the source was opened from. Replacing
  /// this route with the copy's is the exact same fix already applied to
  /// the "Копией" *picker* (`copy_workout_flow.dart`'s own doc comment):
  /// once the source has done its one job (confirming it's the right
  /// workout to copy), it's replaced in the stack rather than left
  /// underneath.
  Future<void> _copyToNewDate() async {
    final workout = ref
        .read(workoutEditorControllerProvider(widget.workoutId))
        .value
        ?.workout;
    if (workout == null) return;
    await copyWorkoutFlow(context, ref, workout, replaceCurrentRoute: true);
  }

  /// "⋮ → Удалить" in the redesigned status menu (Stage 10 redesign) --
  /// the editor never had its own delete action before (only History did,
  /// Stage 3/Step 9); reuses the exact same `WorkoutService.delete`/
  /// `restore` + 5s Undo snackbar pattern, since the underlying rule (DM
  /// 10: rejected while `inProgress`) is the service's job, not this
  /// screen's -- the menu offers it unconditionally and surfaces the
  /// service's rejection as an error snackbar, same as History does.
  Future<void> _deleteWorkout() async {
    final l10n = AppLocalizations.of(context)!;
    final workout = ref
        .read(workoutEditorControllerProvider(widget.workoutId))
        .value
        ?.workout;
    if (workout == null) return;
    final result = await ref.read(workoutServiceProvider).delete(workout);
    if (!mounted) return;
    result.fold(
      (_) {
        showUndoSnackbar(
          context,
          message: l10n.workoutDeletedMessage,
          actionLabel: l10n.undoAction,
          onUndo: () => ref.read(workoutServiceProvider).restore(workout.id),
        );
        // Owner-reported: this used to hardcode `context.go('/history')`,
        // which always landed on History regardless of which tab the
        // workout was opened from -- same class of bug as the summary
        // screen's "Готово" button. Popping leaves this editor's own
        // top-level route (`app/router.dart`'s top comment) and reveals
        // exactly what was there before.
        context.pop();
      },
      (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteWorkoutError))),
    );
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

  /// Tapping the AppBar title (Stage 10, owner-reported: mirrors tapping
  /// the date to open [_moveDate]) -- no status restriction, unlike the
  /// date (DM 6.4.1 only forbids moving the date while `inProgress`;
  /// renaming has no such conflict, same as the comment field which is
  /// already editable in any status).
  Future<void> _renameWorkout(String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _RenameWorkoutDialog(initialName: currentName),
    );
    if (newName == null || !mounted) return;
    await ref
        .read(workoutEditorControllerProvider(widget.workoutId).notifier)
        .renameWorkout(newName);
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

    // Stage 10 redesign, owner-reported: the AppBar used to show a generic
    // "Тренировка" literal (l10n.workoutEditorTitle) for every workout
    // regardless of its actual name, with the running timer in its own
    // oversized row below and the tags row always present even with zero
    // tags assigned -- together leaving barely two sets visible on screen.
    // The mockup keeps the header to one compact line: the workout's own
    // name plus a small tappable elapsed-time chip, so the AppBar itself
    // now needs `details` and is built per-state instead of once outside
    // `.when()`.
    return detailsAsync.when(
      data: (details) {
        final workout = details.workout;
        final isActive = workout.status == WorkoutStatus.inProgress;
        final scaffold = Scaffold(
          appBar: AppBar(
            // Owner-reported: too much air below the title. Most of the
            // default 56dp toolbar's height sits below the vertically-
            // centered title text -- shrinking to the Material minimum
            // (48dp) removes most of that, on top of the row padding
            // below (also tightened).
            toolbarHeight: 48,
            title: Semantics(
              button: true,
              label: l10n.renameWorkoutTooltip,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.control),
                onTap: () => _renameWorkout(
                  workout.name ?? l10n.workoutDefaultNamePrefix,
                ),
                child: Tooltip(
                  message: workout.name ?? l10n.workoutDefaultNamePrefix,
                  child: Text(
                    workout.name ?? l10n.workoutDefaultNamePrefix,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            actions: [
              if (isActive)
                _WorkoutTimerAction(
                  workoutId: widget.workoutId,
                  controller: controller,
                ),
            ],
          ),
          // While the push transition is still animating in, the AppBar
          // above is already showing the real title/timer (cheap to
          // build) -- only the expensive exercise list is deferred, so a
          // returning user isn't staring at a fully blank screen.
          body: _transitionSettled
              ? _EditorBody(
                  details: details,
                  controller: controller,
                  onAddExercise: _addExercise,
                  onChangeStatus: _changeStatus,
                  onCopyLastPerformance: _copyLastPerformance,
                  onMoveDate: _moveDate,
                  onSetCompletedChanged: _onSetCompletedChanged,
                  onSetDeleted: _deleteSet,
                  onEditExercise: _editExercise,
                  onDeleteExercise: _deleteExercise,
                  onSaveAsTemplate: _saveAsTemplate,
                  onDeleteWorkout: _deleteWorkout,
                  onExportPdf: _exportPdf,
                  onCopyToNewDate: _copyToNewDate,
                )
              : const Center(child: CircularProgressIndicator()),
        );
        // A single shared ticker for both the AppBar timer chip and the
        // rest-timer card below (S-03/S-04, Stage 4) -- two independent
        // `Timer.periodic`s previously made `tester.pumpAndSettle()`
        // pathologically slow in widget tests (it never found a quiet
        // moment where neither was about to fire).
        return isActive ? _ActiveWorkoutTicker(child: scaffold) : scaffold;
      },
      loading: () => Scaffold(
        appBar: AppBar(toolbarHeight: 48, title: Text(l10n.workoutEditorTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(toolbarHeight: 48, title: Text(l10n.workoutEditorTitle)),
        body: ErrorRetryState(
          message: l10n.workoutLoadError,
          onRetry: () =>
              ref.invalidate(workoutEditorControllerProvider(widget.workoutId)),
        ),
      ),
    );
  }
}

/// Rename dialog opened by tapping the AppBar title (Stage 10, owner-
/// reported). Unlike `CreateTemplateDialog`, a blank result is a valid,
/// meaningful answer here (DM 6.4: clears `name` back to the "Тренировка"
/// fallback), so there's no "Save" validation gate to speak of -- this
/// just returns whatever's typed, trimmed, on "Сохранить".
///
/// For an unnamed workout, the caller passes the localized fallback label
/// itself as [initialName] (Stage 12, owner-reported) instead of leaving
/// the field empty with just a hint: the placeholder text isn't real,
/// selectable text, so a user trying to tap past its end to append
/// something found the caret stuck at the only position an empty field
/// has (offset 0). Pre-filling with the real label gives the caret
/// somewhere to actually sit.
class _RenameWorkoutDialog extends StatefulWidget {
  const _RenameWorkoutDialog({required this.initialName});

  final String initialName;

  @override
  State<_RenameWorkoutDialog> createState() => _RenameWorkoutDialogState();
}

class _RenameWorkoutDialogState extends State<_RenameWorkoutDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // `TextEditingController(text: ...)` alone leaves the selection
    // unset, which places the caret at the very start of the text on
    // first focus rather than the end -- a well-known Flutter gotcha.
    // Set it explicitly so the caret starts right after the pre-filled
    // name, ready to append or backspace it away.
    _nameController = TextEditingController.fromValue(
      TextEditingValue(
        text: widget.initialName,
        selection: TextSelection.collapsed(
          offset: widget.initialName.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.renameWorkoutTitle),
      content: TextField(
        controller: _nameController,
        autofocus: true,
        maxLength: WorkoutNameRules.maxNameLength,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.workoutNameLabel,
          hintText: l10n.workoutDefaultNamePrefix,
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_nameController.text),
          child: Text(l10n.actionSave),
        ),
      ],
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
    required this.onSetDeleted,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onSaveAsTemplate,
    required this.onDeleteWorkout,
    required this.onExportPdf,
    required this.onCopyToNewDate,
  });

  final WorkoutDetails details;
  final WorkoutEditorController controller;
  final VoidCallback onAddExercise;
  final void Function(WorkoutStatus newStatus) onChangeStatus;
  final void Function(String workoutExerciseId) onCopyLastPerformance;
  final void Function(DateTime currentDate) onMoveDate;
  final void Function(String setId, bool value) onSetCompletedChanged;
  final ValueChanged<String> onSetDeleted;
  final ValueChanged<Exercise> onEditExercise;
  final ValueChanged<String> onDeleteExercise;
  final VoidCallback onSaveAsTemplate;
  final VoidCallback onDeleteWorkout;
  final VoidCallback onExportPdf;
  final VoidCallback onCopyToNewDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workout = details.workout;

    return Column(
      children: [
        Padding(
          // Owner-reported: too much air between the AppBar's title (the
          // workout's own name) and this row (date/status/tags) below it
          // -- most of that gap turned out to be the AppBar's own default
          // toolbar height (also tightened, see the AppBar above), not
          // this padding, plus the row's cross-axis centering against its
          // tallest children (fixed below, `.start`). Owner-reported
          // (third follow-up): 0 read as too tight once the other two
          // fixes landed -- split the difference between that and the
          // pre-fix gap (measured 26px / 58px on device -> ~6dp here).
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            // Owner-reported (follow-up): the remaining gap wasn't really
            // "space above the date/status" -- it's the default `.center`
            // cross-axis alignment centering the short date text/badge
            // against this row's tallest children (the 48dp icon-button
            // touch targets, kept at 48dp per UX 11 -- not shrinking
            // those). `.start` aligns everything to the row's own top
            // edge instead, which already sits flush against the AppBar.
            crossAxisAlignment: CrossAxisAlignment.start,
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
              StatusBadge(status: workout.status),
              const Spacer(),
              // The row is top-aligned (`CrossAxisAlignment.start` above)
              // so the date/status stay flush against the AppBar, but
              // that leaves these two icon buttons -- taller than the
              // text/badge even at compact density -- looking shifted
              // down instead of level with them. Nudged up by eye/
              // on-device measurement (Stage 10 redesign, owner-reported)
              // to land their icon's visual center on the same line as
              // the date/badge's.
              Transform.translate(
                offset: const Offset(0, -8),
                child: _TagAddButton(workoutId: workout.id),
              ),
              Transform.translate(
                offset: const Offset(0, -8),
                child: WorkoutStatusMenu(
                  key: const ValueKey('workout-status-menu'),
                  status: workout.status,
                  excludeStatuses: {
                    primaryStatusCtaTransition(workout.status),
                    ?secondaryStatusCtaTransition(workout.status),
                  },
                  onSelectStatus: onChangeStatus,
                  onSaveAsTemplate: onSaveAsTemplate,
                  onDelete: onDeleteWorkout,
                  onExportPdf: onExportPdf,
                ),
              ),
            ],
          ),
        ),
        _AssignedTagsWrap(tags: details.tags),
        if (workout.status == WorkoutStatus.inProgress)
          _RestTimerBar(workoutId: workout.id, controller: controller),
        Expanded(
          // Owner-reported (Stage 10): tapping a set's stepper/checkbox/
          // delete icon etc. while the comment field below still had focus
          // used to leave its keyboard open and pointed at a field the
          // user had already moved on from -- every touch in this
          // scrollable now drops focus first, same as the precise-entry
          // dialog's own trigger already did
          // (`NumericStepperField._openPreciseEntry`). A `Listener` on
          // `onPointerDown`, not a `GestureDetector.onTap`: a plain
          // ancestor `GestureDetector` competes with every button/checkbox
          // underneath for the same tap in Flutter's gesture arena, and
          // usually loses (buttons' own `InkWell` recognizers tend to win
          // clean taps) -- confirmed by a failing test with that first
          // attempt, not assumed. `Listener.onPointerDown` fires on every
          // raw pointer-down regardless of which recognizer later wins the
          // gesture, so it reliably unfocuses whichever button gets tapped,
          // while `HitTestBehavior.translucent` still lets that tap fall
          // through untouched to the field/button underneath it.
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            child: CustomScrollView(
              scrollCacheExtent: const ScrollCacheExtent.pixels(2000),
              slivers: [
                if (details.exercises.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      child: Center(child: Text(l10n.workoutExercisesEmpty)),
                    ),
                  )
                else
                  SliverList.builder(
                    // Owner-reported (Stage 10): the drag handle made
                    // reordering feel sluggish on a screen already busy with
                    // large exercise cards -- removed in favour of the
                    // "⋮ → Вверх/Вниз" menu on each card as the *only* way to
                    // reorder now (it already existed as the gesture-free
                    // alternative, DM/UX 11), so no replacement control is
                    // needed here beyond a plain, non-reorderable list.
                    itemCount: details.exercises.length,
                    itemBuilder: (context, index) {
                      final exerciseDetails = details.exercises[index];
                      final workoutExerciseId =
                          exerciseDetails.workoutExercise.id;
                      return ExerciseCard(
                        key: ValueKey(workoutExerciseId),
                        details: exerciseDetails,
                        isActive: workout.status == WorkoutStatus.inProgress,
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
                        onCompletedChanged: onSetCompletedChanged,
                        onAddSet: () => controller.addSet(workoutExerciseId),
                        onDuplicateLastSet: () =>
                            controller.duplicateLastSet(workoutExerciseId),
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
                        onSetDeleted: onSetDeleted,
                        onProgressionDecisionChanged: (decision) =>
                            controller.setProgressionDecision(
                              workoutExerciseId,
                              decision,
                            ),
                        onEditExercise: () =>
                            onEditExercise(exerciseDetails.exercise),
                        onDeleteExercise: () =>
                            onDeleteExercise(workoutExerciseId),
                      );
                    },
                  ),
                // Owner-reported (Stage 10 redesign): "+ Добавить упражнение"
                // used to be pinned at the bottom of the screen next to
                // Start/Finish; moved into this same scrollable, right below
                // the last exercise card and above the comment field.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Center(
                      child: OutlinedButton.icon(
                        onPressed: onAddExercise,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addExerciseAction),
                      ),
                    ),
                  ),
                ),
                // Owner-reported (Stage 10 redesign): the workout comment used
                // to be pinned above the exercise list, staying on screen while
                // scrolling; moved into this same scrollable, always after the
                // last exercise, so it scrolls with them instead of pinning.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: CommentField(
                      key: ValueKey('workout-comment-${workout.id}'),
                      value: workout.comment,
                      label: l10n.workoutCommentLabel,
                      maxLength: CommentLengthLimits.workout,
                      onChanged: controller.editWorkoutComment,
                      onCommit: controller.flushWorkoutComment,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Builder(
              builder: (context) {
                final primaryButton = _StatusCtaButton(
                  key: const ValueKey('workout-status-cta'),
                  status: workout.status,
                  onPressed: () => onChangeStatus(
                    primaryStatusCtaTransition(workout.status),
                  ),
                );
                final secondaryButton = _secondaryStatusCtaButton(
                  context: context,
                  status: workout.status,
                  onSelectStatus: onChangeStatus,
                  onCopyToNewDate: onCopyToNewDate,
                );
                if (secondaryButton == null) {
                  return primaryButton;
                }
                return Row(
                  children: [
                    Expanded(child: secondaryButton),
                    const SizedBox(width: 12),
                    Expanded(child: primaryButton),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// The one status transition [_StatusCtaButton] always offers as the big
/// primary action (Stage 10 redesign, DESIGN.md section 6: "статус
/// тренировки это отдельные кнопки, а не выпадающее меню") -- every status
/// has an obvious single "next step" (DM 6.4.1), the remaining transitions
/// live in [WorkoutStatusMenu] instead. Always non-null: DM 6.4.1
/// guarantees every status has at least one allowed transition.
WorkoutStatus primaryStatusCtaTransition(WorkoutStatus status) {
  switch (status) {
    case WorkoutStatus.draft:
    case WorkoutStatus.planned:
      return WorkoutStatus.inProgress;
    case WorkoutStatus.inProgress:
      return WorkoutStatus.completed;
    case WorkoutStatus.completed:
      return WorkoutStatus.inProgress;
    case WorkoutStatus.skipped:
    case WorkoutStatus.cancelled:
      return WorkoutStatus.planned;
  }
}

/// A second bottom CTA next to [primaryStatusCtaTransition]'s button, for
/// the one status where DM 6.4.1 offers a genuinely useful second option
/// right away (Stage 10 redesign, owner-reported): a fresh draft can go
/// straight to `inProgress` ("Начать") *or* just get scheduled for later
/// ("Запланировать") -- previously that second option was buried in the
/// "⋮" menu, awkward for something this common right after creating a
/// workout. `null` for every other status, where the primary CTA alone
/// already covers "the one obvious next step".
WorkoutStatus? secondaryStatusCtaTransition(WorkoutStatus status) {
  return status == WorkoutStatus.draft ? WorkoutStatus.planned : null;
}

/// Builds the second bottom CTA button, if [status] has one -- `null` if
/// not, so the caller falls back to the primary button alone.
///
/// Two independent reasons a status might have a second button, handled
/// as separate branches rather than one: [secondaryStatusCtaTransition]
/// (draft -> "Запланировать", still a `WorkoutStatus` transition) and,
/// for `completed`, "Копировать" (Stage 12/redesign_v2, owner-reported:
/// found only through History's own card "⋮" menu before, awkward when
/// you're already looking at the workout you want copied -- see
/// [copyWorkoutFlow]) -- copying isn't a status transition at all, so it
/// can't fit [secondaryStatusCtaTransition]'s `WorkoutStatus?` shape.
Widget? _secondaryStatusCtaButton({
  required BuildContext context,
  required WorkoutStatus status,
  required ValueChanged<WorkoutStatus> onSelectStatus,
  required VoidCallback onCopyToNewDate,
}) {
  final l10n = AppLocalizations.of(context)!;
  // Same vertical padding as _StatusCtaButton's FilledButton so both
  // buttons come out the same height side by side.
  const style = ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 14)),
  );
  if (status == WorkoutStatus.completed) {
    return OutlinedButton(
      key: const ValueKey('workout-status-secondary-cta'),
      style: style,
      onPressed: onCopyToNewDate,
      child: Text(l10n.copyWorkoutAction),
    );
  }
  final secondary = secondaryStatusCtaTransition(status);
  if (secondary == null) return null;
  return OutlinedButton(
    key: const ValueKey('workout-status-secondary-cta'),
    style: style,
    onPressed: () => onSelectStatus(secondary),
    child: Text(workoutTransitionActionLabel(l10n, status, secondary)),
  );
}

/// Big full-width CTA button for [primaryStatusCtaTransition] (DESIGN.md,
/// section 1: "энергичный оранжевый акцент для... CTA" on finishing,
/// primary blue on starting/resuming/scheduling -- matches the mockup's own
/// color split between "Начать тренировку" and "Завершить тренировку").
class _StatusCtaButton extends StatelessWidget {
  const _StatusCtaButton({
    super.key,
    required this.status,
    required this.onPressed,
  });

  final WorkoutStatus status;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final target = primaryStatusCtaTransition(status);
    final isFinishing = target == WorkoutStatus.completed;
    const padding = EdgeInsets.symmetric(vertical: 14);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        // Shape comes from the app-wide FilledButtonThemeData
        // (app/theme.dart) -- no need to repeat it here. Not-finishing
        // (blue) also gets the theme's own pressed-state darkening for
        // free by passing no override at all.
        style: isFinishing
            ? accentFilledButtonStyle(context, padding: padding)
            : FilledButton.styleFrom(padding: padding),
        onPressed: onPressed,
        child: Text(workoutTransitionActionLabel(l10n, status, target)),
      ),
    );
  }
}

/// A single shared one-second ticker for [_WorkoutTimerAction] (the AppBar
/// chip) and the [_RestTimerBar] below it (S-03/S-04, Stage 4), instead of
/// each owning its own `Timer.periodic` — two independent periodic timers
/// previously made `tester.pumpAndSettle()` pathologically slow in widget
/// tests (it never found a quiet moment where neither was about to fire),
/// and it's wasted work in production too. Wraps the whole `Scaffold`
/// (Stage 10 redesign moved the timer into the AppBar, outside the body
/// column the old version wrapped) rather than a specific subtree.
///
/// Owner-reported (Stage 10 redesign): the displayed time only advanced
/// when *something else* triggered a rebuild (tapping anything), not on
/// its own every second, even though the underlying elapsed-seconds value
/// (recomputed from UTC anchors) was always correct once something did
/// force a redraw. Root cause: `widget.child` here is the exact same
/// `Scaffold` widget instance between ticks (nothing about `_EditorBody`'s
/// own inputs changes just because a second passed) -- calling
/// `setState(() {})` only marks *this* State dirty, and rebuilding it just
/// hands back that identical `child` reference; Flutter's element
/// reconciliation treats "same widget instance" as "nothing to update" and
/// skips rebuilding anything underneath, so `_WorkoutTimerAction`/
/// `_RestTimerBar` were never actually called again by the ticker itself.
/// Threading a genuinely new value down via [_WorkoutTickerScope] (an
/// `InheritedWidget`, notifying only the specific descendants that
/// registered as dependents) sidesteps that "identical widget" shortcut
/// entirely -- exactly what `InheritedWidget` exists for.
class _ActiveWorkoutTicker extends StatefulWidget {
  const _ActiveWorkoutTicker({required this.child});

  final Widget child;

  @override
  State<_ActiveWorkoutTicker> createState() => _ActiveWorkoutTickerState();
}

class _ActiveWorkoutTickerState extends State<_ActiveWorkoutTicker> {
  Timer? _ticker;
  int _tick = 0;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _tick++);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _WorkoutTickerScope(tick: _tick, child: widget.child);
}

/// Notifies [_WorkoutTimerAction]/[_RestTimerBar] on every
/// [_ActiveWorkoutTicker] tick, regardless of whether anything else in the
/// tree changed -- see that class's doc comment for why a plain
/// `setState(() {})` up there isn't enough on its own. [tick] itself is
/// never read; depending on this widget at all is the point.
class _WorkoutTickerScope extends InheritedWidget {
  const _WorkoutTickerScope({required this.tick, required super.child});

  final int tick;

  static void listen(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<_WorkoutTickerScope>();
  }

  @override
  bool updateShouldNotify(_WorkoutTickerScope oldWidget) =>
      tick != oldWidget.tick;
}

/// Compact AppBar timer chip (S-03, Stage 4, TS 7.1; Stage 10 redesign,
/// owner-reported: the old full-width row -- big digits plus a separate
/// pause icon button -- ate an entire row on its own, leaving too little
/// room for the sets list; the mockup keeps it inline next to the
/// workout's name instead). Tapping the whole chip pauses/resumes, the
/// same action the old dedicated icon offered; the icon swaps between a
/// running/paused glyph so the state stays visible without reading the
/// tooltip (`ASSUMPTION(timer-chip-icon)`: the mockup's static frame only
/// shows a plain clock glyph, since it never captures a paused moment --
/// keeping a state-reflecting icon here preserves the pause affordance the
/// dedicated button used to make obvious). Shown only while `inProgress`
/// (`ActiveWorkoutState` exists only then, DM 6.14); the elapsed value is
/// always recomputed from UTC anchors, never accumulated in memory, so a
/// missed tick (backgrounded app) never desyncs the displayed time.
class _WorkoutTimerAction extends ConsumerWidget {
  const _WorkoutTimerAction({
    required this.workoutId,
    required this.controller,
  });

  final String workoutId;
  final WorkoutEditorController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Registers this widget as a dependent of `_ActiveWorkoutTicker`'s
    // scope (see its doc comment) so it's rebuilt every second on its own,
    // not only when something else happens to touch this subtree.
    _WorkoutTickerScope.listen(context);
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(activeWorkoutStateProvider(workoutId));

    return stateAsync.maybeWhen(
      data: (state) {
        if (state == null) return const SizedBox.shrink();
        final timerService = ref.read(activeWorkoutTimerServiceProvider);
        final elapsed = timerService.elapsedSeconds(state);

        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: Tooltip(
            message: state.isPaused
                ? l10n.workoutTimerResumeAction
                : l10n.workoutTimerPauseAction,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.control),
              onTap: state.isPaused
                  ? controller.resumeTimer
                  : controller.pauseTimer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isPaused
                          ? Icons.play_circle_outline
                          : Icons.pause_circle_outline,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      formatElapsedTime(elapsed),
                      style: AppNumberTextStyles.compactTimer(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

/// Rest timer bar (S-04, Stage 4, TS 7.2 step 2): shown only while a rest
/// timer is running (`ActiveWorkoutState.restTimerEndsAtUtc != null` *and*
/// within one extra second of it), started automatically when a set is
/// marked done (if `AppSettings.restTimerAutoStart` — see
/// `_WorkoutEditorScreenState._onSetCompletedChanged`). "±10 с"
/// adjusts the running countdown and reschedules its notification
/// (TS 7.2 step 3: "отмена/перезапуск таймера — отмена/перепланирование
/// уведомления"); "Пропустить" cancels both the timer and the
/// notification. Once the remaining time reaches zero the card keeps
/// showing "00:00" (fully filled) for one more second before disappearing
/// on its own (Stage 12, owner-reported: the notification/etc. still fire
/// right at the true deadline, unchanged -- but hiding the card at that
/// same instant cut off both the "00" label and the fill's own glide to
/// 100% before either could ever actually be seen). Purely a display
/// decision, made fresh each tick from the still-unchanged
/// `ActiveWorkoutState` row, not a database write: the row itself is only
/// ever cleared by an explicit skip or by the next set starting a fresh
/// timer (`startRestTimer` always overwrites it outright), so there is
/// nothing to reconcile here.
class _RestTimerBar extends ConsumerWidget {
  const _RestTimerBar({required this.workoutId, required this.controller});

  final String workoutId;
  final WorkoutEditorController controller;

  Future<void> _adjust(
    BuildContext context,
    WidgetRef ref,
    int deltaSec,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await controller.adjustRestTimer(deltaSec);
    // A direct repository read, not the cached `activeWorkoutStateProvider`
    // stream value -- right after the write above, that stream may not
    // have propagated the new row yet.
    final endsAt =
        (await ref
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
    // Same reasoning as `_WorkoutTimerAction`'s -- see
    // `_ActiveWorkoutTicker`'s doc comment.
    _WorkoutTickerScope.listen(context);
    final l10n = AppLocalizations.of(context)!;
    final stateAsync = ref.watch(activeWorkoutStateProvider(workoutId));

    return stateAsync.maybeWhen(
      data: (state) {
        if (state == null || state.restTimerEndsAtUtc == null) {
          return const SizedBox.shrink();
        }
        final timerService = ref.read(activeWorkoutTimerServiceProvider);
        // Millisecond precision throughout -- see this class's doc comment
        // for why the card now lingers on "00:00" for a second past the
        // true deadline instead of vanishing right at it.
        final remainingMs = timerService.remainingRestMilliseconds(state) ?? 0;
        if (remainingMs <= -1000) {
          return const SizedBox.shrink();
        }
        // The label never shows a negative countdown -- once truly expired
        // it's pinned at "00:00" (via `formatElapsedTime`'s own <0 clamp)
        // for that extra lingering second, same as `RestTimerCard`'s fill
        // clamps to fully filled (see its own `elapsedMs` clamp).
        final remaining = remainingMs > 0 ? (remainingMs / 1000).ceil() : 0;
        // `restTimerDurationSec` is the original planned duration, fixed
        // once at start (Stage 10 redesign, owner-reported: `adjustRestTimer`
        // no longer changes it) -- exactly the denominator RestTimerCard's
        // progress fill needs to keep a constant fill speed across ±10с
        // adjustments.
        final totalSeconds = state.restTimerDurationSec ?? remaining;
        final notificationsEnabled = ref
            .watch(notificationsEnabledProvider)
            .maybeWhen(data: (enabled) => enabled, orElse: () => true);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RestTimerCard(
                remainingSeconds: remaining,
                remainingMilliseconds: remainingMs,
                totalMilliseconds: totalSeconds * 1000,
                onAdjust: (delta) => _adjust(context, ref, delta),
                onSkip: () => _skip(ref),
              ),
              // TS 7.3: "ненавязчивая пометка «Уведомления выключены»" --
              // no settings deep-link (would need a new package beyond the
              // ones approved for this step), just an informational note.
              if (!notificationsEnabled)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
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

/// "+ Добавить тег" trigger (S-03), now folded into the date/status row
/// instead of its own full-width row (Stage 10 redesign, owner-reported:
/// that row was always present -- taking up space -- even with zero tags
/// assigned, which both the pre- and post-redesign screenshots showed as
/// the common case). Reads `AppSettings.showTags` itself (S-17:
/// "выключение скрывает... фильтр тегов") so callers don't need to know
/// about the setting. Icon-only (`Icons.label_outline`, the conventional
/// "tag" glyph) rather than a labelled chip -- shorter, and reads clearly
/// next to the status menu it now sits beside.
class _TagAddButton extends ConsumerWidget {
  const _TagAddButton({required this.workoutId});

  final String workoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;
    if (!showTags) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return IconButton(
      icon: const Icon(Icons.label_outline),
      tooltip: l10n.workoutTagsAddAction,
      visualDensity: VisualDensity.compact,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => TagPickerSheet(workoutId: workoutId),
      ),
    );
  }
}

/// Read-only chips for each assigned tag (S-03) -- wraps to a new line if
/// there are several. Renders nothing when there are no tags (the common
/// case the "+" trigger above now handles on its own, Stage 10 redesign)
/// or `AppSettings.showTags` is off (S-17) -- this only affects
/// visibility, the workout's tag links are untouched.
class _AssignedTagsWrap extends ConsumerWidget {
  const _AssignedTagsWrap({required this.tags});

  final List<WorkoutTag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;
    if (!showTags || tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [for (final tag in tags) WorkoutTagChip(tag: tag)],
      ),
    );
  }
}
