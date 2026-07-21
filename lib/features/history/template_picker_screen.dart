import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import 'create_workout_from_template_flow.dart';

/// "Из шаблона" (creation menu option, TS 8 section 8): pick which
/// template to create a workout from. Archived templates are excluded, same
/// default as the S-12 list itself.
class TemplatePickerScreen extends ConsumerWidget {
  const TemplatePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final templatesAsync = ref.watch(templateListProvider(false));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templateSourcePickerTitle)),
      body: templatesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return Center(child: Text(l10n.templateSourcePickerEmpty));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.template.name),
                subtitle: Text(l10n.templateExerciseCount(entry.exerciseCount)),
                onTap: () =>
                    createWorkoutFromTemplateFlow(context, ref, entry.template),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text(l10n.templatesLoadError)),
      ),
    );
  }
}
