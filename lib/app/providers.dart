/// Single composition root for dependency injection (03_TECHNICAL_SPEC.md,
/// section 4). UI/services never construct `AppDatabase` or the
/// repository implementations directly — they depend on the interfaces
/// below, wired here.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../core/logger.dart';
import '../data/database.dart' as drift;
import '../data/repositories_impl/active_workout_repository_impl.dart';
import '../data/repositories_impl/app_settings_repository_impl.dart';
import '../data/repositories_impl/body_measurement_repository_impl.dart';
import '../data/repositories_impl/exercise_repository_impl.dart';
import '../data/repositories_impl/import_export_operation_repository_impl.dart';
import '../data/repositories_impl/measurement_type_repository_impl.dart';
import '../data/repositories_impl/personal_record_repository_impl.dart';
import '../data/repositories_impl/progression_repository_impl.dart';
import '../data/repositories_impl/workout_repository_impl.dart';
import '../data/repositories_impl/workout_tag_repository_impl.dart';
import '../data/repositories_impl/workout_template_repository_impl.dart';
import '../domain/enums.dart';
import '../domain/models/active_workout_state.dart';
import '../domain/models/app_settings.dart';
import '../domain/models/body_measurement.dart';
import '../domain/models/exercise.dart';
import '../domain/models/exercise_catalog_filter.dart';
import '../domain/models/exercise_history_entry.dart';
import '../domain/models/exercise_progression_state.dart';
import '../domain/models/import_export_operation.dart';
import '../domain/models/measurement_type.dart';
import '../domain/models/personal_record.dart';
import '../domain/models/template_details.dart';
import '../domain/models/template_list_entry.dart';
import '../domain/models/workout.dart';
import '../domain/models/workout_details.dart';
import '../domain/models/workout_history_entry.dart';
import '../domain/models/workout_history_filter.dart';
import '../domain/models/workout_period_stats.dart';
import '../domain/models/workout_tag.dart';
import '../domain/repositories/active_workout_repository.dart';
import '../domain/repositories/app_settings_repository.dart';
import '../domain/repositories/body_measurement_repository.dart';
import '../domain/repositories/exercise_repository.dart';
import '../domain/repositories/import_export_operation_repository.dart';
import '../domain/repositories/measurement_type_repository.dart';
import '../domain/repositories/personal_record_repository.dart';
import '../domain/repositories/progression_repository.dart';
import '../domain/repositories/workout_repository.dart';
import '../domain/repositories/workout_tag_repository.dart';
import '../domain/repositories/workout_template_repository.dart';
import '../features/template_editor/controller.dart';
import '../features/workout_editor/controller.dart';
import 'locale.dart';
import '../services/active_workout_timer_service.dart';
import '../services/app_settings_service.dart';
import '../services/body_measurement_service.dart';
import '../services/exercise_service.dart';
import '../services/export/export_service.dart';
import '../services/measurement_type_service.dart';
import '../services/notification_service.dart';
import '../services/progression_service.dart';
import '../services/records_service.dart';
import '../services/workout_service.dart';
import '../services/workout_tag_service.dart';
import '../services/workout_template_service.dart';

final loggerProvider = Provider<AppLogger>((ref) => AppLogger());

/// Rest-timer local notifications (Stage 4, TS 7.3, D-11). `main.dart`
/// overrides this with an already-`initialize()`d instance before `runApp`;
/// the default here (never `initialize()`d) is only a safe fallback so
/// widget tests that don't care about notifications — the vast majority —
/// don't need to override it themselves. Every call site wraps this in its
/// own try/catch, so an un-initialized plugin failing in a test is harmless.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(FlutterLocalNotificationsPlugin());
});

/// Drives the "Уведомления выключены" hint on the rest-timer bar (TS 7.3).
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  try {
    return await ref.watch(notificationServiceProvider).areNotificationsEnabled();
  } catch (_) {
    return true;
  }
});

