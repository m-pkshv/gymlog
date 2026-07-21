import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../core/date_format.dart';
import '../../domain/enums.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_history_filter.dart';
import '../../domain/models/workout_tag.dart';
import '../../l10n/app_localizations.dart';
import '../workout_editor/status_labels.dart';
import 'calendar/history_calendar_view.dart';
import 'copy_workout_flow.dart';
import 'widgets/workout_history_tile.dart';

enum _NewWorkoutChoice { scratch, copy }

enum _HistoryViewMode { list, calendar }

/// S-02 "История": search by name + date range/statuses/tags filters (all
/// combinable, 04_UI_UX_SPEC.md section 5; Stage 3). Tapping a card opens
/// the editor (S-03); the per-card "⋮" menu offers "Копировать" (TS 8
/// section 8) and "Удалить" (soft delete + 5s Undo snackbar, DM 10) —
/// "перенести" from the same S-02 menu already exists inside the editor
/// (per-card move is a separate, not-yet-requested Stage 3 item); the FAB
/// opens the "с нуля/из шаблона/копией" creation menu.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  Set<WorkoutStatus> _statuses = {};
  Set<String> _tagIds = {};
  _HistoryViewMode _viewMode = _HistoryViewMode.list;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  WorkoutHistoryFilter get _filter => (
    query: _searchController.text.trim(),
    dateFrom: _dateFrom,
    dateTo: _dateTo,
    statuses: _statuses,
    tagIds: _tagIds,
  );

  // In calendar mode, month navigation is the date axis (see
  // HistoryCalendarView); the date-range fields are hidden in the filter
  // sheet and excluded here so the toggle icon doesn't show a stale badge.
  bool get _hasActiveFilters =>
      (_viewMode == _HistoryViewMode.list &&
          (_dateFrom != null || _dateTo != null)) ||
      _statuses.isNotEmpty ||
      _tagIds.isNotEmpty;

  bool get _hasActiveSearchOrFilters =>
      _hasActiveFilters || _searchController.text.trim().isNotEmpty;

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_HistoryFiltersResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _HistoryFilterSheet(
        showDateRange: _viewMode == _HistoryViewMode.list,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        statuses: _statuses,
        tagIds: _tagIds,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _dateFrom = result.dateFrom;
        _dateTo = result.dateTo;
        _statuses = result.statuses;
        _tagIds = result.tagIds;
      });
    }
  }

  void _setViewMode(_HistoryViewMode mode) {
    setState(() => _viewMode = mode);
  }

  void _resetAll() {
    setState(() {
      _searchController.clear();
      _dateFrom = null;
      _dateTo = null;
      _statuses = {};
      _tagIds = {};
    });
  }

  Future<void> _openNewWorkoutMenu() async {
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
              onTap: () => Navigator.of(
                sheetContext,
              ).pop(_NewWorkoutChoice.scratch),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: Text(l10n.newWorkoutFromCopyAction),
              onTap: () =>
                  Navigator.of(sheetContext).pop(_NewWorkoutChoice.copy),
            ),
            ListTile(
              enabled: false,
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.newWorkoutFromTemplateAction),
              subtitle: Text(l10n.comingSoonLabel),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case _NewWorkoutChoice.scratch:
        final workout = await ref
            .read(workoutRepositoryProvider)
            .createDraft(date: DateTime.now());
        if (mounted) context.push('/history/workout/${workout.id}');
      case _NewWorkoutChoice.copy:
        context.push('/history/copy-source');
    }
  }

  Future<void> _deleteWorkout(Workout workout) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await ref.read(workoutServiceProvider).delete(workout);
    if (!mounted) return;
    result.fold(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.workoutDeletedMessage),
            duration: undoSnackbarDuration,
            action: SnackBarAction(
              label: l10n.undoAction,
              onPressed: () =>
                  ref.read(workoutServiceProvider).restore(workout.id),
            ),
          ),
        );
      },
      (error) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteWorkoutError))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabHistory),
        actions: [
          IconButton(
            tooltip: _viewMode == _HistoryViewMode.list
                ? l10n.historyViewCalendarTooltip
                : l10n.historyViewListTooltip,
            onPressed: () => _setViewMode(
              _viewMode == _HistoryViewMode.list
                  ? _HistoryViewMode.calendar
                  : _HistoryViewMode.list,
            ),
            icon: Icon(
              _viewMode == _HistoryViewMode.list
                  ? Icons.calendar_month_outlined
                  : Icons.view_list_outlined,
            ),
          ),
          IconButton(
            tooltip: l10n.filterWorkoutsTooltip,
            onPressed: _openFilters,
            icon: _hasActiveFilters
                ? const Badge(child: Icon(Icons.tune))
                : const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchHistoryHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _viewMode == _HistoryViewMode.list
                ? _HistoryList(
                    filter: _filter,
                    isFiltered: _hasActiveSearchOrFilters,
                    onReset: _resetAll,
                    onCopy: (source) => copyWorkoutFlow(context, ref, source),
                    onDelete: _deleteWorkout,
                  )
                : HistoryCalendarView(
                    query: _searchController.text.trim(),
                    statuses: _statuses,
                    tagIds: _tagIds,
                    onCopy: (source) => copyWorkoutFlow(context, ref, source),
                    onDelete: _deleteWorkout,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewWorkoutMenu,
        tooltip: l10n.newWorkoutAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  const _HistoryList({
    required this.filter,
    required this.isFiltered,
    required this.onReset,
    required this.onCopy,
    required this.onDelete,
  });

  final WorkoutHistoryFilter filter;
  final bool isFiltered;
  final VoidCallback onReset;
  final void Function(Workout source) onCopy;
  final void Function(Workout workout) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(historyListProvider(filter));

    return historyAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState(l10n: l10n, isFiltered: isFiltered, onReset: onReset);
        }
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) => WorkoutHistoryTile(
            entry: entries[index],
            onCopy: onCopy,
            onDelete: onDelete,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text(l10n.historyLoadError)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l10n,
    required this.isFiltered,
    required this.onReset,
  });

  final AppLocalizations l10n;
  final bool isFiltered;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? l10n.historySearchEmptyTitle : l10n.historyEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onReset,
                child: Text(l10n.resetFiltersAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryFiltersResult {
  const _HistoryFiltersResult({
    required this.dateFrom,
    required this.dateTo,
    required this.statuses,
    required this.tagIds,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<WorkoutStatus> statuses;
  final Set<String> tagIds;
}

/// History's filter bottom sheet (04_UI_UX_SPEC.md, section 5). Edits a
/// local copy and only reports back via `Navigator.pop` on
/// "Сбросить"/"Применить" — same "apply, not live" pattern as the exercise
/// catalog's filter sheet (Stage 2, `ASSUMPTION(sheet-apply-not-live)`).
/// The tags section is hidden entirely when `AppSettings.showTags` is off
/// (S-17: "выключение скрывает чипы и фильтр тегов").
class _HistoryFilterSheet extends ConsumerStatefulWidget {
  const _HistoryFilterSheet({
    required this.showDateRange,
    required this.dateFrom,
    required this.dateTo,
    required this.statuses,
    required this.tagIds,
  });

  // Hidden in calendar view mode (Stage 3): month navigation is the date
  // axis there instead of an explicit range.
  final bool showDateRange;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final Set<WorkoutStatus> statuses;
  final Set<String> tagIds;

  @override
  ConsumerState<_HistoryFilterSheet> createState() =>
      _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends ConsumerState<_HistoryFilterSheet> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  late Set<WorkoutStatus> _statuses;
  late Set<String> _tagIds;

  @override
  void initState() {
    super.initState();
    _dateFrom = widget.dateFrom;
    _dateTo = widget.dateTo;
    _statuses = Set.of(widget.statuses);
    _tagIds = Set.of(widget.tagIds);
  }

  void _apply() {
    Navigator.of(context).pop(
      _HistoryFiltersResult(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        statuses: _statuses,
        tagIds: _tagIds,
      ),
    );
  }

  void _reset() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
      _statuses = {};
      _tagIds = {};
    });
  }

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateFrom = picked);
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dateTo = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showTags = ref.watch(appSettingsProvider).value?.showTags ?? true;
    final tagsAsync = ref.watch(workoutTagsListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.filtersTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (widget.showDateRange) ...[
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.filterDateFromLabel),
                        subtitle: Text(
                          _dateFrom != null
                              ? formatShortDate(_dateFrom!)
                              : l10n.filterAnyDate,
                        ),
                        onTap: _pickDateFrom,
                        trailing: _dateFrom != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _dateFrom = null),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.filterDateToLabel),
                        subtitle: Text(
                          _dateTo != null
                              ? formatShortDate(_dateTo!)
                              : l10n.filterAnyDate,
                        ),
                        onTap: _pickDateTo,
                        trailing: _dateTo != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() => _dateTo = null),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.filterStatusesLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final status in WorkoutStatus.values)
                    FilterChip(
                      label: Text(workoutStatusLabel(l10n, status)),
                      selected: _statuses.contains(status),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _statuses.add(status);
                        } else {
                          _statuses.remove(status);
                        }
                      }),
                    ),
                ],
              ),
              if (showTags) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.filterTagsLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                tagsAsync.when(
                  data: (tags) => tags.isEmpty
                      ? Text(l10n.workoutTagsEmpty)
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final WorkoutTag tag in tags)
                              FilterChip(
                                label: Text(tag.name),
                                selected: _tagIds.contains(tag.id),
                                onSelected: (selected) => setState(() {
                                  if (selected) {
                                    _tagIds.add(tag.id);
                                  } else {
                                    _tagIds.remove(tag.id);
                                  }
                                }),
                              ),
                          ],
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Text(l10n.workoutTagsLoadError),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: Text(l10n.filterResetAction),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: Text(l10n.filterApplyAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
