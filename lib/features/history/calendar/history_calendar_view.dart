import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/widgets/error_retry_state.dart';
import '../../../domain/enums.dart';
import '../../../domain/models/workout.dart';
import '../../../domain/models/workout_history_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/workout_history_tile.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Calendar-view alternative to History's list (02_DEVELOPMENT_PLAN.md
/// Stage 3 functionality list; `04_UI_UX_SPEC.md` does not describe this
/// screen at all — layout/interaction below are a deliberate design choice,
/// confirmed with the owner 2026-07-21 to implement now rather than defer
/// further, not a data/architecture decision): a month grid with a dot
/// marker on days that have at least one workout matching the active
/// search/status/tag filters; tapping a day shows that day's workouts
/// below, using the same [WorkoutHistoryTile] as the list view. The
/// date-range filter fields don't apply here — month navigation is the
/// date axis instead (`HistoryScreen` hides them in the filter sheet while
/// this view is active).
class HistoryCalendarView extends ConsumerStatefulWidget {
  const HistoryCalendarView({
    super.key,
    required this.query,
    required this.statuses,
    required this.tagIds,
    required this.onCopy,
    required this.onCreateTemplate,
    required this.onDelete,
  });

  final String query;
  final Set<WorkoutStatus> statuses;
  final Set<String> tagIds;
  final void Function(Workout source) onCopy;
  final void Function(Workout source) onCreateTemplate;
  final void Function(Workout workout) onDelete;

  @override
  ConsumerState<HistoryCalendarView> createState() =>
      _HistoryCalendarViewState();
}

class _HistoryCalendarViewState extends ConsumerState<HistoryCalendarView> {
  late DateTime _visibleMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month, 1);
    _selectedDay = today;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final monthStart = _visibleMonth;
    final monthEnd = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0);
    final filter = (
      query: widget.query,
      dateFrom: monthStart,
      dateTo: monthEnd,
      statuses: widget.statuses,
      tagIds: widget.tagIds,
    );
    final historyAsync = ref.watch(historyListProvider(filter));

    return Column(
      children: [
        _MonthHeader(
          month: _visibleMonth,
          onPrevious: () => _changeMonth(-1),
          onNext: () => _changeMonth(1),
        ),
        Expanded(
          child: historyAsync.when(
            data: (entries) {
              final byDay = <DateTime, List<WorkoutHistoryEntry>>{};
              for (final entry in entries) {
                byDay
                    .putIfAbsent(_dateOnly(entry.workout.date), () => [])
                    .add(entry);
              }
              final selectedEntries = byDay[_selectedDay] ?? const [];

              return Column(
                children: [
                  _MonthGrid(
                    month: _visibleMonth,
                    selectedDay: _selectedDay,
                    markedDays: byDay.keys.toSet(),
                    onSelectDay: (day) => setState(() => _selectedDay = day),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: selectedEntries.isEmpty
                        ? Center(child: Text(l10n.historyCalendarDayEmpty))
                        : ListView.builder(
                            itemCount: selectedEntries.length,
                            itemBuilder: (context, index) => WorkoutHistoryTile(
                              entry: selectedEntries[index],
                              onCopy: widget.onCopy,
                              onCreateTemplate: widget.onCreateTemplate,
                              onDelete: widget.onDelete,
                            ),
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => ErrorRetryState(
              message: l10n.historyLoadError,
              onRetry: () => ref.invalidate(historyListProvider(filter)),
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final rawLabel = DateFormat.yMMMM(locale).format(month);
    final label = rawLabel.isEmpty
        ? rawLabel
        : rawLabel[0].toUpperCase() + rawLabel.substring(1);

    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: l10n.historyCalendarPreviousMonthTooltip,
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            tooltip: l10n.historyCalendarNextMonthTooltip,
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.markedDays,
    required this.onSelectDay,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Set<DateTime> markedDays;
  final void Function(DateTime day) onSelectDay;

  // A fixed row height (rather than GridView's width-driven aspect ratio)
  // keeps the grid's total height bounded (<= 7 rows * _rowHeight) no
  // matter how wide the screen is — an aspect-ratio-1 GridView cell grows
  // with screen width and overflowed the column on wide viewports. 48dp is
  // also the UX 11 minimum touch target height (04_UI_UX_SPEC.md, section
  // 11); the marker dot needs its own space below the day number too,
  // which doubles as headroom against the 1.6x text-scale check (UX 9).
  // Cell *width* on a 320dp-wide phone (04's minimum supported width,
  // section 10) is ~43dp after padding — below 48dp is unavoidable for a
  // 7-column grid at that width (7 × 48 alone exceeds 320dp); accepted the
  // same way section 10 already accepts icon-only compression elsewhere on
  // small screens.
  static const _rowHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final monthStart = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = monthStart.weekday - 1; // grid is Monday-first
    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();
    final today = _dateOnly(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    // 2024-01-01 is a Monday; used only to read localized weekday
    // abbreviations for the header row, not as a real calendar date.
    final referenceMonday = DateTime(2024, 1, 1);
    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(locale).format(referenceMonday.add(Duration(days: i))),
    ];

    Widget dayCell(int index) {
      if (index < leadingBlanks || index >= totalCells) {
        return const SizedBox.shrink();
      }
      final day = DateTime(month.year, month.month, index - leadingBlanks + 1);
      final isSelected = day == selectedDay;
      final isToday = day == today;
      final isMarked = markedDays.contains(day);

      // UX 11: the marker dot signals "has a workout" by shape/presence,
      // not color alone, but a screen reader can't see it at all without
      // this — same reasoning as "состояния передаются не только цветом"
      // for workout status chips elsewhere in the app.
      final semanticLabel = [
        DateFormat.yMMMMd(locale).format(day),
        if (isMarked) l10n.historyCalendarDayHasWorkout,
        if (isToday) l10n.historyCalendarDayToday,
      ].join(', ');

      return Semantics(
        label: semanticLabel,
        button: true,
        selected: isSelected,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => onSelectDay(day),
          customBorder: const CircleBorder(),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? colorScheme.primary : null,
              border: isToday && !isSelected
                  ? Border.all(color: colorScheme.primary)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : null,
                  ),
                ),
                if (isMarked)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.primary,
                    ),
                  )
                else
                  const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      key: const Key('historyCalendarGrid'),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
            ],
          ),
          for (var row = 0; row < rowCount; row++)
            SizedBox(
              height: _rowHeight,
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(child: dayCell(row * 7 + col)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
