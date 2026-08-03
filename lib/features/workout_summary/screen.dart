import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/duration_format.dart';
import '../../core/widgets/confetti_overlay.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/grouped_section.dart';
import '../../core/widgets/hero_stat_tile.dart';
import '../../core/widgets/shine_sweep.dart';
import '../../domain/enums.dart';
import '../../domain/models/personal_record.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import '../stats/record_type_labels.dart';
import '../stats/record_value_format.dart';
import '../workout_editor/controller.dart';
import '../workout_editor/export_workout_pdf_flow.dart';
import '../workout_editor/widgets/comment_field.dart';
import 'workout_summary_stats.dart';

/// S-05 workout summary: shown once, right after "Завершить" moves a
/// workout to `completed` (TS 7.2 step 6: "... → итоговый экран"). Reuses
/// [WorkoutEditorController] (same `workoutId`, a fresh `.autoDispose`
/// instance) for the comment field -- the same underlying field the editor
/// already exposes, not a separate copy. Each exercise's progression
/// decision (Stage: design/redesign_v2, owner-confirmed) is read-only here
/// -- a small badge next to its row, shown only when one was actually set --
/// editing it stays in the workout editor's exercise cards, matching the
/// owner-supplied mockup, which shows no controls for it on this screen.
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
        // Owner-requested: a short confetti burst on arrival -- layered
        // over the body in a `Stack` rather than inside it, so it isn't
        // just another scrollable item and doesn't shift on scroll. Keyed
        // by workoutId, not `const`, so Riverpod rebuilding this branch for
        // a *different* workout (shouldn't normally happen -- this screen
        // is a one-shot destination per finish -- but keeps the guarantee
        // explicit) replays the burst instead of reusing stale particles.
        data: (details) => Stack(
          children: [
            _SummaryBody(
              details: details,
              controller: controller,
              // Owner-reported: this used to hardcode
              // `context.go('/history')`, which always landed on History
              // regardless of which tab the workout was actually opened
              // from (Today, a template, etc.). The editor
              // `pushReplacement`s this screen in its own spot in the
              // stack (see the editor's `_changeStatus`), so popping
              // reveals exactly what was there before -- same invariant
              // as `app/router.dart`'s top comment for the editor route
              // itself.
              onDone: () => context.pop(),
            ),
            Positioned.fill(
              child: ConfettiOverlay(key: ValueKey(widget.workoutId)),
            ),
          ],
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
          // Stage: design/redesign_v2, owner-supplied mockup ("Тренировка
          // завершена" hero card + name, replacing the previous accent-
          // tinted duration hero -- duration moved into the plain stat row
          // below, alongside exercise/set counts).
          _CompletedHeroCard(
            workoutName: details.workout.name ?? l10n.workoutDefaultNamePrefix,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SummaryStatCard(
                  value: formatElapsedTime(
                    details.workout.actualDurationSec ?? 0,
                  ),
                  label: l10n.workoutSummaryDurationLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryStatCard(
                  value: stats.exerciseCount.toString(),
                  label: l10n.workoutSummaryExercisesLabel,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryStatCard(
                  value: stats.setCount.toString(),
                  label: l10n.workoutSummarySetsLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _NewRecordsSection(
            workoutId: details.workout.id,
            exercises: details.exercises,
          ),
          if (details.exercises.isNotEmpty) ...[
            GroupedSection(
              title: l10n.workoutSummaryExercisesLabel,
              children: [
                for (var i = 0; i < details.exercises.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  _ExerciseSummaryRow(details: details.exercises[i]),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          CommentField(
            key: ValueKey('workout-comment-${details.workout.id}'),
            value: details.workout.comment,
            label: l10n.workoutSummaryCommentLabel,
            hint: l10n.workoutSummaryCommentHint,
            maxLength: CommentLengthLimits.workout,
            onChanged: controller.editWorkoutComment,
            onCommit: controller.flushWorkoutComment,
          ),
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

/// The hero card at the top of S-05 (Stage: design/redesign_v2, owner-
/// supplied mockup): a filled checkmark badge, "Тренировка завершена", and
/// the workout's own name (or the shared default title) underneath as a
/// subtitle. Reuses [ColorScheme.primaryContainer]/[primary] rather than a
/// new token -- the mockup's pale-blue (light)/deep-navy (dark) card with a
/// solid-blue badge is exactly that role pairing already.
class _CompletedHeroCard extends StatelessWidget {
  const _CompletedHeroCard({required this.workoutName});

  final String workoutName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primary,
              child: Icon(Icons.check, color: scheme.onPrimary, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.workoutSummaryCompletedTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              workoutName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three plain figure tiles under the hero card (duration,
/// exercise count, set count -- Stage: design/redesign_v2, owner-supplied
/// mockup). No icon, unlike [HeroStatTile]'s other uses -- the mockup's
/// tiles are just a big number and a caption, each in its own outlined
/// card matching [GroupedSection]'s own card recipe below, so the two
/// card styles on this screen read as the same visual language.
class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        // Owner-reported: the original padding read too tight against the
        // card's border.
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: HeroStatTile(value: value, label: label),
      ),
    );
  }
}

/// One exercise row inside the "Упражнения" card (Stage: design/
/// redesign_v2, owner-supplied mockup): a status badge (all planned sets
/// done vs. not), the exercise name, how many sets were completed out of
/// how many were planned, and -- only if the owner actually set one
/// (DM 6.11 "ручная отметка", `ProgressionDecision.none` otherwise) -- a
/// small badge on the trailing edge showing that decision. Read-only (see
/// the class-level doc comment on [WorkoutSummaryScreen]).
class _ExerciseSummaryRow extends StatelessWidget {
  const _ExerciseSummaryRow({required this.details});

  final WorkoutExerciseDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final total = details.sets.length;
    final completed = details.sets.where((set) => set.isCompleted).length;
    final decision = details.workoutExercise.progressionDecision;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _ExerciseStatusBadge(isFullyCompleted: completed >= total),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: details.exercise.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' ${l10n.workoutSummaryExerciseSetsRatio(completed, total)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (decision != ProgressionDecision.none) ...[
            const SizedBox(width: AppSpacing.sm),
            _ProgressionBadge(decision: decision),
          ],
        ],
      ),
    );
  }
}

/// Left-hand circular status marker on an [_ExerciseSummaryRow]: a solid
/// green check when every planned set was completed, a solid orange "!"
/// otherwise -- the same success/accent color pairing [CompletionToggle]
/// and the "not fully completed" workout status already use, not new
/// tokens.
class _ExerciseStatusBadge extends StatelessWidget {
  const _ExerciseStatusBadge({required this.isFullyCompleted});

  final bool isFullyCompleted;

  static const double _diameter = 28;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFullyCompleted ? semantic.success : semantic.accent,
      ),
      child: Icon(
        isFullyCompleted ? Icons.check : Icons.priority_high,
        size: 16,
        color: isFullyCompleted ? semantic.onSuccess : semantic.onAccent,
      ),
    );
  }
}

