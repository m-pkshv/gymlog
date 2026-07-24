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
/// pattern as `copyWorkoutFlow` (Stage 3). Uses `go`, not `push` (Stage
/// 10, owner-reported) -- the S-12 template card's "Create workout" is
/// called from the "More" branch and S-01's "Из шаблона" quick action
/// pushes into a picker outside `/history`, so `push` would attach the
/// editor to the wrong branch's own Navigator (see `copyWorkoutFlow`'s
/// doc comment).
Future<void> createWorkoutFromTemplateFlow(
  BuildContext context,
  WidgetRef ref,
  WorkoutTemplate template,
) async {
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
    if (context.mounted) context.go('/history/workout/${workout.id}');
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
