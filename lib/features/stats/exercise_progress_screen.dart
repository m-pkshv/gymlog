import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/personal_record.dart';
import '../../l10n/app_localizations.dart';
import 'record_type_labels.dart';
import 'record_value_format.dart';

/// S-10 "Прогресс по упражнению" (04_UI_UX_SPEC.md, section 5). This step
/// covers the records list and the reps-at-weight table, both backed by the
/// already-cached `PersonalRecordRepository` (Stage 7 Steps 1-2) -- no new
/// history computation needed for either. The period-filtered progress
/// charts (max weight/1RM/tonnage or distance/pace/duration over time) are
/// a later step.
class ExerciseProgressScreen extends ConsumerStatefulWidget {
  const ExerciseProgressScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseProgressScreen> createState() =>
      _ExerciseProgressScreenState();
}

class _ExerciseProgressScreenState
    extends ConsumerState<ExerciseProgressScreen> {
  Exercise? _exercise;
  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final exercise = await ref
          .read(exerciseRepositoryProvider)
          .getById(widget.exerciseId);
      if (!mounted) return;
      setState(() {
        _exercise = exercise;
        _isLoading = false;
        _loadError = exercise == null;
      });
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to load exercise for progress screen',
            error: error,
            stackTrace: stackTrace,
          );
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = _exercise;

    return Scaffold(
      appBar: AppBar(title: Text(exercise?.name ?? '')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError || exercise == null
          ? Center(child: Text(l10n.exerciseProgressLoadError))
          : _ProgressBody(exercise: exercise),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recordsAsync = ref.watch(
      personalRecordsForExerciseProvider(exercise.id),
    );

    return recordsAsync.when(
      data: (records) {
        final generalRecords =
            records.where((r) => r.recordType != RecordType.maxRepsAtWeight).toList()
              ..sort(
                (a, b) => a.recordType.index.compareTo(b.recordType.index),
              );
        final repsAtWeight =
            records.where((r) => r.recordType == RecordType.maxRepsAtWeight).toList()
              ..sort((a, b) => a.keyValue!.compareTo(b.keyValue!));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.statsRecordsSectionTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (generalRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.statsRecordsEmptyState),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (final record in generalRecords)
                      _RecordTile(l10n: l10n, record: record),
                  ],
                ),
              ),
            if (repsAtWeight.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.statsRepsAtWeightTableTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _RepsAtWeightTable(l10n: l10n, records: repsAtWeight),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(l10n.exerciseProgressLoadError)),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.l10n, required this.record});

  final AppLocalizations l10n;
  final PersonalRecord record;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(recordTypeLabel(l10n, record.recordType)),
      subtitle: Text(formatShortDate(record.achievedAt)),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatRecordValue(l10n, record.recordType, record.value),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (isEstimatedRecord(record.recordType))
            Text(
              l10n.statsEstimatedBadge,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      onTap: () => context.push('/history/workout/${record.workoutId}'),
    );
  }
}

class _RepsAtWeightTable extends StatelessWidget {
  const _RepsAtWeightTable({required this.l10n, required this.records});

  final AppLocalizations l10n;
  final List<PersonalRecord> records;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text(l10n.statsRepsAtWeightWeightColumn)),
        DataColumn(
          label: Text(l10n.statsRepsAtWeightRepsColumn),
          numeric: true,
        ),
        DataColumn(label: Text(l10n.statsRepsAtWeightDateColumn)),
      ],
      rows: [
        for (final record in records)
          DataRow(
            cells: [
              DataCell(Text(l10n.statsKgValue(record.keyValue!.toStringAsFixed(1)))),
              DataCell(Text(record.value.round().toString())),
              DataCell(Text(formatShortDate(record.achievedAt))),
            ],
            onSelectChanged: (_) =>
                context.push('/history/workout/${record.workoutId}'),
          ),
      ],
    );
  }
}
