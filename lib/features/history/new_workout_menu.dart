import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

enum _NewWorkoutChoice { scratch, copy, template }

/// "Новая тренировка" bottom sheet (S-02's FAB and the S-01 "Сегодня" quick
/// actions, Stage 9): "с нуля" / "копией" (S-02 → S-04 picker) / "из
/// шаблона" (S-02 → S-04 picker) — 04_UI_UX_SPEC.md, section 5. Shared so
/// both entry points offer the identical menu (02_DEVELOPMENT_PLAN.md
/// Stage 3, `AskUserQuestion`-confirmed placement).
Future<void> showNewWorkoutMenu(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final choice = await showModalBottomSheet<_NewWorkoutChoice>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.add),
            title: Text(l10n.newWorkoutFromScratchAction),
            onTap: () => Navigator.of(sheetContext).pop(_NewWorkoutChoice.scratch),
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: Text(l10n.newWorkoutFromCopyAction),
            onTap: () => Navigator.of(sheetContext).pop(_NewWorkoutChoice.copy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.newWorkoutFromTemplateAction),
            onTap: () =>
                Navigator.of(sheetContext).pop(_NewWorkoutChoice.template),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;

  switch (choice) {
    case _NewWorkoutChoice.scratch:
      final workout = await ref
          .read(workoutRepositoryProvider)
          .createDraft(date: DateTime.now());
      if (context.mounted) context.push('/history/workout/${workout.id}');
    case _NewWorkoutChoice.copy:
      context.push('/history/copy-source');
    case _NewWorkoutChoice.template:
      context.push('/history/template-source');
  }
}
