import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/duration_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/personal_record.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import '../stats/record_type_labels.dart';
import '../stats/record_value_format.dart';
import '../workout_editor/controller.dart';
import '../workout_editor/widgets/comment_field.dart';
import '../workout_editor/widgets/progression_segmented_button.dart';
import 'workout_summary_stats.dart';

/// S-05 workout summary: shown once, right after "Завершить" moves a
/// workout to `completed` (TS 7.2 step 6: "... → итоговый экран"). Reuses
/// [WorkoutEditorController] (same `workoutId`, a fresh `.autoDispose`
/// instance) for the comment field and progression decisions -- they're the
/// same underlying fields the editor already exposes, not a separate copy.
/// "Новые рекорды (если есть)" (Stage 7): a `PersonalRecord` counts as "new"
/// here when its cached `workoutId` equals this workout's id -- since
/// `RecordsService` only overwrites a record's `workoutId` when a value is
/// *strictly* beaten (never on a tie), this is exactly "the record this
/// workout just set", no separate before/after diffing needed.
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
        _NewRecordsSection(
          workoutId: details.workout.id,
          exercises: details.exercises,
        ),
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

/// "Новые рекорды (если есть)" (04_UI_UX_SPEC.md S-05, Stage 7): renders
/// nothing at all when no exercise in this workout set a record just now --
/// the section itself, including its own trailing spacing, is conditional,
/// not just its content (the caller places this right after the stat tiles
/// unconditionally).
class _NewRecordsSection extends ConsumerWidget {
  const _NewRecordsSection({required this.workoutId, required this.exercises});

  final String workoutId;
  final List<WorkoutExerciseDetails> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final rows = <Widget>[];
    for (final exerciseDetails in exercises) {
      final records =
          ref.watch(personalRecordsForExerciseProvider(exerciseDetails.exercise.id)).value ??
          const <PersonalRecord>[];
      for (final record in records) {
        if (record.workoutId != workoutId) continue;
        rows.add(
          _NewRecordRow(
            l10n: l10n,
            exerciseName: exerciseDetails.exercise.name,
            record: record,
          ),
        );
      }
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.workoutSummaryNewRecordsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: rows)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _NewRecordRow extends StatelessWidget {
  const _NewRecordRow({
    required this.l10n,
    required this.exerciseName,
    required this.record,
  });

  final AppLocalizations l10n;
  final String exerciseName;
  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      recordTypeLabel(l10n, record.recordType),
      if (record.recordType == RecordType.maxRepsAtWeight)
        l10n.statsKgValue(record.keyValue!.toStringAsFixed(1)),
    ];
    return ListTile(
      leading: const Icon(Icons.emoji_events_outlined),
      title: Text(exerciseName),
      subtitle: Text(subtitleParts.join(' · ')),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatRecordValue(l10n, record.recordType, record.value),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (isEstimatedRecord(record.recordType))
            Text(
              l10n.statsEstimatedBadge,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
