import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/enums.dart';
import '../../domain/models/workout.dart';
import '../../l10n/app_localizations.dart';

enum ActiveWorkoutConflictResolution { finishOther, cancelOther }

/// DM 6.4.1's "at most one `inProgress` workout" invariant: shows the
/// "Уже есть активная тренировка" dialog and, if the owner picks an action,
/// finishes or cancels [conflict] (a workout other than the one the caller
/// is trying to start) via `workout_service` directly. Returns whether the
/// conflict was resolved, so the caller knows it's now safe to retry its
/// own transition to `inProgress`. Shared by the workout editor's own
/// status menu (S-03, Stage 3) and the S-01 "Начать" quick action
/// (Stage 9), so both behave identically.
Future<bool> resolveActiveWorkoutConflict(
  BuildContext context,
  WidgetRef ref,
  Workout conflict,
) async {
  final l10n = AppLocalizations.of(context)!;
  final resolution = await showDialog<ActiveWorkoutConflictResolution>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.activeWorkoutConflictTitle),
      content: Text(l10n.activeWorkoutConflictMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(ActiveWorkoutConflictResolution.cancelOther),
          child: Text(l10n.activeWorkoutConflictCancelOtherAction),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(ActiveWorkoutConflictResolution.finishOther),
          child: Text(l10n.activeWorkoutConflictFinishOtherAction),
        ),
      ],
    ),
  );
  if (resolution == null || !context.mounted) return false;

  final targetStatus =
      resolution == ActiveWorkoutConflictResolution.finishOther
      ? WorkoutStatus.completed
      : WorkoutStatus.cancelled;
  final result = await ref
      .read(workoutServiceProvider)
      .changeStatus(workout: conflict, newStatus: targetStatus);
  if (!context.mounted) return false;
  return result.fold((_) => true, (error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.workoutStatusChangeError)));
    return false;
  });
}
