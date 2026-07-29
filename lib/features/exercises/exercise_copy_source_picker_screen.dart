import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/widgets/error_retry_state.dart';
import '../../domain/models/exercise_catalog_filter.dart';
import '../../l10n/app_localizations.dart';
import 'exercise_type_labels.dart';

/// "Скопировать из..." picker (S-08, Stage 10, owner-reported): pick an
/// existing exercise -- built-in or user-created alike ("копировать из
/// всех") -- to prefill the create-exercise form's fields from, so a user
/// who just wants a tweaked variant of something already in the catalog
/// doesn't have to fill every field from scratch. Same lightweight,
/// name-only search shape as `AddExerciseScreen`/`ExerciseProgressPickerScreen`
/// (no type/muscle/equipment filters -- those belong to the full S-06
/// catalog), but with no "create new" affordance of its own: picking one
/// pops it back to the caller, exactly like `AddExerciseScreen`'s own list
/// tap (not `ExerciseProgressPickerScreen`'s "push forward" shape).
class ExerciseCopySourcePickerScreen extends ConsumerStatefulWidget {
  const ExerciseCopySourcePickerScreen({super.key});

  @override
  ConsumerState<ExerciseCopySourcePickerScreen> createState() =>
      _ExerciseCopySourcePickerScreenState();
}

class _ExerciseCopySourcePickerScreenState
    extends ConsumerState<ExerciseCopySourcePickerScreen> {
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
      appBar: AppBar(title: Text(l10n.exerciseCopySourcePickerTitle)),
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
                      onTap: () => context.pop(exercise),
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
