import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import '../../app/providers.dart';
import '../../core/reference_data_ids.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/enums.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/exercise_catalog_filter.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';
import 'reference_data_labels.dart';

/// S-06 "Упражнения": search (matches the canonical and localized name,
/// DM 12) plus type/muscle group/equipment/archived/user-created filters,
/// all combinable (04_UI_UX_SPEC.md, section 5 — Stage 2 acceptance
/// criteria). Search is a persistent field under the AppBar; filters live
/// in a bottom sheet opened from the AppBar action.
class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  ExerciseType? _type;
  String? _muscleGroupId;
  String? _equipmentId;
  bool _includeArchived = false;
  bool _onlyUserCreated = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Jumps the list to [rowIndex] out of [totalRows] (S-06, Stage 10,
  /// owner-reported: "точки быстрого перемещения... как алфавитный переход
  /// в контактах"). `ListView.builder` never knows every row's exact pixel
  /// height up front (section headers and exercise cards differ, and a
  /// lazily-built sliver only has an *estimate* of its total scroll extent
  /// until every item has been laid out at least once) — rather than try to
  /// track real per-row heights, this jumps to the *proportional* offset
  /// `rowIndex / totalRows` of however much scroll extent is currently
  /// known. That's the same trade-off every "no exact heights" jump-list
  /// implementation makes: it lands close to the right section, not
  /// necessarily pixel-exact, same as tapping a letter in Contacts doesn't
  /// promise the very first matching row sits at the very top.
  void _jumpToRow(int rowIndex, int totalRows) {
    if (!_scrollController.hasClients || totalRows <= 1) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    if (maxExtent <= 0) return;
    final target = (rowIndex / (totalRows - 1)) * maxExtent;
    _scrollController.jumpTo(target.clamp(0.0, maxExtent));
  }

  ExerciseCatalogFilter get _filter => (
    query: _searchController.text.trim(),
    type: _type,
    muscleGroupId: _muscleGroupId,
    equipmentId: _equipmentId,
    includeArchived: _includeArchived,
    onlyUserCreated: _onlyUserCreated,
  );

  bool get _hasActiveFilters =>
      _type != null ||
      _muscleGroupId != null ||
      _equipmentId != null ||
      _includeArchived ||
      _onlyUserCreated;

  bool get _hasActiveSearchOrFilters =>
      _hasActiveFilters || _searchController.text.trim().isNotEmpty;

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_FiltersResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        type: _type,
        muscleGroupId: _muscleGroupId,
        equipmentId: _equipmentId,
        includeArchived: _includeArchived,
        onlyUserCreated: _onlyUserCreated,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _type = result.type;
        _muscleGroupId = result.muscleGroupId;
        _equipmentId = result.equipmentId;
        _includeArchived = result.includeArchived;
        _onlyUserCreated = result.onlyUserCreated;
      });
    }
  }

  void _resetAll() {
    setState(() {
      _searchController.clear();
      _type = null;
      _muscleGroupId = null;
      _equipmentId = null;
      _includeArchived = false;
      _onlyUserCreated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(exercisesListProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabExercises),
        actions: [
          IconButton(
            tooltip: l10n.filterExercisesTooltip,
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
                hintText: l10n.searchExercisesHint,
                prefixIcon: const Icon(Icons.search),
                // Owner-reported: a quick way to clear the search text
                // without selecting/backspacing it by hand -- only shown
                // once there's something to clear; `_searchController`
                // already has a listener that calls `setState` on every
                // change (this screen's `initState`), so clearing it here
                // makes the icon disappear on its own, no extra state.
                // Same fix as History's own search field.
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.searchExercisesClearTooltip,
                        icon: const Icon(Icons.clear),
                        onPressed: _searchController.clear,
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                if (exercises.isEmpty) {
                  return _EmptyState(
                    l10n: l10n,
                    isFiltered: _hasActiveSearchOrFilters,
                    onReset: _resetAll,
                  );
                }
                final rows = _groupByMuscleGroup(exercises);
                final sections = _sectionAnchors(rows);
                final list = ListView.builder(
                  controller: _scrollController,
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return switch (row) {
                      _SectionHeaderRow() => _MuscleGroupSectionHeader(
                        muscleGroupId: row.muscleGroupId,
                        count: row.count,
                      ),
                      _ExerciseRow() => _ExerciseListTile(
                        exercise: row.exercise,
                      ),
                    };
                  },
                );
                // A jump-to-section rail only earns its screen space once
                // there's more than one section to jump between.
                if (sections.length <= 1) return list;
                return Stack(
                  children: [
                    list,
                    Positioned(
                      top: 0,
                      bottom: 72, // clears the FAB (Stage 10, owner-reported)
                      right: 0,
                      child: _SectionIndexRail(
                        key: const Key('exercise-index-rail'),
                        sections: sections,
                        totalRows: rows.length,
                        onSelect: (rowIndex) =>
                            _jumpToRow(rowIndex, rows.length),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorRetryState(
                message: l10n.exercisesLoadError,
                onRetry: () => ref.invalidate(exercisesListProvider(_filter)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/exercises/new'),
        tooltip: l10n.createExerciseAction,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A flattened "section header, then its exercises" row list, built once
/// per [ExercisesScreen] build rather than kept as a nested structure --
/// [ListView.builder] can then stay lazily virtualized (TS 11.6: the
/// catalog holds ~200 rows, the same scale-sensitivity that motivated the
/// project's own 1000-workout scroll profiling on Stage 10) instead of
/// eagerly building every section's children up front.
sealed class _ListRow {}

class _SectionHeaderRow extends _ListRow {
  _SectionHeaderRow(this.muscleGroupId, this.count);

  /// `null` = the "no muscle group" bucket (user-created exercises that
  /// never got one).
  final String? muscleGroupId;
  final int count;
}

class _ExerciseRow extends _ListRow {
  _ExerciseRow(this.exercise);

  final Exercise exercise;
}

/// Groups [exercises] by `primaryMuscleGroupId` (Stage 10 redesign,
/// AUDIT.md section 1.3: "no grouping/sections at all -- just one flat
/// list"). Section order follows [muscleGroupIds]' canonical order (the
/// same fixed order the filter sheet's dropdown and the seeded per-
/// muscle-group tags already use), not alphabetically -- alphabetical
/// order would reshuffle by locale, this doesn't. The "no group" bucket,
/// if non-empty, sorts last.
///
/// *Within* each section, exercises sort alphabetically by (already-
/// localized, DM 12) name, case-insensitively -- owner-reported
/// (redesign_v2): previously left in whatever order the provider
/// returned (Stage 2's `createdAt DESC`). No separate "shorter name
/// wins" rule is needed for the case the owner called out ("Жим штанги"
/// above "Жим штанги лёжа"): plain string comparison already sorts a
/// name before any longer name it's a prefix of -- there's no character
/// at that position to compare against, so the shorter string is
/// `compareTo`'s "smaller" by definition.
List<_ListRow> _groupByMuscleGroup(List<Exercise> exercises) {
  final byGroup = <String?, List<Exercise>>{};
  for (final exercise in exercises) {
    byGroup
        .putIfAbsent(exercise.primaryMuscleGroupId, () => <Exercise>[])
        .add(exercise);
  }
  final rows = <_ListRow>[];
  for (final id in [...muscleGroupIds, null]) {
    final group = byGroup[id];
    if (group == null || group.isEmpty) continue;
    group.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    rows.add(_SectionHeaderRow(id, group.length));
    rows.addAll(group.map(_ExerciseRow.new));
  }
  return rows;
}

/// One entry per section header in [rows], in the same order they appear
/// (S-06, Stage 10, owner-reported: the jump rail's dots) — [rowIndex] is
/// what [_ExercisesScreenState._jumpToRow] needs; [muscleGroupId] isn't
/// used for display anymore (the dots are neutral, see
/// [_SectionIndexRail]'s doc comment) but stays on the record in case a
/// future tweak wants it back.
List<({String? muscleGroupId, int rowIndex})> _sectionAnchors(
  List<_ListRow> rows,
) {
  final anchors = <({String? muscleGroupId, int rowIndex})>[];
  for (var i = 0; i < rows.length; i++) {
    final row = rows[i];
    if (row is _SectionHeaderRow) {
      anchors.add((muscleGroupId: row.muscleGroupId, rowIndex: i));
    }
  }
  return anchors;
}

/// The jump rail itself (S-06, Stage 10, owner-reported: "точки быстрого
/// перемещения... как алфавитный переход в контактах") — one dot per
/// [sections] entry. A single vertical-drag gesture covers both a plain tap
/// (Flutter reports a tap as a drag that starts and ends with ~no movement,
/// so `onVerticalDragStart` alone already fires for it) and a Contacts-style
/// scan across dots without lifting the finger — [onSelect] fires every
/// time the touched dot changes, not on every pixel of movement, both to
/// avoid redundant scroll jumps and to know when to fire
/// [HapticFeedback.selectionClick] (the same per-letter tick Contacts-style
/// pickers give on every native platform).
///
/// Stage 10, owner-reported (second pass, "ужасный вид... сложно попасть"):
/// the first version colored each dot by muscle group, spread all of them
/// across the *entire* available height (`MainAxisAlignment.spaceEvenly`
/// over the full rail) at a bare 24dp width. All three turned out wrong in
/// practice — the per-muscle-group color duplicated the section headers'
/// own color without adding information here; stretching thinly across the
/// whole screen when there are only a few sections looked sparse and made
/// each dot's effective drag target *height* tiny; 24dp is already half
/// Material's own 48dp minimum touch target, easy to slide off sideways
/// while scanning down a screen edge. Now: dots are neutral
/// (`onSurfaceVariant`, no color), packed at a fixed row height instead of
/// stretched (so few sections cluster tightly rather than spreading thin),
/// and the rail is twice as wide (48dp, meeting the 48dp minimum) with that
/// same fixed row height as its floor -- capped, not fixed, so a catalog
/// with many sections still fits without overflowing.
class _SectionIndexRail extends StatefulWidget {
  const _SectionIndexRail({
    super.key,
    required this.sections,
    required this.totalRows,
    required this.onSelect,
  });

  final List<({String? muscleGroupId, int rowIndex})> sections;
  final int totalRows;
  final ValueChanged<int> onSelect;

  @override
  State<_SectionIndexRail> createState() => _SectionIndexRailState();
}

class _SectionIndexRailState extends State<_SectionIndexRail> {
  int? _activeIndex;

  static const double _railWidth = 48;
  static const double _maxDotRowHeight = 32;

  void _handleTouch(double localDy, double rowHeight, int count) {
    if (count == 0 || rowHeight <= 0) return;
    final index = (localDy / rowHeight).floor().clamp(0, count - 1);
    if (index == _activeIndex) return;
    setState(() => _activeIndex = index);
    HapticFeedback.selectionClick();
    widget.onSelect(widget.sections[index].rowIndex);
  }

  void _endTouch() {
    if (_activeIndex == null) return;
    setState(() => _activeIndex = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final count = widget.sections.length;
    return Semantics(
      label: l10n.exerciseIndexRailLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rowHeight = count == 0
              ? _maxDotRowHeight
              : (constraints.maxHeight / count).clamp(0.0, _maxDotRowHeight);
          return Center(
            child: SizedBox(
              width: _railWidth,
              height: rowHeight * count,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragStart: (details) =>
                    _handleTouch(details.localPosition.dy, rowHeight, count),
                onVerticalDragUpdate: (details) =>
                    _handleTouch(details.localPosition.dy, rowHeight, count),
                onVerticalDragEnd: (_) => _endTouch(),
                onVerticalDragCancel: _endTouch,
                // Stage 10, owner-reported: dim to a faint hint when idle,
                // full opacity only while actually being dragged/tapped --
                // otherwise the rail sat there at full strength permanently,
                // competing with the list for attention even when unused.
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: _activeIndex != null ? 1.0 : 0.35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var i = 0; i < count; i++)
                        _RailDot(
                          color: scheme.onSurfaceVariant,
                          active: _activeIndex == i,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RailDot extends StatelessWidget {
  const _RailDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final size = active ? 12.0 : 8.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MuscleGroupSectionHeader extends StatelessWidget {
  const _MuscleGroupSectionHeader({
    required this.muscleGroupId,
    required this.count,
  });

  final String? muscleGroupId;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final label = muscleGroupId == null
        ? l10n.exerciseNoMuscleGroupLabel
        : muscleGroupLabel(l10n, muscleGroupId!);
    final color = muscleGroupId == null
        ? scheme.outline
        : muscleGroupColor(muscleGroupId!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.workoutExerciseCount(count),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One exercise row (S-06). Stage 10 redesign, AUDIT.md section 1.3: the
/// leading icon used to be the same neutral, uncolored glyph on nearly
/// every row ("the catalog's icon carries no information") -- now a
/// muscle-group-colored circle (white icon, the same "white against an
/// arbitrary palette color, not the theme" precedent already used for the
/// tag-color swatch's checkmark, Stage 9) instead of a plain gray `Icon`.
/// Wrapped in a `Card` (same treatment History/Today's cards got) so rows
/// no longer blend together on a fast scroll.
class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final subtitleParts = [
      exerciseTypeLabel(l10n, exercise.exerciseType),
      if (exercise.primaryMuscleGroupId != null)
        muscleGroupLabel(l10n, exercise.primaryMuscleGroupId!),
    ];
    final avatarColor = exercise.primaryMuscleGroupId == null
        ? scheme.surfaceContainerHighest
        : muscleGroupColor(exercise.primaryMuscleGroupId!);
    final avatarForeground = exercise.primaryMuscleGroupId == null
        ? scheme.onSurfaceVariant
        : Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        // Owner-reported (redesign_v2): the app's own design language is
        // rounded squares/rectangles (buttons, cards, chips -- see
        // `AppRadius`), not circles -- a plain `CircleAvatar` here didn't
        // match. Sized up twice since: first from an initial
        // 40dp/`AppRadius.control` to 48dp (the app's own min touch-target
        // size elsewhere), then to 56dp -- owner-reported: room for this
        // to read well once real per-exercise icon art replaces the plain
        // type glyph here (D-3, still not delivered). `AppRadius.button`
        // (16) kept as-is at the larger size too -- close enough to the
        // same radius-to-box ratio as before (16/48 -> 16/56) that it
        // wasn't worth changing on its own.
        leading: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: avatarColor,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Icon(
            exerciseTypeIcon(exercise.exerciseType),
            color: avatarForeground,
            size: 30,
          ),
        ),
        title: Text(exercise.name),
        subtitle: Text(subtitleParts.join(' · ')),
        trailing: exercise.isArchived
            ? Chip(label: Text(l10n.exerciseArchivedBadge))
            : null,
        onTap: () => context.push('/exercises/${exercise.id}'),
      ),
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
              Icons.fitness_center_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? l10n.exercisesSearchEmptyTitle
                  : l10n.exercisesEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isFiltered)
              OutlinedButton(
                onPressed: onReset,
                child: Text(l10n.resetFiltersAction),
              )
            else
              FilledButton.icon(
                onPressed: () => context.push('/exercises/new'),
                icon: const Icon(Icons.add),
                label: Text(l10n.createExerciseAction),
              ),
          ],
        ),
      ),
    );
  }
}

class _FiltersResult {
  const _FiltersResult({
    required this.type,
    required this.muscleGroupId,
    required this.equipmentId,
    required this.includeArchived,
    required this.onlyUserCreated,
  });

  final ExerciseType? type;
  final String? muscleGroupId;
  final String? equipmentId;
  final bool includeArchived;
  final bool onlyUserCreated;
}

/// Filter bottom sheet (04_UI_UX_SPEC.md, section 5: "выборы/фильтры —
/// bottom sheet с ручкой-индикатором", provided by `showDragHandle: true`).
/// Edits a local copy and only reports back to [ExercisesScreen] via
/// [Navigator.pop] on "Применить"/"Сбросить" — the list itself doesn't
/// re-query on every tap inside the sheet.
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.type,
    required this.muscleGroupId,
    required this.equipmentId,
    required this.includeArchived,
    required this.onlyUserCreated,
  });

  final ExerciseType? type;
  final String? muscleGroupId;
  final String? equipmentId;
  final bool includeArchived;
  final bool onlyUserCreated;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  ExerciseType? _type;
  String? _muscleGroupId;
  String? _equipmentId;
  bool _includeArchived = false;
  bool _onlyUserCreated = false;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _muscleGroupId = widget.muscleGroupId;
    _equipmentId = widget.equipmentId;
    _includeArchived = widget.includeArchived;
    _onlyUserCreated = widget.onlyUserCreated;
  }

  void _apply() {
    Navigator.of(context).pop(
      _FiltersResult(
        type: _type,
        muscleGroupId: _muscleGroupId,
        equipmentId: _equipmentId,
        includeArchived: _includeArchived,
        onlyUserCreated: _onlyUserCreated,
      ),
    );
  }

  void _reset() {
    setState(() {
      _type = null;
      _muscleGroupId = null;
      _equipmentId = null;
      _includeArchived = false;
      _onlyUserCreated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.filtersTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExerciseType?>(
              isExpanded: true,
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.exerciseTypeLabel),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.filterAnyType),
                ),
                for (final type in ExerciseType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(exerciseTypeLabel(l10n, type)),
                  ),
              ],
              onChanged: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _muscleGroupId,
              decoration: InputDecoration(
                labelText: l10n.filterMuscleGroupLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.filterAnyMuscleGroup),
                ),
                DropdownMenuItem(
                  value: exerciseFilterNoneValue,
                  child: Text(l10n.exerciseNoMuscleGroupLabel),
                ),
                for (final id in muscleGroupIds)
                  DropdownMenuItem(
                    value: id,
                    child: Text(muscleGroupLabel(l10n, id)),
                  ),
              ],
              onChanged: (value) => setState(() => _muscleGroupId = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              isExpanded: true,
              initialValue: _equipmentId,
              decoration: InputDecoration(
                labelText: l10n.exerciseEquipmentLabel,
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.filterAnyEquipment),
                ),
                DropdownMenuItem(
                  value: exerciseFilterNoneValue,
                  child: Text(l10n.exerciseNoEquipmentLabel),
                ),
                for (final id in equipmentIds)
                  DropdownMenuItem(
                    value: id,
                    child: Text(equipmentLabel(l10n, id)),
                  ),
              ],
              onChanged: (value) => setState(() => _equipmentId = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.filterShowArchived),
              value: _includeArchived,
              onChanged: (value) => setState(() => _includeArchived = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.filterOnlyUserCreated),
              value: _onlyUserCreated,
              onChanged: (value) => setState(() => _onlyUserCreated = value),
            ),
            const SizedBox(height: 8),
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
    );
  }
}
