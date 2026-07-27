import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_template.dart';
import '../../l10n/app_localizations.dart';
import '../templates/widgets/create_template_dialog.dart';

/// "Создать шаблон" (S-02's and the workout editor's own "⋮" menu, TS 8
/// section 8, Stage 10 owner-reported: any workout -- draft, planned or
/// already completed in History -- can be saved as a template, not just
/// from a History card): prompts for the template's name (defaulting to
/// the workout's own display name), calls
/// `WorkoutTemplateService.createFromWorkout` (which only ever copies
/// exercises/order/planned values, never actuals or completion marks --
/// same as the "prompt worked" rule below), and opens the result for
/// review. Shared so both entry points behave identically, same "create
/// then open" pattern as `copyWorkoutFlow`/`createWorkoutFromTemplateFlow`.
///
/// Uses `go`, not `push`: `/more/templates/:id` belongs to the "Ещё"
/// branch of the tab shell (`app/router.dart`), not a top-level route like
/// `/workout/:id` -- `push`ing it here would attach the template editor to
/// whichever branch/Navigator the caller happens to be on instead of
/// "Ещё"'s own (see `today/screen.dart`'s doc comment for the general
/// explanation of why that's wrong for a `StatefulShellRoute`).
Future<void> createTemplateFromWorkoutFlow(
  BuildContext context,
  WidgetRef ref,
  Workout source,
) async {
  final l10n = AppLocalizations.of(context)!;
  final service = ref.read(workoutTemplateServiceProvider);
  final defaultName =
      source.name ?? '${l10n.workoutDefaultNamePrefix} ${formatShortDate(source.date)}';
  final created = await showDialog<WorkoutTemplate>(
    context: context,
    builder: (context) => CreateTemplateDialog(
      initialName: defaultName,
      create: (name) => service.createFromWorkout(workoutId: source.id, name: name),
    ),
  );
  if (created != null && context.mounted) {
    context.go('/more/templates/${created.id}');
  }
}
