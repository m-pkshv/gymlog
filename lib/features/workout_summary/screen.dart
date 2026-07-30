import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/duration_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/hero_stat_tile.dart';
import '../../domain/enums.dart';
import '../../domain/models/personal_record.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import '../stats/record_type_labels.dart';
import '../stats/record_value_format.dart';
import '../workout_editor/controller.dart';
import '../workout_editor/export_workout_pdf_flow.dart';
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
      appBar: AppBar(
        title: Text(l10n.workoutSummaryTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportWorkoutPdfAction,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              final details = ref
                  .read(workoutEditorControllerProvider(widget.workoutId))
                  .value;
              if (details == null) return;
              exportWorkoutPdfFlow(context, ref, details);
            },
          ),
        ],
      ),
      body: detailsAsync.when(
        data: (details) => _SummaryBody(
          details: details,
          controller: controller,
          // Owner-reported: this used to hardcode `context.go('/history')`,
          // which always landed on History regardless of which tab the
          // workout was actually opened from (Today, a template, etc.).
          // The editor `pushReplacement`s this screen in its own spot in
          // the stack (see the editor's `_changeStatus`), so popping reveals
          // exactly what was there before -- same invariant as
          // `app/router.dart`'s top comment for the editor route itself.
          onDone: () => context.pop(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => ErrorRetryState(
          message: l10n.workoutLoadError,
          onRetry: () =>
              ref.invalidate(workoutEditorControllerProvider(widget.workoutId)),
        ),
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
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final stats = computeWorkoutSummaryStats(details);

    // Owner-reported: the "Готово" button (the list's last item) used to
    // render right up against the physical bottom edge, ending up partly
    // hidden behind the OS's on-screen navigation bar (back/home/recents)
    // -- there's no AppBar-equivalent handling the bottom edge the way the
    // Scaffold's AppBar already does the top, so this screen needs its own
    // `SafeArea`, same as the editor's bottom CTA
    // (`workout_editor/screen.dart`).
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Duration is this screen's hero number (Stage 10 redesign,
          // AUDIT.md section 1.7: "probably the most emotionally significant
          // number right after finishing", but pre-redesign it carried the
          // same visual weight as exercises/sets/tonnage). Given its own
          // accent-tinted card, full width, above a plain row of the other
          // three. ASSUMPTION(summary-hero-layout): no mockup reference was
          // available for this screen specifically; this exact split (hero
          // duration + a row of secondary tiles, replacing the audited 2x2
          // grid) is a cosmetic call following AUDIT's explicit critique, not
          // a literal copy of a reference design.
          DecoratedBox(
            decoration: BoxDecoration(
              color: semantic.accentContainer,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: HeroStatTile(
                icon: Icons.timer_outlined,
                iconColor: semantic.onAccentContainer,
                value: formatElapsedTime(
                  details.workout.actualDurationSec ?? 0,
                ),
                label: l10n.workoutSummaryDurationLabel,
                valueColor: semantic.onAccentContainer,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: HeroStatTile(
                  icon: Icons.fitness_center,
                  value: stats.exerciseCount.toString(),
                  label: l10n.workoutSummaryExercisesLabel,
                ),
              ),
              Expanded(
                child: HeroStatTile(
                  icon: Icons.checklist,
                  value: stats.setCount.toString(),
                  label: l10n.workoutSummarySetsLabel,
                ),
              ),
              Expanded(
                child: HeroStatTile(
                  icon: Icons.scale_outlined,
                  value: l10n.workoutSummaryTonnageValue(
                    stats.tonnageKg.toStringAsFixed(1),
                  ),
                  label: l10n.workoutSummaryTonnageLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
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
///
/// Stage 10 redesign, AUDIT.md section 1.7: two named problems fixed here.
/// (1) "the one moment meant to reward the user looked as neutral as a
/// settings screen" -- given an accent-tinted card (the same family
/// `RestTimerCard` uses for its own energetic-CTA role) instead of a plain
/// `Card`. (2) "the exercise name repeats once per record instead of
/// grouping" -- records are now grouped by exercise, one name heading
/// followed by all of that exercise's new records, rather than one
/// `ListTile` per record with a repeated title. ASSUMPTION(new-records-
/// styling): no mockup reference was available for this screen; both fixes
/// are cosmetic calls that apply the audit's own critique with the already-
/// established accent token, not a literal copy of a reference design.
class _NewRecordsSection extends ConsumerWidget {
  const _NewRecordsSection({required this.workoutId, required this.exercises});

  final String workoutId;
  final List<WorkoutExerciseDetails> exercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final groups = <(String exerciseName, List<PersonalRecord> records)>[];
    for (final exerciseDetails in exercises) {
      final records =
          ref
              .watch(
                personalRecordsForExerciseProvider(exerciseDetails.exercise.id),
              )
              .value ??
          const <PersonalRecord>[];
      final newRecords = records
          .where((record) => record.workoutId == workoutId)
          .toList();
      if (newRecords.isNotEmpty) {
        groups.add((exerciseDetails.exercise.name, newRecords));
      }
    }
    if (groups.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: semantic.accentContainer,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: semantic.onAccentContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.workoutSummaryNewRecordsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: semantic.onAccentContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              for (final group in groups)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: _NewRecordExerciseGroup(
                    l10n: l10n,
                    exerciseName: group.$1,
                    records: group.$2,
                    onContainerColor: semantic.onAccentContainer,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewRecordExerciseGroup extends StatelessWidget {
  const _NewRecordExerciseGroup({
    required this.l10n,
    required this.exerciseName,
    required this.records,
    required this.onContainerColor,
  });

  final AppLocalizations l10n;
  final String exerciseName;
  final List<PersonalRecord> records;
  final Color onContainerColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exerciseName,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: onContainerColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        for (final record in records)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: _NewRecordDetail(
              l10n: l10n,
              record: record,
              onContainerColor: onContainerColor,
            ),
          ),
      ],
    );
  }
}

class _NewRecordDetail extends StatelessWidget {
  const _NewRecordDetail({
    required this.l10n,
    required this.record,
    required this.onContainerColor,
  });

  final AppLocalizations l10n;
  final PersonalRecord record;
  final Color onContainerColor;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      recordTypeLabel(l10n, record.recordType),
      if (record.recordType == RecordType.maxRepsAtWeight)
        l10n.statsKgValue(record.keyValue!.toStringAsFixed(1)),
    ];
    return Row(
      children: [
        Expanded(
          child: Text(
            subtitleParts.join(' · '),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: onContainerColor),
          ),
        ),
        Text(
          formatRecordValue(l10n, record.recordType, record.value),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: onContainerColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (isEstimatedRecord(record.recordType))
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xs),
            child: Text(
              l10n.statsEstimatedBadge,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: onContainerColor.withValues(alpha: 0.75),
              ),
            ),
          ),
      ],
    );
  }
}
