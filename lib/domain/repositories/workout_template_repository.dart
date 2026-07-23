import '../models/template_details.dart';
import '../models/template_exercise.dart';
import '../models/template_list_entry.dart';
import '../models/template_set.dart';
import '../models/workout_template.dart';

/// Storage contract for the template aggregate — `WorkoutTemplate` +
/// `TemplateExercise` + `TemplateSet` (06_DATA_MODEL.md, section 6.8, D-16).
/// Implemented in the Data layer (D-13); services/UI depend only on this
/// interface, never on `AppDatabase` directly. Name-length validation (DM
/// 6.8) is `WorkoutTemplateService`'s job, not this contract's.
abstract class WorkoutTemplateRepository {
  /// Non-deleted templates, most recently created first (S-12). Archived
  /// templates are excluded unless [includeArchived] — same default as the
  /// exercise catalog (S-06).
  Stream<List<WorkoutTemplate>> watchAll({bool includeArchived = false});

  /// Same set as [watchAll], each with its exercise count (S-12 list card:
  /// "имя, число упражнений") — a SQL aggregate (TS 11.6), not fetched and
  /// counted in Dart.
  Stream<List<TemplateListEntry>> watchAllWithExerciseCount({
    bool includeArchived = false,
  });

  /// [locale] (`'ru'`/`'en'`, from `resolvedLocaleCode`) resolves each
  /// embedded exercise's name/description against `ExerciseL10n` (DM 12)
  /// when a translation exists; omitted (`null`) returns canonical text.
  Future<TemplateDetails?> getDetails(String templateId, {String? locale});

  Future<WorkoutTemplate> create({required String name, String? comment});

  /// "Создать шаблон" (S-02/S-03 workout action, TS 8 section 8): copies
  /// [workoutId]'s non-deleted exercises (order + `WorkoutExercise.comment`)
  /// and each set's planned values into a
  /// brand-new template named [name]. Facts, completion, and the source
  /// workout's own comment are never copied — `TemplateSet` has no fact
  /// fields at all (DM 6.8), and the workout-level comment follows the same
  /// "starts blank" precedent `copyWorkout` already established for
  /// workout-to-workout copies (Stage 3). Throws `ArgumentError` if
  /// [workoutId] doesn't exist.
  Future<WorkoutTemplate> createFromWorkout({
    required String workoutId,
    required String name,
  });

  /// "Дублировать" (S-12 card menu, 04_UI_UX_SPEC.md section 5): full
  /// within-aggregate clone of [templateId] — every `TemplateExercise`
  /// (order + comment) and `TemplateSet` (all planned fields, `side`),
  /// plus the source template's own comment, into a brand-new,
  /// never-archived template named [name] (04/TS 8 don't detail field
  /// copying for "duplicate" the way they do for the cross-aggregate
  /// workout<->template copies, so everything is copied 1:1 — this isn't a
  /// conversion between different kinds of data like those, just a clone).
  /// Throws `ArgumentError` if [templateId] doesn't exist.
  Future<WorkoutTemplate> duplicate({
    required String templateId,
    required String name,
  });

  /// Persists template-level field changes (name, comment, archived).
  Future<void> update(WorkoutTemplate template);

  Future<TemplateExercise> addExercise({
    required String templateId,
    required String exerciseId,
  });

  /// Persists `TemplateExercise`-level field changes — the comment autosave
  /// write (S-13, mirrors S-03's TS 5 contract).
  Future<void> updateTemplateExercise(TemplateExercise templateExercise);

  Future<TemplateSet> addSet({required String templateExerciseId});

  /// Persists set field changes — the autosave write (S-13, TS 5).
  Future<void> updateTemplateSet(TemplateSet set);

  /// Reorder (S-13, same drag handle + "⋮ → Вверх/Вниз" as S-03): rewrites
  /// `orderIndex` so it matches each id's position in
  /// [orderedTemplateExerciseIds].
  Future<void> reorderExercises({
    required String templateId,
    required List<String> orderedTemplateExerciseIds,
  });

  /// Soft-deletes [templateId] (S-12 "⋮ → Удалить", D-19): marks the
  /// template and every one of its non-deleted `TemplateExercise`/
  /// `TemplateSet` rows `isDeleted = true`, in one transaction.
  Future<void> deleteTemplate(String templateId);

  /// Reverses [deleteTemplate] within the DM 10 Undo window: un-marks
  /// `isDeleted` on the template and the same `TemplateExercise`/
  /// `TemplateSet` rows it cascaded to.
  Future<void> restoreTemplate(String templateId);
}
