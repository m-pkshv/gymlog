import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../domain/models/template_list_entry.dart';
import '../../domain/models/workout_template.dart';
import '../../l10n/app_localizations.dart';
import '../history/create_workout_from_template_flow.dart';
import 'widgets/create_template_dialog.dart';

enum _TemplateCardAction { createWorkout, duplicate, archive, delete }

/// S-12 template list: name + exercise count, "⋮" menu ("Создать
/// тренировку" — TS 8 section 8, reverse of "Создать шаблон";
/// "Дублировать" — full within-aggregate clone;
/// архивировать/разархивировать; удалить — Undo), FAB "Создать" (from
/// scratch, TS 8). Archived templates are hidden by default
/// (`ASSUMPTION(templates-hide-archived-by-default)`, Stage 5 Step 1).
class TemplateListScreen extends ConsumerWidget {
  const TemplateListScreen({super.key});

  Future<void> _createTemplate(BuildContext context, WidgetRef ref) async {
    final service = ref.read(workoutTemplateServiceProvider);
    final created = await showDialog<WorkoutTemplate>(
      context: context,
      builder: (context) => CreateTemplateDialog(
        create: (name) => service.create(name: name),
      ),
    );
    if (created != null && context.mounted) {
      context.push('/more/templates/${created.id}');
    }
  }

  Future<void> _duplicate(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
  ) async {
    final service = ref.read(workoutTemplateServiceProvider);
    final created = await showDialog<WorkoutTemplate>(
      context: context,
      builder: (context) => CreateTemplateDialog(
        initialName: template.name,
        title: AppLocalizations.of(context)!.duplicateTemplateTitle,
        create: (name) =>
            service.duplicate(templateId: template.id, name: name),
      ),
    );
    if (created != null && context.mounted) {
      context.push('/more/templates/${created.id}');
    }
  }

  Future<void> _toggleArchived(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(workoutTemplateRepositoryProvider)
          .update(template.copyWith(isArchived: !template.isArchived));
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to toggle archived for template ${template.id}',
            error: error,
            stackTrace: stackTrace,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.archiveTemplateError)));
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    WorkoutTemplate template,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final repository = ref.read(workoutTemplateRepositoryProvider);
    try {
      await repository.deleteTemplate(template.id);
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to delete template ${template.id}',
            error: error,
            stackTrace: stackTrace,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteTemplateError)));
      }
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.templateDeletedMessage),
        duration: undoSnackbarDuration,
        action: SnackBarAction(
          label: l10n.undoAction,
          onPressed: () => repository.restoreTemplate(template.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(templateListProvider(false));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      body: templatesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _EmptyState(
              l10n: l10n,
              onCreate: () => _createTemplate(context, ref),
            );
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) => _TemplateListTile(
              entry: entries[index],
              onCreateWorkout: () => createWorkoutFromTemplateFlow(
                context,
                ref,
                entries[index].template,
              ),
              onDuplicate: () =>
                  _duplicate(context, ref, entries[index].template),
              onArchiveToggle: () =>
                  _toggleArchived(context, ref, entries[index].template),
              onDelete: () => _delete(context, ref, entries[index].template),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(l10n.templatesLoadError)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createTemplate(context, ref),
        tooltip: l10n.createTemplateAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TemplateListTile extends StatelessWidget {
  const _TemplateListTile({
    required this.entry,
    required this.onCreateWorkout,
    required this.onDuplicate,
    required this.onArchiveToggle,
    required this.onDelete,
  });

  final TemplateListEntry entry;
  final VoidCallback onCreateWorkout;
  final VoidCallback onDuplicate;
  final VoidCallback onArchiveToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final template = entry.template;
    return ListTile(
      title: Text(template.name),
      subtitle: Text(l10n.templateExerciseCount(entry.exerciseCount)),
      trailing: PopupMenuButton<_TemplateCardAction>(
        onSelected: (action) {
          switch (action) {
            case _TemplateCardAction.createWorkout:
              onCreateWorkout();
            case _TemplateCardAction.duplicate:
              onDuplicate();
            case _TemplateCardAction.archive:
              onArchiveToggle();
            case _TemplateCardAction.delete:
              onDelete();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _TemplateCardAction.createWorkout,
            child: Text(l10n.createWorkoutFromTemplateAction),
          ),
          PopupMenuItem(
            value: _TemplateCardAction.duplicate,
            child: Text(l10n.duplicateTemplateAction),
          ),
          PopupMenuItem(
            value: _TemplateCardAction.archive,
            child: Text(
              template.isArchived
                  ? l10n.unarchiveTemplateAction
                  : l10n.archiveTemplateAction,
            ),
          ),
          PopupMenuItem(
            value: _TemplateCardAction.delete,
            child: Text(l10n.deleteTemplateAction),
          ),
        ],
      ),
      onTap: () => context.push('/more/templates/${template.id}'),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.onCreate});

  final AppLocalizations l10n;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.copy_all_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.templatesEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(l10n.createTemplateAction),
            ),
          ],
        ),
      ),
    );
  }
}
