import 'package:flutter/material.dart';

import '../../../domain/models/workout_details.dart';
import '../../../l10n/app_localizations.dart';
import '../../exercises/exercise_type_labels.dart';
import '../set_field_config.dart';
import 'set_row.dart';

/// Card for one exercise entry in the workout editor (S-03): header + the
/// sets table + "+ Подход". Tags, comment, "Прошлые результаты" and the
/// progression segment are Stage 3+ scope, not included here.
class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.details,
    required this.onFieldChanged,
    required this.onFieldCommit,
    required this.onWarmupChanged,
    required this.onCompletedChanged,
    required this.onAddSet,
  });

  final WorkoutExerciseDetails details;
  final void Function(
    String setId,
    SetFieldSpec field,
    bool actual,
    double? value,
  )
  onFieldChanged;
  final void Function(String setId, SetFieldSpec field, bool actual)
  onFieldCommit;
  final void Function(String setId, bool value) onWarmupChanged;
  final void Function(String setId, bool value) onCompletedChanged;
  final VoidCallback onAddSet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fields = setFieldsFor(details.exercise.exerciseType, l10n);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(exerciseTypeIcon(details.exercise.exerciseType)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    details.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final set in details.sets)
              SetRow(
                set: set,
                fields: fields,
                onFieldChanged: (field, actual, value) =>
                    onFieldChanged(set.id, field, actual, value),
                onFieldCommit: (field, actual) =>
                    onFieldCommit(set.id, field, actual),
                onWarmupChanged: (value) => onWarmupChanged(set.id, value),
                onCompletedChanged: (value) =>
                    onCompletedChanged(set.id, value),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: Text(l10n.addSetAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
