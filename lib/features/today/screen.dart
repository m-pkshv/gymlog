import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_history_entry.dart';
import '../../l10n/app_localizations.dart';
import '../history/new_workout_menu.dart';
import '../history/start_workout_flow.dart';
import '../workout_editor/status_labels.dart';

/// S-01 "Сегодня" (04_UI_UX_SPEC.md, section 5, Stage 9): the nearest
/// upcoming workout (or, if one is already `inProgress`, a "Продолжить"
/// card instead -- a separate case per the spec) plus the "Новая
/// тренировка"/"Из шаблона"/"Скопировать прошлую" quick actions, always
/// visible below the card (or the greeting, when there's neither).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeAsync = ref.watch(inProgressWorkoutProvider);
    final upcomingAsync = ref.watch(nextUpcomingWorkoutProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabToday)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            activeAsync.when(
              data: (active) {
                if (active != null) return _ContinueWorkoutCard(workout: active);
                return upcomingAsync.when(
                  data: (entry) => entry != null
                      ? _UpcomingWorkoutCard(entry: entry)
                      : const _EmptyTodayState(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => ErrorRetryState(
                    message: l10n.todayLoadError,
                    onRetry: () => ref.invalidate(nextUpcomingWorkoutProvider),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorRetryState(
                message: l10n.todayLoadError,
                onRetry: () => ref.invalidate(inProgressWorkoutProvider),
              ),
            ),
            const SizedBox(height: 24),
            const _QuickActions(),
          ],
        ),
      ),
    );
  }
}

/// "При активной — карточка «Продолжить»" — shown instead of the upcoming-
/// workout card whenever `inProgressWorkoutProvider` has a value (DM 6.4.1:
/// at most one, so there's never a choice between several).
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
          onPressed: () => context.push('/history/workout/${workout.id}'),
          child: Text(l10n.continueWorkoutAction),
        ),
        onTap: () => context.push('/history/workout/${workout.id}'),
      ),
    );
  }
}

/// "Ближайшая тренировка (сегодня/будущая ближайшая): карточка со статусом,
/// упражнениями, кнопки «Начать» / «Открыть»". ASSUMPTION(today-card-
/// actions): the button starts it directly (`startWorkoutFlow`, DM 6.4.1);
/// tapping the card body opens the editor without changing status --
/// 04_UI_UX_SPEC.md doesn't spell out which control does which, but this
/// is the same "primary button vs. tap-to-open" shape already used
/// elsewhere in the app (e.g. History's cards), so it's low-risk.
class _UpcomingWorkoutCard extends ConsumerWidget {
  const _UpcomingWorkoutCard({required this.entry});

  final WorkoutHistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final workout = entry.workout;
    final name = workout.name ?? l10n.workoutDefaultNamePrefix;
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(
          '${formatShortDate(workout.date)} · '
          '${workoutStatusLabel(l10n, workout.status)} · '
          '${l10n.workoutExerciseCount(entry.exerciseCount)}',
        ),
        trailing: FilledButton(
          onPressed: () => startWorkoutFlow(context, ref, workout),
          child: Text(l10n.todayStartAction),
        ),
        onTap: () => context.push('/history/workout/${workout.id}'),
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
          onPressed: () => context.push('/history/template-source'),
          icon: const Icon(Icons.description_outlined),
          label: Text(l10n.newWorkoutFromTemplateAction),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push('/history/copy-source'),
          icon: const Icon(Icons.copy_outlined),
          label: Text(l10n.newWorkoutFromCopyAction),
        ),
      ],
    );
  }
}
