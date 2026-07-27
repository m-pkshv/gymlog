import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../domain/models/workout_template.dart';
import '../../l10n/app_localizations.dart';

/// "Создать тренировку" (S-12 template card menu / History's "Из шаблона"
/// creation option, TS 8 section 8): prompts for the new workout's date,
/// calls `WorkoutRepository.createFromTemplate`, and opens the result in
/// the editor. Shared so both entry points behave identically, same
/// pattern as `copyWorkoutFlow` (Stage 3). Uses `push`, not `go`
/// (`/workout/:id` is a route outside the tab shell, `app/router.dart`'s
/// top comment) -- see `today/screen.dart`'s doc comment for why.
///
/// [replaceCurrentRoute] (Stage 10 redesign, owner-reported): the "Из
/// шаблона" *picker* (`/template-source`) passes `true` -- same reasoning
/// as `copyWorkoutFlow`'s: once a template is chosen there, the picker's
/// job is done, so the editor replaces it in the stack; "back"/"Готово"
/// then land directly on whatever opened the picker (Today or History).
/// S-12's own "⋮ → Создать тренировку" on a template card (not through the
/// picker) keeps the default `push`.
Future<void> createWorkoutFromTemplateFlow(
  BuildContext context,
  WidgetRef ref,
  WorkoutTemplate template, {
  bool replaceCurrentRoute = false,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (picked == null || !context.mounted) return;

  try {
    final workout = await ref
        .read(workoutRepositoryProvider)
        .createFromTemplate(templateId: template.id, date: picked);
    if (!context.mounted) return;
    if (replaceCurrentRoute) {
      context.pushReplacement('/workout/${workout.id}');
    } else {
      context.push('/workout/${workout.id}');
    }
  } catch (error, stackTrace) {
    ref
        .read(loggerProvider)
        .error(
          'Failed to create workout from template ${template.id}',
          error: error,
          stackTrace: stackTrace,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.createWorkoutFromTemplateError)));
    }
  }
}