/// Right-hand circular badge on an [_ExerciseSummaryRow] showing a
/// non-`none` [ProgressionDecision] as the same glyph used by
/// `ProgressionSegmentedButton` ("↑"/"="/"↓") -- a softer container-tier
/// tint rather than the status badge's solid fill, so the two don't compete
/// for attention on the same row. "Increase" reads as
/// [AppSemanticColors.success] (owner-confirmed: was the error/red family),
/// "decrease" as [AppSemanticColors.accent] (owner-reported: was the
/// success/green family, replaced with the same orange the "not fully
/// completed" status badge already uses), and "repeat" is neutral gray,
/// unchanged.
class _ProgressionBadge extends StatelessWidget {
  const _ProgressionBadge({required this.decision});

  final ProgressionDecision decision;

  static const double _diameter = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;

    final (Color background, Color foreground, String glyph) = switch (decision) {
      ProgressionDecision.increase => (
        semantic.successContainer,
        semantic.onSuccessContainer,
        l10n.progressionDecisionIncrease,
      ),
      ProgressionDecision.repeat => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
        l10n.progressionDecisionRepeat,
      ),
      ProgressionDecision.decrease => (
        semantic.accentContainer,
        semantic.onAccentContainer,
        l10n.progressionDecisionDecrease,
      ),
      ProgressionDecision.none => (Colors.transparent, Colors.transparent, ''),
    };

    return Semantics(
      label: glyph,
      child: Container(
        width: _diameter,
        height: _diameter,
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        alignment: Alignment.center,
        child: Text(
          glyph,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
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
              // Owner-reported: match the hero card above ("Тренировка
              // завершена", `_CompletedHeroCard`) instead of a small
              // inline icon+text row -- same badge size (28dp circle,
              // solid `accent`/`onAccent`, the same "pale container +
              // solid badge" pairing `_CompletedHeroCard` already uses
              // with `primary`/`primaryContainer`) and the same title
              // text style, centered, with the title below the badge
              // rather than beside it.
              Center(
                child: Column(
                  children: [
                    ShineSweep(
                      // Owner-reported: start at the midpoint of the
                      // confetti burst (`ConfettiOverlay`'s own 2240ms
                      // duration) -- was a fixed pause after it finished,
                      // then a pause before it finished; now tied
                      // directly to that duration instead of a separate
                      // hand-tuned constant, so the two stay in sync if
                      // the confetti timing ever changes again.
                      delay: const Duration(milliseconds: 2240 ~/ 2),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: semantic.accent,
                        child: Icon(
                          Icons.emoji_events,
                          color: semantic.onAccent,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.workoutSummaryNewRecordsTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: semantic.onAccentContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
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
