import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/exercise_catalog_filter.dart';
import '../../l10n/app_localizations.dart';
import '../exercises/exercise_type_labels.dart';

/// Search-only exercise picker that leads into S-10 (04_UI_UX_SPEC.md,
/// section 5: "«Прогресс по упражнению» (поиск упражнения → S-10)"). No
/// type/muscle/equipment filters -- those belong to the full S-06 catalog
/// screen, not this lightweight lookup. Archived exercises are hidden by
/// default, the same as every other catalog picker in the app
/// (`emptyExerciseCatalogFilter`, e.g. `AddExerciseScreen`). Tapping a
/// result pushes forward to the progress screen rather than popping a
/// result back -- this isn't a "pick one for the caller" flow.
class ExerciseProgressPickerScreen extends ConsumerStatefulWidget {
  const ExerciseProgressPickerScreen({super.key});

  @override
  ConsumerState<ExerciseProgressPickerScreen> createState() =>
      _ExerciseProgressPickerScreenState();
}

class _ExerciseProgressPickerScreenState
    extends ConsumerState<ExerciseProgressPickerScreen> {
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ExerciseCatalogFilter filter = (
      query: _searchController.text.trim(),
      type: null,
      muscleGroupId: null,
      equipmentId: null,
      includeArchived: false,
      onlyUserCreated: false,
    );
    final exercisesAsync = ref.watch(exercisesListProvider(filter));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exerciseProgressPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
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
                  return Center(
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? l10n.exercisesEmptyTitle
                          : l10n.exercisesSearchEmptyTitle,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      leading: Icon(exerciseTypeIcon(exercise.exerciseType)),
                      title: Text(exercise.name),
                      subtitle: Text(
                        exerciseTypeLabel(l10n, exercise.exerciseType),
                      ),
                      onTap: () =>
                          context.push('/stats/exercise/${exercise.id}'),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => ErrorRetryState(
                message: l10n.exercisesLoadError,
                onRetry: () => ref.invalidate(exercisesListProvider(filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
