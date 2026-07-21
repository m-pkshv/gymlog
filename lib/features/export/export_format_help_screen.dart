import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/export/exercises_csv.dart';
import '../../services/export/measurements_csv.dart';
import '../../services/export/workouts_csv.dart';

/// S-16's "Описание формата CSV" (04_UI_UX_SPEC.md: "встроенная справка из
/// `03`, раздел 10"). Column-name lists reuse the same `*CsvHeader`
/// constants the generators write (`services/export/*_csv.dart`) instead
/// of a translated copy, so this screen can never drift out of sync with
/// what an actual export file contains -- those names are literal CSV
/// header text, not user-facing strings, so they're intentionally not run
/// through ARB.
class ExportFormatHelpScreen extends StatelessWidget {
  const ExportFormatHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final columnsStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontFamily: 'monospace');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exportFormatHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.exportFormatHelpIntro),
          const SizedBox(height: 24),
          Text(l10n.exportFormatHelpManifestTitle, style: titleStyle),
          const SizedBox(height: 4),
          Text(l10n.exportFormatHelpManifestDescription),
          const SizedBox(height: 24),
          Text('workouts.csv', style: titleStyle),
          const SizedBox(height: 4),
          Text(l10n.exportFormatHelpWorkoutsDescription),
          const SizedBox(height: 8),
          Text(l10n.exportFormatHelpColumnsLabel),
          SelectableText(workoutsCsvHeader.join(', '), style: columnsStyle),
          const SizedBox(height: 24),
          Text('measurements.csv', style: titleStyle),
          const SizedBox(height: 4),
          Text(l10n.exportFormatHelpMeasurementsDescription),
          const SizedBox(height: 8),
          Text(l10n.exportFormatHelpColumnsLabel),
          SelectableText(
            measurementsCsvHeader.join(', '),
            style: columnsStyle,
          ),
          const SizedBox(height: 24),
          Text('exercises.csv', style: titleStyle),
          const SizedBox(height: 4),
          Text(l10n.exportFormatHelpExercisesDescription),
          const SizedBox(height: 8),
          Text(l10n.exportFormatHelpColumnsLabel),
          SelectableText(exercisesCsvHeader.join(', '), style: columnsStyle),
        ],
      ),
    );
  }
}
