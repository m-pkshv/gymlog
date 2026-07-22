import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/date_format.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/exercise.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_set_format.dart';
import 'exercise_type_labels.dart';
import 'reference_data_labels.dart';

/// S-07 exercise card, Stage 2 scope: image placeholder, name/type/
/// muscles/equipment/description, YouTube link (shown as plain text — the
/// owner decided against adding `url_launcher` for now, so there is no
/// "open in browser" button yet), "About"/"История" tabs. The "Рекорды" tab
/// arrives in Stage 7 with `records_service`/`PersonalRecord`. "Edit" opens
/// `CreateExerciseScreen` in edit mode; only offered for user-created
/// exercises (built-in ones can only be archived, DM 10).
class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends ConsumerState<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Exercise? _exercise;
  bool _isLoading = true;
  bool _loadError = false;
  bool _canDelete = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final exercise = await ref
          .read(exerciseRepositoryProvider)
          .getById(widget.exerciseId);
      final canDelete = exercise == null
          ? false
          : await ref.read(exerciseServiceProvider).canDelete(exercise);
      if (!mounted) return;
      setState(() {
        _exercise = exercise;
        _canDelete = canDelete;
        _isLoading = false;
        _loadError = exercise == null;
      });
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .error(
            'Failed to load exercise ${widget.exerciseId}',
            error: error,
            stackTrace: stackTrace,
          );
      // Without clearing _isLoading here, the body's `_isLoading ? spinner :
      // ...` check never reaches the error branch at all -- a load failure
      // would spin forever instead of showing "Не удалось загрузить".
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      }
    }
  }

  Future<void> _edit() async {
    final exercise = _exercise;
    if (exercise == null || _isBusy) return;
    final updated = await context.push<Exercise>(
      '/exercises/${exercise.id}/edit',
      extra: exercise,
    );
    if (updated != null && mounted) {
      setState(() => _exercise = updated);
    }
  }

  Future<void> _archive({required bool archived}) async {
    final exercise = _exercise;
    if (exercise == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isBusy = true);
    final service = ref.read(exerciseServiceProvider);
    final result = archived
        ? await service.archive(exercise)
        : await service.unarchive(exercise);
    if (!mounted) return;
    result.fold((updated) => setState(() => _exercise = updated), (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.archiveExerciseError)));
    });
    setState(() => _isBusy = false);
  }

  Future<void> _confirmDelete() async {
    final exercise = _exercise;
    if (exercise == null || _isBusy) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteExerciseConfirmTitle),
        content: Text(l10n.deleteExerciseConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.deleteExerciseAction,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    final result = await ref.read(exerciseServiceProvider).delete(exercise);
    if (!mounted) return;
    result.fold((_) => context.pop(), (_) {
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteExerciseError)));
    });
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
        actions: exercise == null
            ? null
            : [
                PopupMenuButton<_ExerciseAction>(
                  enabled: !_isBusy,
                  onSelected: (action) {
                    switch (action) {
                      case _ExerciseAction.edit:
                        _edit();
                      case _ExerciseAction.archive:
                        _archive(archived: true);
                      case _ExerciseAction.unarchive:
                        _archive(archived: false);
                      case _ExerciseAction.delete:
                        _confirmDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    if (!exercise.isBuiltIn)
                      PopupMenuItem(
                        value: _ExerciseAction.edit,
                        child: Text(l10n.editExerciseAction),
                      ),
                    PopupMenuItem(
                      value: exercise.isArchived
                          ? _ExerciseAction.unarchive
                          : _ExerciseAction.archive,
                      child: Text(
                        exercise.isArchived
                            ? l10n.unarchiveExerciseAction
                            : l10n.archiveExerciseAction,
                      ),
                    ),
                    if (_canDelete)
                      PopupMenuItem(
                        value: _ExerciseAction.delete,
                        child: Text(l10n.deleteExerciseAction),
                      ),
                  ],
                ),
              ],
        bottom: exercise == null
            ? null
            : TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.exerciseAboutTab),
                  Tab(text: l10n.exerciseHistoryTab),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError || exercise == null
          ? ErrorRetryState(
              message: l10n.exerciseDetailLoadError,
              onRetry: _load,
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(exercise: exercise),
                _HistoryTab(exercise: exercise),
              ],
            ),
    );
  }
}

enum _ExerciseAction { edit, archive, unarchive, delete }

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            // Built-in exercises get a real image once the full seed
            // pipeline lands (D-3); until then, and always for
            // user-created ones, this placeholder icon stands in.
            child: exercise.imageAsset != null
                ? ClipOval(child: Image.asset(exercise.imageAsset!))
                : Icon(
                    exerciseTypeIcon(exercise.exerciseType),
                    size: 56,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
        if (exercise.isArchived) ...[
          const SizedBox(height: 12),
          Center(
            child: Chip(label: Text(l10n.exerciseArchivedBadge)),
          ),
        ],
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(exerciseTypeIcon(exercise.exerciseType)),
          title: Text(exerciseTypeLabel(l10n, exercise.exerciseType)),
          subtitle: Text(l10n.exerciseTypeLabel),
        ),
        if (exercise.primaryMuscleGroupId != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              muscleGroupLabel(l10n, exercise.primaryMuscleGroupId!),
            ),
            subtitle: Text(l10n.exercisePrimaryMuscleLabel),
          ),
        if (exercise.secondaryMuscleGroupIds.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              exercise.secondaryMuscleGroupIds
                  .map((id) => muscleGroupLabel(l10n, id))
                  .join(', '),
            ),
            subtitle: Text(l10n.exerciseSecondaryMusclesLabel),
          ),
        if (exercise.equipmentId != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(equipmentLabel(l10n, exercise.equipmentId!)),
            subtitle: Text(l10n.exerciseEquipmentLabel),
          ),
        if (exercise.description != null &&
            exercise.description!.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(exercise.description!),
            subtitle: Text(l10n.exerciseDescriptionLabel),
          ),
        if (exercise.youtubeUrl != null && exercise.youtubeUrl!.isNotEmpty)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.smart_display_outlined),
            title: Text(exercise.youtubeUrl!),
            subtitle: Text(l10n.exerciseYoutubeUrlLabel),
          ),
      ],
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(exerciseHistoryProvider(exercise.id));

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => ErrorRetryState(
        message: l10n.exerciseDetailLoadError,
        onRetry: () => ref.invalidate(exerciseHistoryProvider(exercise.id)),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return Center(child: Text(l10n.exerciseHistoryEmpty));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(formatShortDate(entry.workout.date)),
                subtitle: Text(
                  entry.sets
                      .map(
                        (set) => formatSetSummary(set, exercise.exerciseType),
                      )
                      .join(', '),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
