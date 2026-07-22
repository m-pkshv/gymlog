import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../domain/models/workout.dart';
import '../../l10n/app_localizations.dart';
import 'active_workout_conflict.dart';

/// "Начать" quick action (S-01 "Сегодня" card, Stage 9): starts [workout]
/// directly (`draft`/`planned` -> `inProgress`, DM 6.4.1), resolving the
/// "at most one `inProgress`" conflict the same way the editor's own status
/// menu does (`resolveActiveWorkoutConflict`), then opens the editor (S-03)
/// on it — the same destination "Открыть" pushes to, so either action on
/// the card lands the owner on a workout that's now actually started.
Future<void> startWorkoutFlow(
  BuildContext context,
  WidgetRef ref,
  Workout workout,
) async {
  final l10n = AppLocalizations.of(context)!;

  final conflict = await ref
      .read(workoutRepositoryProvider)
      .getInProgressWorkout();
  if (!context.mounted) return;
  if (conflict != null && conflict.id != workout.id) {
    final resolved = await resolveActiveWorkoutConflict(
      context,
      ref,
      conflict,
    );
    if (!resolved || !context.mounted) return;
  }

  final result = await ref
      .read(workoutServiceProvider)
      .changeStatus(workout: workout, newStatus: WorkoutStatus.inProgress);
  if (!context.mounted) return;
  result.fold(
    (_) => context.push('/history/workout/${workout.id}'),
    (error) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.workoutStatusChangeError))),
  );
}
