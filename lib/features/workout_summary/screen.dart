import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/duration_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/controller.dart';
import '../workout_editor/widgets/comment_field.dart';
import '../workout_editor/widgets/progression_segmented_button.dart';
import 'workout_summary_stats.dart';

/// S-05 workout summary: shown once, right after "Завершить" moves a
/// workout to `completed` (TS 7.2 step 6: "... → итоговый экран"). Reuses
/// [WorkoutEditorController] (same `workoutId`, a fresh `.autoDispose`
/// instance) for the comment field and progression decisions -- they're the
/// same underlying fields the editor already exposes, not a separate copy.
/// "Новые рекорды" is intentionally absent: the `PersonalRecord` cache
/// (D-8) and its "is this a record" logic don't exist until Stage 7
/// (owner-confirmed 2026-07-21, same reasoning as the S-07 "Рекорды" tab
/// omitted at Stage 2).
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.workoutId});

  final String workoutId;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Same autosave guarantee as the editor (03_TECHNICAL_SPEC.md,
      // section 5): force-write the comment field's pending debounce
      // before the OS may kill the process.
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
      appBar: AppBar(title: Text(l10n.workoutSummaryTitle)),
      body: detailsAsync.when(
        data: (details) => _SummaryBody(
          details: details,
          controller: controller,
          onDone: () => context.go('/history'),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.workoutLoadError)),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({
    required this.details,
    required this.controller,
    required this.onDone,
  });

  final WorkoutDetails details;
  final WorkoutEditorController controller;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = computeWorkoutSummaryStats(details);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _StatTile(
              icon: Icons.timer_outlined,
              value: formatElapsedTime(details.workout.actualDurationSec ?? 0),
              label: l10n.workoutSummaryDurationLabel,
            ),
            _StatTile(
              icon: Icons.fitness_center,
              value: stats.exerciseCount.toString(),
              label: l10n.workoutSummaryExercisesLabel,
            ),
            _StatTile(
              icon: Icons.checklist,
              value: stats.setCount.toString(),
              label: l10n.workoutSummarySetsLabel,
            ),
            _StatTile(
              icon: Icons.scale_outlined,
              value: l10n.workoutSummaryTonnageValue(
                stats.tonnageKg.toStringAsFixed(1),
              ),
              label: l10n.workoutSummaryTonnageLabel,
            ),
          ],
        ),
        const SizedBox(height: 24),
        CommentField(
          key: ValueKey('workout-comment-${details.workout.id}'),
          value: details.workout.comment,
          label: l10n.workoutCommentLabel,
          maxLength: CommentLengthLimits.workout,
          onChanged: controller.editWorkoutComment,
          onCommit: controller.flushWorkoutComment,
        ),
        if (details.exercises.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.progressionDecisionLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final exerciseDetails in details.exercises)
            _ExerciseProgressionRow(
              details: exerciseDetails,
              onChanged: (decision) => controller.setProgressionDecision(
                exerciseDetails.workoutExercise.id,
                decision,
              ),
            ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onDone,
          child: Text(l10n.workoutSummaryDoneAction),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ExerciseProgressionRow extends ConsumerWidget {
  const _ExerciseProgressionRow({
    required this.details,
    required this.onChanged,
  });

  final WorkoutExerciseDetails details;
  final ValueChanged<ProgressionDecision> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final stagnationCount = ref
        .watch(progressionStateProvider(details.exercise.id))
        .value
        ?.stagnationCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details.exercise.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          ProgressionSegmentedButton(
            selected: details.workoutExercise.progressionDecision,
            onChanged: onChanged,
          ),
          if (stagnationCount != null && stagnationCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.stagnationHint(stagnationCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
