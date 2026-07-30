import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/date_format.dart';
import '../../core/duration_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/personal_record.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/workout_details.dart';
import '../../features/stats/record_type_labels.dart';
import '../../features/stats/record_value_format.dart';
import '../../features/workout_editor/set_field_config.dart';
import '../../features/workout_editor/status_labels.dart';
import '../../features/workout_editor/widgets/workout_tag_chip.dart';
import '../../features/workout_summary/workout_summary_stats.dart';
import '../../l10n/app_localizations.dart';

/// Single-workout PDF export (Stage 11) -- e.g. to send a completed
/// workout to a coach. Mirrors the same figures S-05 (the workout summary
/// screen) already shows (duration/exercises/sets/tonnage, new records),
/// plus a plan-vs-fact table per exercise and the owner's own profile
/// details in the header, so a reader who isn't the app's user can tell
/// whose workout this is and what actually happened.
class WorkoutPdfService {
  const WorkoutPdfService();

  static const _regularFontAsset = 'assets/fonts/Roboto-Regular.ttf';
  static const _boldFontAsset = 'assets/fonts/Roboto-Bold.ttf';

  Future<Uint8List> buildWorkoutPdf({
    required WorkoutDetails details,
    required UserProfile profile,
    required Map<String, List<PersonalRecord>> newRecordsByExerciseId,
    required AppLocalizations l10n,
  }) async {
    final regularFont = pw.Font.ttf(await rootBundle.load(_regularFontAsset));
    final boldFont = pw.Font.ttf(await rootBundle.load(_boldFontAsset));

    pw.MemoryImage? avatarImage;
    final avatarPath = profile.avatarPath;
    if (avatarPath != null) {
      final file = File(avatarPath);
      if (await file.exists()) {
        avatarImage = pw.MemoryImage(await file.readAsBytes());
      }
    }

    final stats = computeWorkoutSummaryStats(details);
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    doc.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(details, profile, avatarImage, l10n),
          pw.SizedBox(height: 16),
          _buildStatsRow(stats, l10n),
          if ((details.workout.comment ?? '').trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(details.workout.comment!.trim()),
          ],
          if (newRecordsByExerciseId.values.any((records) => records.isNotEmpty)) ...[
            pw.SizedBox(height: 16),
            _buildNewRecordsSection(
              details,
              newRecordsByExerciseId,
              l10n,
              boldFont,
            ),
          ],
          pw.SizedBox(height: 20),
          for (final exerciseDetails in details.exercises)
            _buildExerciseSection(exerciseDetails, l10n, boldFont),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _buildHeader(
    WorkoutDetails details,
    UserProfile profile,
    pw.MemoryImage? avatarImage,
    AppLocalizations l10n,
  ) {
    final fullName = [
      profile.firstName,
      profile.lastName,
    ].where((part) => (part ?? '').trim().isNotEmpty).join(' ');
    final displayName = fullName.isNotEmpty ? fullName : profile.nickname;
    final title = details.workout.name ?? l10n.workoutDefaultNamePrefix;
    final durationLabel = details.workout.actualDurationSec != null
        ? formatElapsedTime(details.workout.actualDurationSec!)
        : null;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (avatarImage != null) ...[
          pw.ClipOval(
            child: pw.Image(
              avatarImage,
              width: 48,
              height: 48,
              fit: pw.BoxFit.cover,
            ),
          ),
          pw.SizedBox(width: 12),
        ],
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if ((displayName ?? '').trim().isNotEmpty)
                pw.Text(
                  displayName!.trim(),
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                [
                  formatShortDate(details.workout.date),
                  workoutStatusLabel(l10n, details.workout.status),
                  ?durationLabel,
                ].join('   ·   '),
                style: const pw.TextStyle(
                  fontSize: 11,
                  color: PdfColors.grey700,
                ),
              ),
              if (details.tags.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                pw.Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in details.tags)
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          workoutTagLabel(l10n, tag),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildStatsRow(WorkoutSummaryStats stats, AppLocalizations l10n) {
    return pw.Row(
      children: [
        _statTile(l10n.workoutSummaryExercisesLabel, stats.exerciseCount.toString()),
        _statTile(l10n.workoutSummarySetsLabel, stats.setCount.toString()),
        _statTile(
          l10n.workoutSummaryTonnageLabel,
          l10n.workoutSummaryTonnageValue(stats.tonnageKg.toStringAsFixed(1)),
        ),
      ],
    );
  }

  pw.Widget _statTile(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  /// Same "a record counts as new here iff its cached `workoutId` matches
  /// this workout" rule as the summary screen's `_NewRecordsSection`
  /// (workout_summary/screen.dart) -- [newRecordsByExerciseId] is expected
  /// to already be filtered that way by the caller (this service has no
  /// repository access of its own).
  pw.Widget _buildNewRecordsSection(
    WorkoutDetails details,
    Map<String, List<PersonalRecord>> byExerciseId,
    AppLocalizations l10n,
    pw.Font boldFont,
  ) {
    final groups = <pw.Widget>[];
    for (final exerciseDetails in details.exercises) {
      final records = byExerciseId[exerciseDetails.exercise.id] ?? const [];
      if (records.isEmpty) continue;
      groups.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                exerciseDetails.exercise.name,
                style: pw.TextStyle(font: boldFont, fontSize: 11),
              ),
              for (final record in records)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 8, top: 2),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          _recordSubtitle(l10n, record),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Text(
                        _recordValueWithBadge(l10n, record),
                        style: pw.TextStyle(font: boldFont, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }
    if (groups.isEmpty) return pw.SizedBox();

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.amber700),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            l10n.workoutSummaryNewRecordsTitle,
            style: pw.TextStyle(font: boldFont, fontSize: 12),
          ),
          ...groups,
        ],
      ),
    );
  }

  String _recordSubtitle(AppLocalizations l10n, PersonalRecord record) {
    final parts = [
      recordTypeLabel(l10n, record.recordType),
      if (record.recordType == RecordType.maxRepsAtWeight)
        l10n.statsKgValue(record.keyValue!.toStringAsFixed(1)),
    ];
    return parts.join(' · ');
  }

  String _recordValueWithBadge(AppLocalizations l10n, PersonalRecord record) {
    final value = formatRecordValue(l10n, record.recordType, record.value);
    if (!isEstimatedRecord(record.recordType)) return value;
    return '$value (${l10n.statsEstimatedBadge})';
  }

  pw.Widget _buildExerciseSection(
    WorkoutExerciseDetails exerciseDetails,
    AppLocalizations l10n,
    pw.Font boldFont,
  ) {
    final fields = setFieldsFor(exerciseDetails.exercise.exerciseType, l10n);
    final headers = [
      l10n.setColumnNumber,
      l10n.setColumnPlan,
      l10n.setColumnFact,
      l10n.setColumnDone,
    ];
    final rows = exerciseDetails.sets
        .map(
          (set) => [
            set.setNumber.toString(),
            formatFieldsSummary(set, fields, actual: false),
            formatFieldsSummary(set, fields, actual: true),
            set.isCompleted ? 'X' : '',
          ],
        )
        .toList();
    final comment = exerciseDetails.workoutExercise.comment;

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            exerciseDetails.exercise.name,
            style: pw.TextStyle(font: boldFont, fontSize: 13),
          ),
          if ((comment ?? '').trim().isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text(
                comment!.trim(),
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ),
          pw.SizedBox(height: 6),
          if (rows.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: rows,
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerStyle: pw.TextStyle(font: boldFont, fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
            ),
        ],
      ),
    );
  }
}
