import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import 'controller.dart';
import 'status_labels.dart';
import 'widgets/exercise_card.dart';

/// S-03 workout editor, Stage 1 minimum (02_DEVELOPMENT_PLAN.md): add
/// exercises, add sets, edit plan/fact with autosave, "✓" (DM 6.7), and
/// draft -> inProgress -> completed via "Начать"/"Завершить". Tags, the
/// full status menu, progression, reorder, comments and "прошлые
/// результаты" are out of scope until later stages.
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

  Future<void> _changeStatus(WorkoutStatus newStatus) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = ref.read(
      workoutEditorControllerProvider(widget.workoutId).notifier,
    );
    final result = newStatus == WorkoutStatus.inProgress
        ? await controller.start()
        : await controller.finish();
    if (!mounted) return;
    result.fold((_) {}, (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.workoutStatusChangeError)));
    });
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
  });

  final WorkoutDetails details;
  final WorkoutEditorController controller;
  final VoidCallback onAddExercise;
  final void Function(WorkoutStatus newStatus) onChangeStatus;

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
              Text(formatShortDate(workout.date)),
              const SizedBox(width: 12),
              Chip(label: Text(workoutStatusLabel(l10n, workout.status))),
              const Spacer(),
              if (workout.status == WorkoutStatus.draft)
                FilledButton(
                  onPressed: () => onChangeStatus(WorkoutStatus.inProgress),
                  child: Text(l10n.startWorkoutAction),
                )
              else if (workout.status == WorkoutStatus.inProgress)
                FilledButton(
                  onPressed: () => onChangeStatus(WorkoutStatus.completed),
                  child: Text(l10n.finishWorkoutAction),
                ),
            ],
          ),
        ),
        Expanded(
          child: details.exercises.isEmpty
              ? Center(child: Text(l10n.workoutExercisesEmpty))
              : ListView(
                  children: [
                    for (final exerciseDetails in details.exercises)
                      ExerciseCard(
                        details: exerciseDetails,
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
                        onCompletedChanged: (setId, value) {
                          controller.setCompleted(setId, value: value);
                        },
                        onAddSet: () => controller.addSet(
                          exerciseDetails.workoutExercise.id,
                        ),
                      ),
                  ],
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
