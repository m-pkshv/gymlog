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
}