final appDatabaseProvider = Provider<drift.AppDatabase>((ref) {
  final db = drift.AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(ref.watch(appDatabaseProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The workout currently `inProgress`, if any (TS 7.2 step 5) — drives the
/// "Тренировка продолжается" recovery banner on the tab shell.
final inProgressWorkoutProvider = StreamProvider<Workout?>((ref) {
  return ref.watch(workoutRepositoryProvider).watchInProgressWorkout();
});

/// The nearest upcoming `draft`/`planned` workout (S-01 "Сегодня" card,
/// Stage 9) — `DateTime.now()` is read once per provider rebuild, which is
/// fine since "today" doesn't change while the app stays open.
final nextUpcomingWorkoutProvider = StreamProvider<WorkoutHistoryEntry?>((
  ref,
) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchNextUpcomingWorkout(notBefore: DateTime.now());
});

/// One exercise's completed-workout history (S-07 "История" tab, Stage 9) —
/// `.autoDispose` since `exerciseId` varies per screen instance and this
/// would otherwise keep every exercise ever viewed cached for the rest of
/// the session. Previously a bare `FutureBuilder` inside the widget itself,
/// which re-created (and re-awaited) its future on every parent rebuild —
/// e.g. every time the card's own "⋮" menu triggered a `setState` a few
/// levels up — causing an avoidable loading-spinner flicker and repeat
/// query; a provider is cached by [exerciseId] instead, and `ref.invalidate`
/// gives the S-06 error state's "Повторить" button (04_UI_UX_SPEC.md,
/// section 6) something concrete to call.
final exerciseHistoryProvider = FutureProvider.autoDispose
    .family<List<ExerciseHistoryEntry>, String>((ref, exerciseId) {
      return ref.watch(workoutRepositoryProvider).getExerciseHistory(exerciseId);
    });

final progressionRepositoryProvider = Provider<ProgressionRepository>((ref) {
  return ProgressionRepositoryImpl(ref.watch(appDatabaseProvider));
});

final personalRecordRepositoryProvider = Provider<PersonalRecordRepository>((
  ref,
) {
  return PersonalRecordRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The cached personal records for one exercise (S-10 records list).
final personalRecordsForExerciseProvider = StreamProvider.family<
  List<PersonalRecord>,
  String
>((ref, exerciseId) {
  return ref
      .watch(personalRecordRepositoryProvider)
      .watchForExercise(exerciseId);
});

final importExportOperationRepositoryProvider =
    Provider<ImportExportOperationRepository>((ref) {
      return ImportExportOperationRepositoryImpl(ref.watch(appDatabaseProvider));
    });

/// S-16's operations journal, newest first.
final importExportOperationsProvider =
    StreamProvider<List<ImportExportOperation>>((ref) {
      return ref.watch(importExportOperationRepositoryProvider).watchAll();
    });

/// The Stage 8 CSV export pipeline (TS 10).
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(bodyMeasurementRepositoryProvider),
    ref.watch(measurementTypeRepositoryProvider),
    ref.watch(exerciseRepositoryProvider),
    ref.watch(importExportOperationRepositoryProvider),
  );
});

/// The D-7 stagnation-counter algorithm (03_TECHNICAL_SPEC.md, section 9.4).
final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(exerciseRepositoryProvider),
    ref.watch(progressionRepositoryProvider),
  );
});

/// The D-8 personal-record cache algorithm (03_TECHNICAL_SPEC.md, section 9).
final recordsServiceProvider = Provider<RecordsService>((ref) {
  return RecordsService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(exerciseRepositoryProvider),
    ref.watch(personalRecordRepositoryProvider),
  );
});

final activeWorkoutRepositoryProvider = Provider<ActiveWorkoutRepository>((ref) {
  return ActiveWorkoutRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The workout timer (03_TECHNICAL_SPEC.md, section 7.1).
final activeWorkoutTimerServiceProvider = Provider<ActiveWorkoutTimerService>((ref) {
  return ActiveWorkoutTimerService(ref.watch(activeWorkoutRepositoryProvider));
});

final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService(
    ref.watch(workoutRepositoryProvider),
    ref.watch(progressionServiceProvider),
    ref.watch(recordsServiceProvider),
    ref.watch(activeWorkoutTimerServiceProvider),
  );
});

final workoutTagRepositoryProvider = Provider<WorkoutTagRepository>((ref) {
  return WorkoutTagRepositoryImpl(ref.watch(appDatabaseProvider));
});

