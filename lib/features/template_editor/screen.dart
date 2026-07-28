import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/undo_snackbar.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/template_details.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/widgets/comment_field.dart';
import 'controller.dart';
import 'widgets/template_exercise_card.dart';

/// S-13 template editor: "как S-03, но без статусов/дат/фактов; только
/// структура и плановые значения" (04_UI_UX_SPEC.md). Name + comment
/// (autosave, same TS 5 contract as the workout editor), exercises with
/// reorder + planned-only sets, "+ Упражнение" (reuses `AddExerciseScreen`,
/// same picker/creation flow as S-03).
class TemplateEditorScreen extends ConsumerStatefulWidget {
  const TemplateEditorScreen({super.key, required this.templateId});

  final String templateId;

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(
        ref
            .read(templateEditorControllerProvider(widget.templateId).notifier)
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
      '/more/templates/${widget.templateId}/add-exercise',
    );
    if (exercise == null) return;
    await ref
        .read(templateEditorControllerProvider(widget.templateId).notifier)
        .addExercise(exercise.id);
  }

  /// "Удалить" a set (S-13 set menu, Stage 10, owner-reported): mirrors
  /// `WorkoutEditorScreen._deleteSet` — soft-delete + 5s Undo snackbar,
  /// no confirmation dialog (DM 10, same pattern as workout/measurement
  /// deletion).
  Future<void> _deleteSet(String setId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(
      templateEditorControllerProvider(widget.templateId).notifier,
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

  /// "Удалить упражнение" (S-13 exercise card menu, Stage 10, owner-
  /// reported) — mirrors `WorkoutEditorScreen._deleteExercise`.
  Future<void> _deleteExercise(String templateExerciseId) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(
      templateEditorControllerProvider(widget.templateId).notifier,
    );
    final deleted = await controller.deleteExercise(templateExerciseId);
    if (!mounted || !deleted) return;
    showUndoSnackbar(
      context,
      message: l10n.exerciseDeletedMessage,
      actionLabel: l10n.undoAction,
      onUndo: () => controller.restoreExercise(templateExerciseId),
    );
  }

  /// "Редактировать упражнение" (S-13 exercise card menu, Stage 10, owner-
  /// reported) — mirrors `WorkoutEditorScreen._editExercise`.
  Future<void> _editExercise(Exercise exercise) async {
    final canonical = await ref
        .read(exerciseRepositoryProvider)
        .getById(exercise.id);
    if (canonical == null || !mounted) return;
    final updated = await context.push<Exercise>(
      '/more/templates/${widget.templateId}/edit-exercise/${exercise.id}',
      extra: canonical,
    );
    if (updated != null && mounted) {
      ref
          .read(templateEditorControllerProvider(widget.templateId).notifier)
          .reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(
      templateEditorControllerProvider(widget.templateId),
    );
    final controller = ref.read(
      templateEditorControllerProvider(widget.templateId).notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templateEditorTitle)),
      body: detailsAsync.when(
        data: (details) => _EditorBody(
          details: details,
          controller: controller,
          onAddExercise: _addExercise,
          onSetDeleted: _deleteSet,
          onEditExercise: _editExercise,
          onDeleteExercise: _deleteExercise,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.templateLoadError,
          onRetry: () => ref.invalidate(
            templateEditorControllerProvider(widget.templateId),
          ),
        ),
      ),
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.details,
    required this.controller,
    required this.onAddExercise,
    required this.onSetDeleted,
    required this.onEditExercise,
    required this.onDeleteExercise,
  });

  final TemplateDetails details;
  final TemplateEditorController controller;
  final VoidCallback onAddExercise;
  final ValueChanged<String> onSetDeleted;
  final ValueChanged<Exercise> onEditExercise;
  final ValueChanged<String> onDeleteExercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final template = details.template;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: CommentField(
            key: ValueKey('template-name-${template.id}'),
            value: template.name,
            label: l10n.templateNameLabel,
            maxLength: WorkoutTemplateRules.maxNameLength,
            maxLines: 1,
            minLines: 1,
            onChanged: controller.editName,
            onCommit: controller.flushName,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: CommentField(
            key: ValueKey('template-comment-${template.id}'),
            value: template.comment,
            label: l10n.templateCommentLabel,
            maxLength: CommentLengthLimits.workoutTemplate,
            onChanged: controller.editComment,
            onCommit: controller.flushComment,
          ),
        ),
        Expanded(
          child: details.exercises.isEmpty
              ? Center(child: Text(l10n.templateExercisesEmpty))
              : ListView.builder(
                  // Owner-reported (Stage 10): the drag handle this used to
                  // have (mirroring ExerciseCard/S-03) felt sluggish, so it
                  // was removed in favour of the "⋮ → Вверх/Вниз" menu on
                  // each card as the only way to reorder now.
                  itemCount: details.exercises.length,
                  itemBuilder: (context, index) {
                    final exerciseDetails = details.exercises[index];
                    final templateExerciseId =
                        exerciseDetails.templateExercise.id;
                    return TemplateExerciseCard(
                      key: ValueKey(templateExerciseId),
                      details: exerciseDetails,
                      canMoveUp: index > 0,
                      canMoveDown: index < details.exercises.length - 1,
                      onFieldChanged: (setId, field, value) {
                        controller.editSet(
                          setId,
                          (set) => field.setPlanned(set, value),
                        );
                      },
                      onFieldCommit: (setId, field) {
                        controller.flushSet(setId);
                      },
                      onAddSet: () => controller.addSet(templateExerciseId),
                      onDuplicateLastSet: () =>
                          controller.duplicateLastSet(templateExerciseId),
                      onMoveUp: () =>
                          controller.moveExercise(templateExerciseId, up: true),
                      onMoveDown: () => controller.moveExercise(
                        templateExerciseId,
                        up: false,
                      ),
                      onSetDeleted: onSetDeleted,
                      onEditExercise: () =>
                          onEditExercise(exerciseDetails.exercise),
                      onDeleteExercise: () =>
                          onDeleteExercise(templateExerciseId),
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
