import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../core/widgets/status_badge.dart';
import '../../domain/enums.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_history_entry.dart';
import '../../l10n/app_localizations.dart';
import '../history/new_workout_menu.dart';
import '../history/start_workout_flow.dart';
import '../workout_editor/status_labels.dart';

/// S-01 "Сегодня" (04_UI_UX_SPEC.md, section 5; Stage 10, owner-reported):
/// every workout dated today (any status — it already happened, is
/// happening, or will happen later today) or in the future (any status),
/// sorted by date. The active (`inProgress`) workout, if any, gets its own
/// pinned "Продолжить" card above the list instead of appearing twice
/// (owner-confirmed) — DM 6.4.1 guarantees there's at most one. Below
/// everything: the "Новая тренировка"/"Из шаблона"/"Скопировать прошлую"
/// quick actions, always visible.
///
/// Every navigation out of this screen into `/history/...` uses
/// `context.go`, never `context.push` (Stage 10, owner-reported bug: after
/// "Завершить" -> "Готово" on the summary screen, returning to "Сегодня"
/// still showed the finished workout's summary with the same "Готово"
/// button). `push` attaches the pushed route to the *calling* branch's own
/// Navigator in a `StatefulShellRoute` — since `/history/workout/:id` etc.
/// belong to the History branch, not Today's, a `push` from here left the
/// editor/summary stuck at the top of Today's own (offstage) stack even
/// after `go('/history')` moved the visible branch elsewhere; switching
/// back to "Сегодня" then showed that stale leftover. `go` re-resolves the
/// full location and correctly attaches it to History's branch instead.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeAsync = ref.watch(inProgressWorkoutProvider);
    final upcomingAsync = ref.watch(todayAndUpcomingWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabToday)),
      body: SafeArea(
        child: activeAsync.when(
          data: (active) => upcomingAsync.when(
            data: (entries) {
              if (active == null && entries.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: const [
                    _EmptyTodayState(),
                    SizedBox(height: AppSpacing.xl),
                    _QuickActions(),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (active != null) _ContinueWorkoutCard(workout: active),
                  for (final entry in entries) _WorkoutListCard(entry: entry),
                  const SizedBox(height: AppSpacing.md),
                  const _QuickActions(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ErrorRetryState(
              message: l10n.todayLoadError,
              onRetry: () => ref.invalidate(todayAndUpcomingWorkoutsProvider),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => ErrorRetryState(
            message: l10n.todayLoadError,
            onRetry: () => ref.invalidate(inProgressWorkoutProvider),
          ),
        ),
      ),
    );
  }
}

/// "При активной — карточка «Продолжить»" — pinned above the list whenever
/// `inProgressWorkoutProvider` has a value (DM 6.4.1: at most one, so
/// there's never a choice between several, and it's never duplicated
/// inside the list below — the list query excludes `inProgress`).
///
/// Stage 10 redesign, AUDIT.md section 1.1: "today's workout and a future
/// one look identical, despite differing in importance" and "the Start
/// button is the only color accent on the whole screen". An active workout
/// is the single most actionable thing this screen can show — given the
/// same accent treatment the rest timer/summary's hero number use, instead
/// of the plain neutral `Card` every other row gets. [StatusBadge] isn't
/// used here (unlike the rows below): this card only ever renders for
/// `inProgress`, so a status badge would just repeat what "Продолжить"
/// already says. ASSUMPTION(today-hero-card): no mockup reference was
/// available for this screen; the accent treatment is a cosmetic call
/// applying AUDIT's own critique with the already-established token, not a
/// literal copy of a reference design.
class _ContinueWorkoutCard extends StatelessWidget {
  const _ContinueWorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final name =
        workout.name ?? '${l10n.workoutDefaultNamePrefix} ${formatShortDate(workout.date)}';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: semantic.accentContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/history/workout/${workout.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                color: semantic.onAccentContainer,
                size: 36,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: semantic.onAccentContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      workoutStatusLabel(l10n, workout.status),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(
                        color: semantic.onAccentContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              FilledButton(
                onPressed: () => context.go('/history/workout/${workout.id}'),
                child: Text(l10n.continueWorkoutAction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row of the "Сегодня" list (Stage 10): every status is possible here
/// (today's workouts can already be `completed`/`cancelled`/`skipped`, not
/// just `draft`/`planned`), so the "Start" button only makes sense — and
/// only appears — for the two not-yet-performed statuses. Every card is
/// still tappable to open the workout, regardless of status (same
/// tap-to-open shape as History's cards). ASSUMPTION(today-card-actions,
/// carried over from the original single-card version): the button starts
/// it directly (`startWorkoutFlow`, DM 6.4.1); tapping the card body opens
/// the editor without changing status.
///
/// Stage 10 redesign, AUDIT.md section 1.1: status used to be buried as
/// plain text in the middle of a dense one-line subtitle -- moved to a
/// color-coded [StatusBadge] (same one History's cards use), always
/// visible regardless of whether "Start" applies.
///
/// A custom `Column` layout, not `ListTile(trailing: ...)` -- found live
/// on-device, not just in a test: a `ListTile`'s title column shares its
/// row with `trailing`, so a wide `trailing` (a status badge whose RU text
/// can run long, e.g. "Запланирована", plus a "Начать" button) squeezed
/// the title down to almost nothing, wrapping a short single word like
/// "Тренировка" mid-word instead of just being on its own line. Giving the
/// title its own full-width row removes that squeeze regardless of how
/// long the badge/button content gets.
///
/// Restyled per the Stage 10 mockup (owner-supplied screenshot): outlined
/// card (`AppRadius.card` + `outlineVariant` border, matching
/// `GroupedSection`/`StatsSectionCard`), "Начать" moved onto the title row
/// (short pill button, no longer squeezes the title now that the badge
/// lives on its own row below) with a chevron in its place for
/// non-actionable statuses, and the date shown as a relative day label
/// (`formatRelativeDay`) instead of the absolute `DD.MM.YYYY`. The mockup
/// also shows a time-of-day next to the date ("Сегодня, 18:00") -- not
/// reproduced, `Workout.date` has no time component (DM 6.4) and nothing
/// here should show a fabricated value. The mockup's top "streak" widget
/// (day-of-week checkmarks + badges) isn't ported: it's new functionality
/// with no schema/business rules in this project (owner-confirmed,
/// out of scope for this pass).
class _WorkoutListCard extends ConsumerWidget {
  const _WorkoutListCard({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final workout = entry.workout;
    final name = workout.name ?? l10n.workoutDefaultNamePrefix;
    final canStart =
        workout.status == WorkoutStatus.draft ||
        workout.status == WorkoutStatus.planned;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/history/workout/${workout.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (canStart)
                    FilledButton(
                      onPressed: () =>
                          startWorkoutFlow(context, ref, workout),
                      child: Text(l10n.todayStartAction),
                    )
                  else
                    Icon(Icons.chevron_right, color: scheme.outline),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${formatRelativeDay(context, workout.date)} · '
                      '${l10n.workoutExerciseCount(entry.exerciseCount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(status: workout.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Пустое состояние: приветствие + те же действия" -- the greeting; the
/// quick actions themselves are `_QuickActions`, always rendered below
/// regardless of which of these three states is showing above it.
class _EmptyTodayState extends StatelessWidget {
  const _EmptyTodayState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.todayEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// "Быстрые действия: «Новая тренировка», «Из шаблона», «Скопировать
/// прошлую»" -- unlike History's FAB (which bundles the same three choices
/// behind one bottom sheet, `showNewWorkoutMenu`), S-01 shows them as three
/// separate, always-visible buttons.
///
/// Stage 10 redesign: restyled per the mockup's "+ Добавить" wide button
/// plus two icon-only buttons, rather than three equal-weight labeled
/// buttons in a row -- "from scratch" is the primary action (wide,
/// leading), template/copy are secondary shortcuts (compact, icon +
/// tooltip, same `UX 11` icon-only-needs-a-label convention used
/// elsewhere in the app). The mockup's dashed border on the wide button
/// isn't reproduced (a real dashed `BorderSide` needs a custom painter --
/// no such helper exists in the project and one wasn't worth adding for a
/// purely decorative detail); a regular outlined border is used instead.
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Rounded-rectangle, not the M3 default stadium/circle shape (owner-
    // reported, mockup screenshot: squared-off corners on all three
    // buttons) -- scoped to this row rather than a theme-wide
    // OutlinedButton/IconButton override, same reasoning `StatsSectionCard`/
    // `GroupedSection` give for not touching `CardTheme` globally.
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
    );
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => createWorkoutFromScratchFlow(context, ref),
            style: OutlinedButton.styleFrom(shape: shape),
            icon: const Icon(Icons.add),
            label: Text(l10n.newWorkoutFromScratchAction),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.outlined(
          onPressed: () => context.go('/history/template-source'),
          style: IconButton.styleFrom(shape: shape),
          icon: const Icon(Icons.description_outlined),
          tooltip: l10n.newWorkoutFromTemplateAction,
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton.outlined(
          onPressed: () => context.go('/history/copy-source'),
          style: IconButton.styleFrom(shape: shape),
          icon: const Icon(Icons.copy_outlined),
          tooltip: l10n.newWorkoutFromCopyAction,
        ),
      ],
    );
  }
}
