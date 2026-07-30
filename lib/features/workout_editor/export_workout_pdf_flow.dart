import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../app/providers.dart';
import '../../domain/models/personal_record.dart';
import '../../domain/models/workout_details.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf/workout_pdf_file_name.dart';

/// "⋮ → Экспортировать в PDF" (workout editor) and the equivalent button on
/// the S-05 summary screen (Stage 11): builds a single-workout PDF and
/// hands it to the OS share sheet. Shared so both entry points behave
/// identically, same "one flow function, several entry points" pattern as
/// `copyWorkoutFlow`/`createTemplateFromWorkoutFlow`.
///
/// "New record" filtering (a `PersonalRecord` counts as set by *this*
/// workout iff its cached `workoutId` matches) is done here, not inside
/// `WorkoutPdfService` -- that service has no repository access of its
/// own, mirroring the summary screen's `_NewRecordsSection`
/// (workout_summary/screen.dart) exactly so both surfaces can never
/// disagree about which records are "new".
Future<void> exportWorkoutPdfFlow(
  BuildContext context,
  WidgetRef ref,
  WorkoutDetails details,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final profile = await ref.read(userProfileRepositoryProvider).watchProfile().first;
    final recordRepository = ref.read(personalRecordRepositoryProvider);
    final newRecordsByExerciseId = <String, List<PersonalRecord>>{};
    for (final exerciseDetails in details.exercises) {
      final records = await recordRepository
          .watchForExercise(exerciseDetails.exercise.id)
          .first;
      newRecordsByExerciseId[exerciseDetails.exercise.id] = records
          .where((record) => record.workoutId == details.workout.id)
          .toList();
    }

    final bytes = await ref
        .read(workoutPdfServiceProvider)
        .buildWorkoutPdf(
          details: details,
          profile: profile,
          newRecordsByExerciseId: newRecordsByExerciseId,
          l10n: l10n,
        );

    if (!context.mounted) return;
    await Printing.sharePdf(
      bytes: bytes,
      filename: workoutPdfFileName(details.workout),
    );
  } catch (error, stackTrace) {
    ref
        .read(loggerProvider)
        .error('Workout PDF export failed', error: error, stackTrace: stackTrace);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportWorkoutPdfError)));
  }
}
