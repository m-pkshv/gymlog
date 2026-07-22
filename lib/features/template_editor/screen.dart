import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/widgets/error_retry_state.dart';
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
  });

  final TemplateDetails details;
  final TemplateEditorController controller;
  final VoidCallback onAddExercise;

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
              : ReorderableListView.builder(
                  // TemplateExerciseCard supplies its own drag handle, so
                  // the default trailing handle would be redundant (same
                  // reasoning as ExerciseCard/S-03).
                  buildDefaultDragHandles: false,
                  itemCount: details.exercises.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = details.exercises
                        .map((e) => e.templateExercise.id)
                        .toList();
                    final movedId = ids.removeAt(oldIndex);
                    ids.insert(newIndex, movedId);
                    controller.reorderExercises(ids);
                  },
                  itemBuilder: (context, index) {
                    final exerciseDetails = details.exercises[index];
                    final templateExerciseId =
                        exerciseDetails.templateExercise.id;
                    return TemplateExerciseCard(
                      key: ValueKey(templateExerciseId),
                      details: exerciseDetails,
                      index: index,
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
                      onWarmupChanged: (setId, value) {
                        controller.setWarmup(setId, value: value);
                      },
                      onAddSet: () => controller.addSet(templateExerciseId),
                      onMoveUp: () =>
                          controller.moveExercise(templateExerciseId, up: true),
                      onMoveDown: () => controller.moveExercise(
                        templateExerciseId,
                        up: false,
                      ),
                      onCommentChanged: (value) =>
                          controller.editExerciseComment(
                            templateExerciseId,
                            value,
                          ),
                      onCommentCommit: () =>
                          controller.flushExerciseComment(templateExerciseId),
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
