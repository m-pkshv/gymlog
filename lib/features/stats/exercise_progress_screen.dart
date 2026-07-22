import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_history_entry.dart';
import '../../domain/models/personal_record.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_progress_series.dart';
import 'record_type_labels.dart';
import 'record_value_format.dart';
import 'widgets/exercise_progress_chart.dart';

/// S-10 "Прогресс по упражнению" (04_UI_UX_SPEC.md, section 5): period-
/// filtered progress charts (max weight/1RM/tonnage for strength/reps, or
/// distance/pace/duration for cardio), the reps-at-weight table, and the
/// records list -- the table and records list are backed by the already-
/// cached `PersonalRecordRepository` (Stage 7 Steps 1-2); the charts are
/// computed fresh from `getExerciseHistory` (this step).
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
  List<ExerciseHistoryEntry> _history = const [];
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
      final history = exercise == null
          ? const <ExerciseHistoryEntry>[]
          : await ref
                .read(workoutRepositoryProvider)
                .getExerciseHistory(widget.exerciseId);
      if (!mounted) return;
      setState(() {
        _exercise = exercise;
        _history = history;
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
      appBar: AppBar(
        // Exercise names have no length limit (DM 6.1) -- UX 12: a long
        // one must ellipsize, not silently clip/overflow the AppBar, with
        // the full text still reachable via long-press.
        title: Tooltip(
          message: exercise?.name ?? '',
          child: Text(
            exercise?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError || exercise == null
          ? ErrorRetryState(
              message: l10n.exerciseProgressLoadError,
              onRetry: _load,
            )
          : _ProgressBody(exercise: exercise, history: _history),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.exercise, required this.history});

  final Exercise exercise;
  final List<ExerciseHistoryEntry> history;

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
            ..._chartsFor(l10n, exercise.exerciseType, history),
            if (repsAtWeight.isNotEmpty) ...[
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
              const SizedBox(height: 24),
            ],
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
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorRetryState(
        message: l10n.exerciseProgressLoadError,
        onRetry: () =>
            ref.invalidate(personalRecordsForExerciseProvider(exercise.id)),
      ),
    );
  }

  /// Type-dependent chart set (04_UI_UX_SPEC.md S-10): strength/reps get
  /// max weight/1RM/tonnage; cardio gets distance/pace/duration; time/
  /// stretch get none, mirroring `RecordsService`'s coverage exactly. Chart
  /// titles reuse the same `recordType*` labels as the records list below --
  /// each chart is that same figure's history, not a different metric.
  List<Widget> _chartsFor(
    AppLocalizations l10n,
    ExerciseType type,
    List<ExerciseHistoryEntry> history,
  ) {
    switch (type) {
      case ExerciseType.strength:
      case ExerciseType.reps:
        return [
          ExerciseProgressChart(
            title: l10n.recordTypeMaxWeight,
            history: history,
            seriesBuilder: maxWeightSeries,
          ),
          const SizedBox(height: 16),
          ExerciseProgressChart(
            title: l10n.recordTypeMax1RM,
            history: history,
            seriesBuilder: oneRepMaxSeries,
            isEstimated: true,
          ),
          const SizedBox(height: 16),
          ExerciseProgressChart(
            title: l10n.recordTypeMaxVolumeWorkout,
            history: history,
            seriesBuilder: tonnageSeries,
          ),
          const SizedBox(height: 24),
        ];
      case ExerciseType.cardio:
        return [
          ExerciseProgressChart(
            title: l10n.recordTypeMaxDistance,
            history: history,
            seriesBuilder: maxDistanceSeries,
          ),
          const SizedBox(height: 16),
          ExerciseProgressChart(
            title: l10n.recordTypeBestPace,
            history: history,
            seriesBuilder: bestPaceSeries,
          ),
          const SizedBox(height: 16),
          ExerciseProgressChart(
            title: l10n.recordTypeLongestDuration,
            history: history,
            seriesBuilder: longestDurationSeries,
          ),
          const SizedBox(height: 24),
        ];
      case ExerciseType.time:
      case ExerciseType.stretch:
        return const [];
    }
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