final workoutTagServiceProvider = Provider<WorkoutTagService>((ref) {
  return WorkoutTagService(ref.watch(workoutTagRepositoryProvider));
});

final workoutTemplateRepositoryProvider = Provider<WorkoutTemplateRepository>((ref) {
  return WorkoutTemplateRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// The single point of truth for template name validation (DM 6.8).
final workoutTemplateServiceProvider = Provider<WorkoutTemplateService>((ref) {
  return WorkoutTemplateService(ref.watch(workoutTemplateRepositoryProvider));
});

final appSettingsRepositoryProvider = Provider<AppSettingsRepository>((ref) {
  return AppSettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final appSettingsServiceProvider = Provider<AppSettingsService>((ref) {
  return AppSettingsService(ref.watch(appSettingsRepositoryProvider));
});

/// The single point of truth for the catalog's archive/delete rules and
/// exerciseType lock (DM 10, DM 6.1).
final exerciseServiceProvider = Provider<ExerciseService>((ref) {
  return ExerciseService(ref.watch(exerciseRepositoryProvider));
});

/// The current display language for `ExerciseL10n`-aware reads (Stage 10,
/// DM 12) — `resolvedLocaleCode` applied to `AppSettings.locale`, reactive
/// so switching the language on the fly (S-17) re-resolves exercise names
/// the same way it already does everything else. Falls back to
/// `AppLocale.system` while settings are still loading, same as
/// `GymLogApp`'s theme/locale defaults.
final effectiveLocaleProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider).value;
  return resolvedLocaleCode(settings?.locale ?? AppLocale.system);
});

/// The exercise catalog list (S-06), keyed by the active search/filters
/// (`emptyExerciseCatalogFilter` for "no filtering" — e.g. the add-exercise
/// picker in the workout editor, which doesn't have its own filter UI yet).
final exercisesListProvider = StreamProvider.family<
  List<Exercise>,
  ExerciseCatalogFilter
>((ref, filter) {
  final locale = ref.watch(effectiveLocaleProvider);
  return ref
      .watch(exerciseRepositoryProvider)
      .watchAll(filter: filter, locale: locale);
});

/// The history list (S-02), keyed by the active filters
/// (`emptyWorkoutHistoryFilter` for "the Stage 1 default" — completed only,
/// no other criteria — e.g. the copy-source picker, which always wants
/// exactly that regardless of History's own filter state).
final historyListProvider = StreamProvider.family<
  List<WorkoutHistoryEntry>,
  WorkoutHistoryFilter
>((ref, filter) {
  return ref.watch(workoutRepositoryProvider).watchHistory(filter: filter);
});

/// All non-deleted workout tags (S-03 tag picker).
final workoutTagsListProvider = StreamProvider<List<WorkoutTag>>((ref) {
  return ref.watch(workoutTagRepositoryProvider).watchAll();
});

/// The singleton app settings row — currently only `showTags` (Stage 3) has
/// a reader/writer; `AppSettingsRepositoryImpl.ensureInitialized` is called
/// once in `main.dart` before this is ever watched.
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(appSettingsRepositoryProvider).watchSettings();
});

/// The D-7 stagnation counter for one exercise (S-03 "N без роста" hint) —
/// `null` if it has no completed occurrences yet.
final progressionStateProvider = StreamProvider.family<
  ExerciseProgressionState?,
  String
>((ref, exerciseId) {
  return ref.watch(progressionRepositoryProvider).watchState(exerciseId);
});

/// The workout editor (S-03) controller, one instance per workout. Owns the
/// autosave debounce (TS 5) and the in-progress/completed transitions
/// (`workout_service`); disposed when the editor screen is popped.
final workoutEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<WorkoutEditorController, AsyncValue<WorkoutDetails>, String>((
      ref,
      workoutId,
    ) {
      final locale = ref.watch(effectiveLocaleProvider);
      return WorkoutEditorController(
        workoutId,
        ref.read(workoutRepositoryProvider),
        ref.read(workoutServiceProvider),
        ref.read(progressionServiceProvider),
        ref.read(recordsServiceProvider),
        ref.read(activeWorkoutTimerServiceProvider),
        ref.read(appSettingsRepositoryProvider),
        ref.read(loggerProvider),
        locale: locale,
      );
    });

