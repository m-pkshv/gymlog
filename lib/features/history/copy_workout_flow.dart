import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/workout.dart';
import '../../l10n/app_localizations.dart';

/// "Скопировать" (S-02 card menu and the "Копией" creation option, TS 8
/// section 8): prompts for the copy's date, calls
/// `WorkoutRepository.copyWorkout`, and opens the result in the editor.
/// Shared so both entry points behave identically. Uses `push`, not `go`
/// (`/workout/:id` is a route outside the tab shell, `app/router.dart`'s
/// top comment) -- see `today/screen.dart`'s doc comment for why.
///
/// [replaceCurrentRoute] (Stage 10 redesign, owner-reported): the
/// "Копией" *picker* (`/copy-source`) passes `true` -- once a source is
/// chosen there, the picker has done its one job, so the editor replaces
/// it in the stack instead of stacking on top; "back" from the fresh copy,
/// or "Готово" after finishing it, then lands directly on whatever opened
/// the picker (Today or History), not back on a now-pointless picker
/// screen. History's own "⋮ → Копировать" on an existing card (not through
/// the picker) keeps the default `push`, since going back to History's own
/// list afterward is exactly what's wanted there.
Future<void> copyWorkoutFlow(
  BuildContext context,
  WidgetRef ref,
  Workout source, {
  bool replaceCurrentRoute = false,
}) async {
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
    if (!context.mounted) return;
    if (replaceCurrentRoute) {
      context.pushReplacement('/workout/${copy.id}');
    } else {
      context.push('/workout/${copy.id}');
    }
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
