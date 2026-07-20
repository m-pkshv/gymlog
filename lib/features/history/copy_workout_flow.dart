import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/workout.dart';
import '../../l10n/app_localizations.dart';

/// "Скопировать" (S-02 card menu and the "Копией" creation option, TS 8
/// section 8): prompts for the copy's date, calls
/// `WorkoutRepository.copyWorkout`, and opens the result in the editor.
/// Shared so both entry points behave identically.
Future<void> copyWorkoutFlow(
  BuildContext context,
  WidgetRef ref,
  Workout source,
) async {
  final l10n = AppLocalizations.of(context)!;
  // TS 8: the copy's date is chosen by the owner, not silently reused.
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked == null || !context.mounted) return;

  try {
    final copy = await ref
        .read(workoutRepositoryProvider)
        .copyWorkout(sourceWorkoutId: source.id, date: picked);
    if (context.mounted) context.push('/history/workout/${copy.id}');
  } catch (error, stackTrace) {
    ref
        .read(loggerProvider)
        .error(
          'Failed to copy workout ${source.id}',
          error: error,
          stackTrace: stackTrace,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.copyWorkoutError)));
    }
  }
}
