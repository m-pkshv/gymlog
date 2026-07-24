import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/error_retry_state.dart';
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
                  padding: const EdgeInsets.all(16),
                  children: const [_EmptyTodayState(), SizedBox(height: 24), _QuickActions()],
                );
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (active != null) _ContinueWorkoutCard(workout: active),
                  for (final entry in entries) _WorkoutListCard(entry: entry),
                  const SizedBox(height: 24),
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
class _ContinueWorkoutCard extends StatelessWidget {
  const _ContinueWorkoutCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name =
        workout.name ?? '${l10n.workoutDefaultNamePrefix} ${formatShortDate(workout.date)}';
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(workoutStatusLabel(l10n, workout.status)),
        trailing: FilledButton(
          onPressed: () => context.go('/history/workout/${workout.id}'),
          child: Text(l10n.continueWorkoutAction),
        ),
        onTap: () => context.go('/history/workout/${workout.id}'),
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
class _WorkoutListCard extends ConsumerWidget {
  const _WorkoutListCard({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final workout = entry.workout;
    final name = workout.name ?? l10n.workoutDefaultNamePrefix;
    final canStart =
        workout.status == WorkoutStatus.draft ||
        workout.status == WorkoutStatus.planned;
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(
          '${formatShortDate(workout.date)} · '
          '${workoutStatusLabel(l10n, workout.status)} · '
          '${l10n.workoutExerciseCount(entry.exerciseCount)}',
        ),
        trailing: canStart
            ? FilledButton(
                onPressed: () => startWorkoutFlow(context, ref, workout),
                child: Text(l10n.todayStartAction),
              )
            : null,
        onTap: () => context.go('/history/workout/${workout.id}'),
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
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
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
class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => createWorkoutFromScratchFlow(context, ref),
          icon: const Icon(Icons.add),
          label: Text(l10n.newWorkoutFromScratchAction),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/history/template-source'),
          icon: const Icon(Icons.description_outlined),
          label: Text(l10n.newWorkoutFromTemplateAction),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go('/history/copy-source'),
          icon: const Icon(Icons.copy_outlined),
          label: Text(l10n.newWorkoutFromCopyAction),
        ),
      ],
    );
  }
}