/// The workout timer's live state (TS 7.1), keyed by workout id — `null`
/// while the workout isn't `inProgress` (no row exists, DM 6.14).
final activeWorkoutStateProvider = StreamProvider.family<ActiveWorkoutState?, String>((
  ref,
  workoutId,
) {
  return ref.watch(activeWorkoutRepositoryProvider).watch(workoutId);
});

/// The template list (S-12), archived hidden by default
/// (`ASSUMPTION(templates-hide-archived-by-default)`, Stage 5).
final templateListProvider = StreamProvider.family<List<TemplateListEntry>, bool>((
  ref,
  includeArchived,
) {
  return ref
      .watch(workoutTemplateRepositoryProvider)
      .watchAllWithExerciseCount(includeArchived: includeArchived);
});

/// The template editor (S-13) controller, one instance per template.
final templateEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<TemplateEditorController, AsyncValue<TemplateDetails>, String>((
      ref,
      templateId,
    ) {
      final locale = ref.watch(effectiveLocaleProvider);
      return TemplateEditorController(
        templateId,
        ref.read(workoutTemplateRepositoryProvider),
        ref.read(loggerProvider),
        locale: locale,
      );
    });

final measurementTypeRepositoryProvider = Provider<MeasurementTypeRepository>((
  ref,
) {
  return MeasurementTypeRepositoryImpl(ref.watch(appDatabaseProvider));
});

final bodyMeasurementRepositoryProvider = Provider<BodyMeasurementRepository>((
  ref,
) {
  return BodyMeasurementRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// Built-in + user-created measurement types (S-14 tabs), archived hidden by
/// default — same convention as [exercisesListProvider]/[templateListProvider].
final measurementTypesListProvider = StreamProvider.family<
  List<MeasurementType>,
  bool
>((ref, includeArchived) {
  return ref
      .watch(measurementTypeRepositoryProvider)
      .watchAll(includeArchived: includeArchived);
});

/// One measurement type's entries, newest date first (S-14 list + graph).
final bodyMeasurementsByTypeProvider = StreamProvider.family<
  List<BodyMeasurement>,
  String
>((ref, measurementTypeId) {
  return ref
      .watch(bodyMeasurementRepositoryProvider)
      .watchByType(measurementTypeId);
});

/// One measurement type's entries within a period (S-09's per-chart period
/// filter, TS 9). The record key relies on Dart records' structural
/// equality to work as a Riverpod family parameter. `autoDispose`: unlike
/// [bodyMeasurementsByTypeProvider], every period a user picks would
/// otherwise mint a permanently-cached subscription that's never released
/// (S-09 has several independently period-switchable charts on screen at
/// once) — this drops a period's drift `.watch()` subscription as soon as
/// nothing is displaying it anymore.
final bodyMeasurementsInRangeProvider = StreamProvider.autoDispose.family<
  List<BodyMeasurement>,
  ({String measurementTypeId, DateTime? from, DateTime? to})
>((ref, params) {
  return ref
      .watch(bodyMeasurementRepositoryProvider)
      .watchByType(params.measurementTypeId, from: params.from, to: params.to);
});

/// S-09 "Тренировки" card figures for a period (TS 9: count + tonnage;
/// frequency is derived from the period's own length, computed UI-side).
/// `autoDispose` for the same reason as [bodyMeasurementsInRangeProvider] —
/// this card has its own independent period switcher.
final workoutPeriodStatsProvider = StreamProvider.autoDispose.family<
  WorkoutPeriodStats,
  ({DateTime? from, DateTime? to})
>((ref, params) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchPeriodStats(from: params.from, to: params.to);
});

/// The single point of truth for custom measurement type name validation
/// and DM 10 archive/delete rules.
final measurementTypeServiceProvider = Provider<MeasurementTypeService>((
  ref,
) {
  return MeasurementTypeService(ref.watch(measurementTypeRepositoryProvider));
});

/// The single point of truth for measurement value range validation (DM
/// 6.9, by `unitKind`).
final bodyMeasurementServiceProvider = Provider<BodyMeasurementService>((
  ref,
) {
  return BodyMeasurementService(
    ref.watch(bodyMeasurementRepositoryProvider),
    ref.watch(measurementTypeRepositoryProvider),
  );
});
