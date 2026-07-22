import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/reference_data_ids.dart';
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
    super.dispose();
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
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) =>
                      _ExerciseListTile(exercise: exercises[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(l10n.exercisesLoadError)),
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

class _ExerciseListTile extends StatelessWidget {
  const _ExerciseListTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subtitleParts = [
      exerciseTypeLabel(l10n, exercise.exerciseType),
      if (exercise.primaryMuscleGroupId != null)
        muscleGroupLabel(l10n, exercise.primaryMuscleGroupId!),
    ];
    return ListTile(
      leading: Icon(exerciseTypeIcon(exercise.exerciseType)),
      title: Text(exercise.name),
      subtitle: Text(subtitleParts.join(' · ')),
      trailing: exercise.isArchived
          ? Chip(label: Text(l10n.exerciseArchivedBadge))
          : null,
      onTap: () => context.push('/exercises/${exercise.id}'),
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
