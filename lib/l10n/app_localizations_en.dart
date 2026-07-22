// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GymLog';

  @override
  String get tabToday => 'Today';

  @override
  String get tabHistory => 'History';

  @override
  String get tabExercises => 'Exercises';

  @override
  String get tabStats => 'Stats';

  @override
  String get tabMore => 'More';

  @override
  String get exercisesEmptyTitle => 'No exercises yet';

  @override
  String get exercisesLoadError => 'Couldn\'t load exercises';

  @override
  String get createExerciseAction => 'Create exercise';

  @override
  String get createExerciseTitle => 'New exercise';

  @override
  String get exerciseNameLabel => 'Name';

  @override
  String get exerciseNameRequiredError => 'Enter a name';

  @override
  String get exerciseTypeLabel => 'Type';

  @override
  String get exerciseTypeStrength => 'Strength';

  @override
  String get exerciseTypeCardio => 'Cardio';

  @override
  String get exerciseTypeReps => 'Reps';

  @override
  String get exerciseTypeTime => 'Time';

  @override
  String get exerciseTypeStretch => 'Stretch';

  @override
  String get createExerciseError => 'Couldn\'t create the exercise';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get newWorkoutAction => 'New workout';

  @override
  String get workoutEditorTitle => 'Workout';

  @override
  String get workoutLoadError => 'Couldn\'t load the workout';

  @override
  String get workoutStatusChangeError => 'Couldn\'t update the workout';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPlanned => 'Planned';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get transitionScheduleAction => 'Schedule';

  @override
  String get transitionResumeAction => 'Resume';

  @override
  String get transitionCancelAction => 'Cancel';

  @override
  String get transitionSkipAction => 'Skip';

  @override
  String get transitionBackToPlanAction => 'Back to planned';

  @override
  String get transitionBackToDraftAction => 'Back to draft';

  @override
  String get activeWorkoutConflictTitle => 'A workout is already in progress';

  @override
  String get activeWorkoutConflictMessage =>
      'Only one workout can be in progress at a time. Finish or cancel the current one first.';

  @override
  String get activeWorkoutConflictCancelOtherAction => 'Cancel it';

  @override
  String get activeWorkoutConflictFinishOtherAction => 'Finish it';

  @override
  String get startWorkoutAction => 'Start workout';

  @override
  String get finishWorkoutAction => 'Finish';

  @override
  String get addExerciseAction => 'Add exercise';

  @override
  String get addSetAction => 'Add set';

  @override
  String get workoutExercisesEmpty => 'No exercises added yet';

  @override
  String get setColumnNumber => '#';

  @override
  String get setColumnWarmup => 'Warm-up';

  @override
  String get setColumnPlan => 'Plan';

  @override
  String get setColumnFact => 'Fact';

  @override
  String get setColumnDone => 'Done';

  @override
  String get setFieldWeightKg => 'Weight, kg';

  @override
  String get setFieldReps => 'Reps';

  @override
  String get setFieldDistanceKm => 'Distance, km';

  @override
  String get setFieldDurationSec => 'Duration, s';

  @override
  String get historyEmptyTitle => 'No completed workouts yet';

  @override
  String get historyLoadError => 'Couldn\'t load history';

  @override
  String get workoutDefaultNamePrefix => 'Workout';

  @override
  String workoutExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String workoutDurationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get muscleGroupChest => 'Chest';

  @override
  String get muscleGroupBack => 'Back';

  @override
  String get muscleGroupShoulders => 'Shoulders';

  @override
  String get muscleGroupRearDelts => 'Rear Delts';

  @override
  String get muscleGroupBiceps => 'Biceps';

  @override
  String get muscleGroupTriceps => 'Triceps';

  @override
  String get muscleGroupForearms => 'Forearms';

  @override
  String get muscleGroupAbs => 'Abs';

  @override
  String get muscleGroupObliques => 'Obliques';

  @override
  String get muscleGroupHipFlexors => 'Hip Flexors';

  @override
  String get muscleGroupGlutes => 'Glutes';

  @override
  String get muscleGroupQuads => 'Quads';

  @override
  String get muscleGroupAdductors => 'Adductors';

  @override
  String get muscleGroupHamstrings => 'Hamstrings';

  @override
  String get muscleGroupCalves => 'Calves';

  @override
  String get muscleGroupFullBody => 'Full body';

  @override
  String get muscleGroupCardioSystem => 'Cardio';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentCable => 'Cable machine';

  @override
  String get equipmentBodyweight => 'Bodyweight';

  @override
  String get equipmentBand => 'Resistance band';

  @override
  String get equipmentCardioMachine => 'Cardio machine';

  @override
  String get equipmentOther => 'Other';

  @override
  String get effortMetricNone => 'None';

  @override
  String get effortMetricRpe => 'RPE';

  @override
  String get effortMetricRir => 'RIR';

  @override
  String get exercisePrimaryMuscleLabel => 'Primary muscle';

  @override
  String get exerciseSecondaryMusclesLabel => 'Secondary muscles';

  @override
  String get exerciseEquipmentLabel => 'Equipment';

  @override
  String get exerciseEffortMetricLabel => 'Effort metric';

  @override
  String get exerciseDescriptionLabel => 'Description';

  @override
  String get exerciseYoutubeUrlLabel => 'YouTube link';

  @override
  String get exerciseYoutubeUrlWarning => 'Doesn\'t look like a YouTube link';

  @override
  String get exerciseNotSpecified => 'Not specified';

  @override
  String get exerciseDetailLoadError => 'Couldn\'t load the exercise';

  @override
  String get exerciseAboutTab => 'About';

  @override
  String get exerciseHistoryTab => 'History';

  @override
  String get exerciseHistoryEmpty =>
      'No completed workouts with this exercise yet';

  @override
  String get exerciseArchivedBadge => 'Archived';

  @override
  String get archiveExerciseAction => 'Archive';

  @override
  String get unarchiveExerciseAction => 'Unarchive';

  @override
  String get deleteExerciseAction => 'Delete';

  @override
  String get deleteExerciseConfirmTitle => 'Delete this exercise?';

  @override
  String get deleteExerciseConfirmMessage => 'This can\'t be undone.';

  @override
  String get deleteExerciseError => 'Couldn\'t delete the exercise';

  @override
  String get archiveExerciseError => 'Couldn\'t update the exercise';

  @override
  String get editExerciseTitle => 'Edit exercise';

  @override
  String get editExerciseAction => 'Edit';

  @override
  String get editExerciseError => 'Couldn\'t save the exercise';

  @override
  String get actionSave => 'Save';

  @override
  String get exerciseTypeLockedHint =>
      'Can\'t be changed: this exercise already has logged sets';

  @override
  String get searchExercisesHint => 'Search by name';

  @override
  String get filterExercisesTooltip => 'Filters';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filterAnyType => 'Any type';

  @override
  String get filterMuscleGroupLabel => 'Muscle group';

  @override
  String get filterAnyMuscleGroup => 'Any muscle group';

  @override
  String get filterAnyEquipment => 'Any equipment';

  @override
  String get filterShowArchived => 'Show archived';

  @override
  String get filterOnlyUserCreated => 'User-created only';

  @override
  String get filterResetAction => 'Reset';

  @override
  String get filterApplyAction => 'Apply';

  @override
  String get exercisesSearchEmptyTitle => 'No matches found';

  @override
  String get resetFiltersAction => 'Reset filters';

  @override
  String get pastResultsAction => 'Past results';

  @override
  String get pastResultsTitle => 'Past results';

  @override
  String get pastResultsEmpty =>
      'No completed occurrences of this exercise yet';

  @override
  String get pastResultsLoadError => 'Couldn\'t load past results';

  @override
  String get copyLastPerformanceAction => 'Copy last performance';

  @override
  String get copyLastPerformanceEmpty => 'No past results to copy yet';

  @override
  String get workoutTagsAddAction => 'Add tag';

  @override
  String get workoutTagsSheetTitle => 'Workout tags';

  @override
  String get workoutTagsEmpty => 'No tags yet';

  @override
  String get workoutTagsLoadError => 'Couldn\'t load tags';

  @override
  String get createTagAction => 'Create tag';

  @override
  String get createTagTitle => 'New tag';

  @override
  String get createTagError => 'Couldn\'t create the tag';

  @override
  String get tagNameLabel => 'Name';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsShowTagsLabel => 'Show tags';

  @override
  String get settingsUnitSystemLabel => 'Imperial units';

  @override
  String get settingsUnitSystemMetric => 'Metric (kg, cm)';

  @override
  String get settingsUnitSystemImperial => 'Imperial (lb, in)';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsRestTimerLabel => 'Default rest timer (sec)';

  @override
  String get settingsRestTimerRangeError =>
      'Enter a value from 10 to 600 seconds';

  @override
  String get settingsRestTimerAutoStartLabel => 'Auto-start rest timer';

  @override
  String get settingsNotificationsLabel => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Enabled';

  @override
  String get settingsNotificationsDisabled => 'Disabled';

  @override
  String get settingsNotificationsOpenSettingsAction => 'Settings';

  @override
  String get settingsNotificationsOpenSettingsError =>
      'Couldn\'t open system settings';

  @override
  String get settingsLoadError => 'Couldn\'t load settings';

  @override
  String get copyWorkoutAction => 'Copy';

  @override
  String get copyWorkoutError => 'Couldn\'t copy the workout';

  @override
  String get newWorkoutFromScratchAction => 'From scratch';

  @override
  String get newWorkoutFromCopyAction => 'From a copy';

  @override
  String get newWorkoutFromTemplateAction => 'From a template';

  @override
  String get copySourcePickerTitle => 'Copy from...';

  @override
  String get copySourcePickerEmpty => 'No completed workouts to copy from yet';

  @override
  String get filterWorkoutsTooltip => 'Filters';

  @override
  String get searchHistoryHint => 'Search by name';

  @override
  String get filterDateFromLabel => 'From';

  @override
  String get filterDateToLabel => 'To';

  @override
  String get filterAnyDate => 'Any date';

  @override
  String get filterStatusesLabel => 'Statuses';

  @override
  String get filterTagsLabel => 'Tags';

  @override
  String get historySearchEmptyTitle => 'No matches found';

  @override
  String get moveExerciseUpAction => 'Move up';

  @override
  String get moveExerciseDownAction => 'Move down';

  @override
  String get workoutCommentLabel => 'Comment';

  @override
  String get exerciseCommentLabel => 'Comment';

  @override
  String get setCommentAction => 'Comment';

  @override
  String get setCommentTitle => 'Set comment';

  @override
  String get setCommentLabel => 'Comment';

  @override
  String get deleteWorkoutAction => 'Delete';

  @override
  String get workoutDeletedMessage => 'Workout deleted';

  @override
  String get undoAction => 'Undo';

  @override
  String get deleteWorkoutError => 'Couldn\'t delete the workout';

  @override
  String get progressionDecisionLabel => 'Progression:';

  @override
  String get progressionDecisionNone => '—';

  @override
  String get progressionDecisionIncrease => '↑';

  @override
  String get progressionDecisionRepeat => '=';

  @override
  String get progressionDecisionDecrease => '↓';

  @override
  String stagnationHint(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts without growth',
      one: '$count workout without growth',
    );
    return '$_temp0';
  }

  @override
  String get historyViewCalendarTooltip => 'Calendar view';

  @override
  String get historyViewListTooltip => 'List view';

  @override
  String get historyCalendarDayEmpty => 'No workouts this day';

  @override
  String get workoutTimerPauseAction => 'Pause';

  @override
  String get workoutTimerResumeAction => 'Resume';

  @override
  String get restTimerLabel => 'Rest';

  @override
  String get restTimerMinus15Tooltip => '-15 s';

  @override
  String get restTimerPlus15Tooltip => '+15 s';

  @override
  String get restTimerSkipAction => 'Skip';

  @override
  String workoutContinuingBannerMessage(int minutes) {
    return 'Workout in progress, $minutes min';
  }

  @override
  String get continueWorkoutAction => 'Continue';

  @override
  String get finishWithIncompleteSetsTitle => 'Finish workout?';

  @override
  String get finishWithIncompleteSetsMessage =>
      'Mark the remaining sets as not completed and finish?';

  @override
  String get notificationPermissionRationaleTitle => 'Enable notifications?';

  @override
  String get notificationPermissionRationaleMessage =>
      'Get notified when your rest between sets is over, even if the app is in the background.';

  @override
  String get notificationPermissionNotNowAction => 'Not now';

  @override
  String get notificationPermissionAllowAction => 'Allow';

  @override
  String get restTimerNotificationTitle => 'Rest timer';

  @override
  String get restTimerNotificationBody => 'Rest is over — next set';

  @override
  String get notificationsOffHint => 'Notifications are off';

  @override
  String get workoutSummaryTitle => 'Workout summary';

  @override
  String get workoutSummaryDurationLabel => 'Duration';

  @override
  String get workoutSummaryExercisesLabel => 'Exercises';

  @override
  String get workoutSummarySetsLabel => 'Sets';

  @override
  String get workoutSummaryTonnageLabel => 'Tonnage';

  @override
  String workoutSummaryTonnageValue(String value) {
    return '$value kg';
  }

  @override
  String get workoutSummaryNewRecordsTitle => 'New records';

  @override
  String get workoutSummaryDoneAction => 'Done';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesEmptyTitle => 'No templates yet';

  @override
  String get templatesLoadError => 'Couldn\'t load templates';

  @override
  String templateExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '$count exercise',
    );
    return '$_temp0';
  }

  @override
  String get createTemplateAction => 'Create template';

  @override
  String get createTemplateTitle => 'New template';

  @override
  String get createTemplateError => 'Couldn\'t create the template';

  @override
  String get templateNameLabel => 'Name';

  @override
  String get templateEditorTitle => 'Template';

  @override
  String get templateCommentLabel => 'Comment';

  @override
  String get templateLoadError => 'Couldn\'t load the template';

  @override
  String get templateExercisesEmpty => 'No exercises yet';

  @override
  String get archiveTemplateAction => 'Archive';

  @override
  String get unarchiveTemplateAction => 'Unarchive';

  @override
  String get archiveTemplateError => 'Couldn\'t update the template';

  @override
  String get deleteTemplateAction => 'Delete';

  @override
  String get templateDeletedMessage => 'Template deleted';

  @override
  String get deleteTemplateError => 'Couldn\'t delete the template';

  @override
  String get createTemplateFromWorkoutAction => 'Create template';

  @override
  String get createWorkoutFromTemplateAction => 'Create workout';

  @override
  String get createWorkoutFromTemplateError => 'Couldn\'t create the workout';

  @override
  String get templateSourcePickerTitle => 'Create from template...';

  @override
  String get templateSourcePickerEmpty =>
      'No templates to create a workout from yet';

  @override
  String get duplicateTemplateAction => 'Duplicate';

  @override
  String get duplicateTemplateTitle => 'Duplicate template';

  @override
  String get measurementsTitle => 'Measurements';

  @override
  String get measurementTypeBodyWeight => 'Body weight';

  @override
  String get measurementTypeBodyFat => 'Body fat %';

  @override
  String get measurementTypeNeck => 'Neck';

  @override
  String get measurementTypeShouldersGirth => 'Shoulders';

  @override
  String get measurementTypeChestGirth => 'Chest';

  @override
  String get measurementTypeWaist => 'Waist';

  @override
  String get measurementTypeHips => 'Hips';

  @override
  String get measurementTypeBicepsLeft => 'Biceps (left)';

  @override
  String get measurementTypeBicepsRight => 'Biceps (right)';

  @override
  String get measurementTypeForearmLeft => 'Forearm (left)';

  @override
  String get measurementTypeForearmRight => 'Forearm (right)';

  @override
  String get measurementTypeThighLeft => 'Thigh (left)';

  @override
  String get measurementTypeThighRight => 'Thigh (right)';

  @override
  String get measurementTypeCalfLeft => 'Calf (left)';

  @override
  String get measurementTypeCalfRight => 'Calf (right)';

  @override
  String get measurementUnitKindMass => 'Weight (kg/lb)';

  @override
  String get measurementUnitKindPercent => 'Percent (%)';

  @override
  String get measurementUnitKindLength => 'Length (cm/in)';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitCm => 'cm';

  @override
  String get unitIn => 'in';

  @override
  String get measurementsTabWeight => 'Weight';

  @override
  String get measurementsTabBodyFat => 'Body fat';

  @override
  String get measurementsTabMeasurements => 'Measurements';

  @override
  String get measurementsTabCustom => 'Custom';

  @override
  String get measurementsEmptyState => 'No entries yet';

  @override
  String get measurementsLoadError => 'Couldn\'t load measurements';

  @override
  String get measurementGirthSelectorLabel => 'Measurement';

  @override
  String get addCustomMeasurementTypeAction => 'Add custom measurement…';

  @override
  String get measurementsCustomEmptyState => 'No custom measurement types yet';

  @override
  String get createMeasurementTypeTitle => 'New measurement type';

  @override
  String get measurementTypeNameLabel => 'Name';

  @override
  String get measurementTypeUnitKindLabel => 'Unit';

  @override
  String get createMeasurementTypeError =>
      'Couldn\'t create the measurement type';

  @override
  String get archiveMeasurementTypeAction => 'Archive';

  @override
  String get unarchiveMeasurementTypeAction => 'Unarchive';

  @override
  String get archiveMeasurementTypeError =>
      'Couldn\'t update the measurement type';

  @override
  String get deleteMeasurementTypeAction => 'Delete';

  @override
  String get deleteMeasurementTypeError =>
      'Couldn\'t delete the measurement type';

  @override
  String get deleteMeasurementTypeConfirmTitle => 'Delete measurement type?';

  @override
  String get deleteMeasurementTypeConfirmMessage =>
      'This will permanently delete this measurement type. This can\'t be undone.';

  @override
  String get measurementEntryDeletedMessage => 'Measurement deleted';

  @override
  String get deleteMeasurementEntryAction => 'Delete';

  @override
  String get measurementFormTitle => 'Log measurement';

  @override
  String get measurementTypeFieldLabel => 'Type';

  @override
  String get measurementDateFieldLabel => 'Date';

  @override
  String get measurementValueFieldLabel => 'Value';

  @override
  String get measurementCommentFieldLabel => 'Comment';

  @override
  String get measurementValueRequiredError => 'Enter a value';

  @override
  String get saveMeasurementError => 'Couldn\'t save the measurement';

  @override
  String get replaceMeasurementConfirmTitle => 'Replace existing value?';

  @override
  String replaceMeasurementConfirmMessage(String value, String unit) {
    return 'There\'s already an entry for this day: $value $unit. Replace it with the new value?';
  }

  @override
  String get replaceMeasurementConfirmAction => 'Replace';

  @override
  String get addMeasurementEntryAction => 'Log measurement';

  @override
  String get statsWeightCardTitle => 'Body weight';

  @override
  String get statsBodyFatCardTitle => 'Body fat %';

  @override
  String get statsMeasurementsCardTitle => 'Measurements';

  @override
  String get statsPeriodWeek => 'Week';

  @override
  String get statsPeriodMonth => 'Month';

  @override
  String get statsPeriodThreeMonths => '3M';

  @override
  String get statsPeriodYear => 'Year';

  @override
  String get statsPeriodAllTime => 'All';

  @override
  String get statsPeriodCustom => 'Custom';

  @override
  String get statsEmptyPeriod => 'No entries in this period';

  @override
  String get statsWorkoutsCardTitle => 'Workouts';

  @override
  String get statsWorkoutsCountLabel => 'Workouts';

  @override
  String get statsWorkoutsFrequencyLabel => 'Frequency';

  @override
  String statsWorkoutsFrequencyValue(String value) {
    return '$value / wk';
  }

  @override
  String get statsExerciseProgressCardTitle => 'Exercise progress';

  @override
  String get statsExerciseProgressSearchAction => 'Choose exercise';

  @override
  String get exerciseProgressPickerTitle => 'Choose exercise';

  @override
  String get exerciseProgressLoadError => 'Failed to load exercise';

  @override
  String get recordTypeMaxWeight => 'Max weight';

  @override
  String get recordTypeMax1RM => 'Estimated 1RM';

  @override
  String get recordTypeMaxVolumeWorkout => 'Workout tonnage';

  @override
  String get recordTypeMaxDistance => 'Max distance';

  @override
  String get recordTypeBestPace => 'Best pace';

  @override
  String get recordTypeLongestDuration => 'Longest duration';

  @override
  String get statsEstimatedBadge => 'estimated';

  @override
  String get statsRecordsSectionTitle => 'Records';

  @override
  String get statsRecordsEmptyState => 'No records yet';

  @override
  String get statsRepsAtWeightTableTitle => 'Reps at weight';

  @override
  String get statsRepsAtWeightWeightColumn => 'Weight';

  @override
  String get statsRepsAtWeightRepsColumn => 'Reps';

  @override
  String get statsRepsAtWeightDateColumn => 'Date';

  @override
  String statsKgValue(String value) {
    return '$value kg';
  }

  @override
  String statsKmValue(String value) {
    return '$value km';
  }

  @override
  String statsPaceValue(String value) {
    return '$value / km';
  }

  @override
  String get exportScreenTitle => 'Import/Export';

  @override
  String get exportAction => 'Export data (CSV)';

  @override
  String get exportError => 'Failed to export data';

  @override
  String get importAction => 'Import';

  @override
  String get importComingSoonLabel => 'Coming in future versions';

  @override
  String get exportFormatHelpAction => 'CSV format description';

  @override
  String get exportFormatHelpTitle => 'CSV format description';

  @override
  String get exportFormatHelpIntro =>
      'Export produces a ZIP archive with three CSV files and manifest.json. UTF-8 encoding with a byte-order mark (opens correctly in Excel and Google Sheets, including Cyrillic text). Comma-separated, values are always metric regardless of the unit system setting. Dates use the YYYY-MM-DD format. Only non-deleted data is exported; archived exercises are included, since workout history still references them.';

  @override
  String get exportFormatHelpManifestTitle => 'manifest.json';

  @override
  String get exportFormatHelpManifestDescription =>
      'Format version, app version, export timestamp, and row counts for each file.';

  @override
  String get exportFormatHelpWorkoutsDescription =>
      'One row per set. A workout with no exercises, or an exercise with no sets, still gets its own row with the remaining fields empty.';

  @override
  String get exportFormatHelpMeasurementsDescription =>
      'One row per measurement entry.';

  @override
  String get exportFormatHelpExercisesDescription =>
      'One row per catalog exercise.';

  @override
  String get exportFormatHelpColumnsLabel => 'Columns:';

  @override
  String get exportJournalTitle => 'Operations log';

  @override
  String get exportJournalEmpty => 'No operations yet';

  @override
  String get exportJournalLoadError => 'Failed to load the log';

  @override
  String get exportStatusInProgress => 'In progress';

  @override
  String get exportStatusSuccess => 'Success';

  @override
  String get exportStatusFailed => 'Failed';

  @override
  String exportJournalCounts(
    int workouts,
    int sets,
    int measurements,
    int exercises,
  ) {
    return '$workouts workouts · $sets sets · $measurements measurements · $exercises exercises';
  }
}
