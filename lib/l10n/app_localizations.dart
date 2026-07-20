import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title, used as the OS task-switcher label.
  ///
  /// In en, this message translates to:
  /// **'GymLog'**
  String get appTitle;

  /// Bottom navigation label for the Today tab (S-01).
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// Bottom navigation label for the History tab (S-02).
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// Bottom navigation label for the Exercises tab (S-06).
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get tabExercises;

  /// Bottom navigation label for the Stats tab (S-09).
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStats;

  /// Bottom navigation label for the More tab (S-11).
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// Empty state title on the Exercises list (S-06) when the catalog has no entries.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get exercisesEmptyTitle;

  /// Error state message on the Exercises list (S-06).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load exercises'**
  String get exercisesLoadError;

  /// FAB tooltip/label and empty-state action on the Exercises list (S-06).
  ///
  /// In en, this message translates to:
  /// **'Create exercise'**
  String get createExerciseAction;

  /// Title of the create-exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'New exercise'**
  String get createExerciseTitle;

  /// Label for the exercise name field on the create-exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get exerciseNameLabel;

  /// Validation error when the exercise name field is left empty (S-08).
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get exerciseNameRequiredError;

  /// Label for the exercise type field on the create-exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get exerciseTypeLabel;

  /// ExerciseType.strength display name.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get exerciseTypeStrength;

  /// ExerciseType.cardio display name.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get exerciseTypeCardio;

  /// ExerciseType.reps display name.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get exerciseTypeReps;

  /// ExerciseType.time display name.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get exerciseTypeTime;

  /// ExerciseType.stretch display name.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get exerciseTypeStretch;

  /// Snackbar shown when creating an exercise fails (S-08).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the exercise'**
  String get createExerciseError;

  /// Submit button label on creation forms (S-08, S-15, ...).
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// Cancel button label on creation forms and confirmation dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// FAB on the History list (S-02) that creates a draft workout and opens the editor (S-03).
  ///
  /// In en, this message translates to:
  /// **'New workout'**
  String get newWorkoutAction;

  /// AppBar title of the workout editor (S-03).
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutEditorTitle;

  /// Error state on the workout editor (S-03) when loading fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the workout'**
  String get workoutLoadError;

  /// Snackbar shown when Start/Finish fails on the workout editor (S-03).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the workout'**
  String get workoutStatusChangeError;

  /// WorkoutStatus.draft display name.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// WorkoutStatus.inProgress display name.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get statusInProgress;

  /// WorkoutStatus.completed display name.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// WorkoutStatus.planned display name.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get statusPlanned;

  /// WorkoutStatus.skipped display name.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// WorkoutStatus.cancelled display name.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// Status menu action for draft -> planned (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get transitionScheduleAction;

  /// Status menu action for completed -> inProgress, within the 24h resume window (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get transitionResumeAction;

  /// Status menu action for planned/inProgress -> cancelled (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get transitionCancelAction;

  /// Status menu action for planned -> skipped (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get transitionSkipAction;

  /// Status menu action for skipped/cancelled -> planned (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Back to planned'**
  String get transitionBackToPlanAction;

  /// Status menu action for planned -> draft (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Back to draft'**
  String get transitionBackToDraftAction;

  /// Button on the workout editor (S-03) that transitions draft -> inProgress.
  ///
  /// In en, this message translates to:
  /// **'Start workout'**
  String get startWorkoutAction;

  /// Button on the workout editor (S-03) that transitions inProgress -> completed.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishWorkoutAction;

  /// Button on the workout editor (S-03) and title of the exercise picker it opens.
  ///
  /// In en, this message translates to:
  /// **'Add exercise'**
  String get addExerciseAction;

  /// Button on an exercise card in the workout editor (S-03) that adds a working set.
  ///
  /// In en, this message translates to:
  /// **'Add set'**
  String get addSetAction;

  /// Empty state on the workout editor (S-03) before any exercise is added.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet'**
  String get workoutExercisesEmpty;

  /// Set-number column header in the sets table (S-03).
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get setColumnNumber;

  /// Warm-up checkbox column header in the sets table (S-03).
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get setColumnWarmup;

  /// Planned-values column header in the sets table (S-03).
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get setColumnPlan;

  /// Actual-values column header in the sets table (S-03).
  ///
  /// In en, this message translates to:
  /// **'Fact'**
  String get setColumnFact;

  /// Completion checkbox column header/semantic label in the sets table (S-03, DM 6.7).
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setColumnDone;

  /// Weight field label in the sets table (S-03, strength exercises).
  ///
  /// In en, this message translates to:
  /// **'Weight, kg'**
  String get setFieldWeightKg;

  /// Reps field label in the sets table (S-03, strength/reps exercises).
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get setFieldReps;

  /// Distance field label in the sets table (S-03, cardio exercises).
  ///
  /// In en, this message translates to:
  /// **'Distance, km'**
  String get setFieldDistanceKm;

  /// Duration field label in the sets table (S-03, cardio/time/stretch exercises).
  ///
  /// In en, this message translates to:
  /// **'Duration, s'**
  String get setFieldDurationSec;

  /// Empty state title on the History list (S-02) when there are no completed workouts.
  ///
  /// In en, this message translates to:
  /// **'No completed workouts yet'**
  String get historyEmptyTitle;

  /// Error state message on the History list (S-02).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load history'**
  String get historyLoadError;

  /// Prefix used as the display name of a Workout with name = null, followed by its date (06_DATA_MODEL.md, section 6.4: "Тренировка + дата").
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workoutDefaultNamePrefix;

  /// Exercise count on a History list card (S-02).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exercise} other{{count} exercises}}'**
  String workoutExerciseCount(int count);

  /// Duration on a History list card (S-02), rounded to whole minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String workoutDurationMinutes(int minutes);

  /// No description provided for @muscleGroupChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get muscleGroupChest;

  /// No description provided for @muscleGroupBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get muscleGroupBack;

  /// No description provided for @muscleGroupShoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get muscleGroupShoulders;

  /// No description provided for @muscleGroupRearDelts.
  ///
  /// In en, this message translates to:
  /// **'Rear Delts'**
  String get muscleGroupRearDelts;

  /// No description provided for @muscleGroupBiceps.
  ///
  /// In en, this message translates to:
  /// **'Biceps'**
  String get muscleGroupBiceps;

  /// No description provided for @muscleGroupTriceps.
  ///
  /// In en, this message translates to:
  /// **'Triceps'**
  String get muscleGroupTriceps;

  /// No description provided for @muscleGroupForearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get muscleGroupForearms;

  /// No description provided for @muscleGroupAbs.
  ///
  /// In en, this message translates to:
  /// **'Abs'**
  String get muscleGroupAbs;

  /// No description provided for @muscleGroupObliques.
  ///
  /// In en, this message translates to:
  /// **'Obliques'**
  String get muscleGroupObliques;

  /// No description provided for @muscleGroupHipFlexors.
  ///
  /// In en, this message translates to:
  /// **'Hip Flexors'**
  String get muscleGroupHipFlexors;

  /// No description provided for @muscleGroupGlutes.
  ///
  /// In en, this message translates to:
  /// **'Glutes'**
  String get muscleGroupGlutes;

  /// No description provided for @muscleGroupQuads.
  ///
  /// In en, this message translates to:
  /// **'Quads'**
  String get muscleGroupQuads;

  /// No description provided for @muscleGroupAdductors.
  ///
  /// In en, this message translates to:
  /// **'Adductors'**
  String get muscleGroupAdductors;

  /// No description provided for @muscleGroupHamstrings.
  ///
  /// In en, this message translates to:
  /// **'Hamstrings'**
  String get muscleGroupHamstrings;

  /// No description provided for @muscleGroupCalves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get muscleGroupCalves;

  /// No description provided for @muscleGroupFullBody.
  ///
  /// In en, this message translates to:
  /// **'Full body'**
  String get muscleGroupFullBody;

  /// No description provided for @muscleGroupCardioSystem.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get muscleGroupCardioSystem;

  /// No description provided for @equipmentBarbell.
  ///
  /// In en, this message translates to:
  /// **'Barbell'**
  String get equipmentBarbell;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In en, this message translates to:
  /// **'Dumbbell'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentMachine.
  ///
  /// In en, this message translates to:
  /// **'Machine'**
  String get equipmentMachine;

  /// No description provided for @equipmentCable.
  ///
  /// In en, this message translates to:
  /// **'Cable machine'**
  String get equipmentCable;

  /// No description provided for @equipmentBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get equipmentBodyweight;

  /// No description provided for @equipmentBand.
  ///
  /// In en, this message translates to:
  /// **'Resistance band'**
  String get equipmentBand;

  /// No description provided for @equipmentCardioMachine.
  ///
  /// In en, this message translates to:
  /// **'Cardio machine'**
  String get equipmentCardioMachine;

  /// No description provided for @equipmentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipmentOther;

  /// No description provided for @effortMetricNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get effortMetricNone;

  /// No description provided for @effortMetricRpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get effortMetricRpe;

  /// No description provided for @effortMetricRir.
  ///
  /// In en, this message translates to:
  /// **'RIR'**
  String get effortMetricRir;

  /// Label for the primary muscle group field on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Primary muscle'**
  String get exercisePrimaryMuscleLabel;

  /// Label for the secondary muscle groups field on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Secondary muscles'**
  String get exerciseSecondaryMusclesLabel;

  /// Label for the equipment field on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get exerciseEquipmentLabel;

  /// Label for the effort metric field on the exercise form (S-08), shown only for strength exercises.
  ///
  /// In en, this message translates to:
  /// **'Effort metric'**
  String get exerciseEffortMetricLabel;

  /// Label for the description field on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get exerciseDescriptionLabel;

  /// Label for the YouTube URL field on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'YouTube link'**
  String get exerciseYoutubeUrlLabel;

  /// Non-blocking hint under the YouTube field when the URL doesn't look like a youtube.com/youtu.be link (DM 6.1: a soft rule, saving stays allowed).
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t look like a YouTube link'**
  String get exerciseYoutubeUrlWarning;

  /// "No selection" option for the optional primary muscle/equipment dropdowns on the exercise form (S-08).
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get exerciseNotSpecified;

  /// Error state on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the exercise'**
  String get exerciseDetailLoadError;

  /// "About" tab label on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get exerciseAboutTab;

  /// "History" tab label on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get exerciseHistoryTab;

  /// Empty state for the "History" tab on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'No completed workouts with this exercise yet'**
  String get exerciseHistoryEmpty;

  /// Badge shown on the exercise card (S-07) when the exercise is archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get exerciseArchivedBadge;

  /// Menu action on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveExerciseAction;

  /// Menu action on the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchiveExerciseAction;

  /// Menu action on the exercise card (S-07), only offered for an unused user-created exercise (DM 10).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteExerciseAction;

  /// AlertDialog title confirming exercise deletion (S-07, DM 10 — permanent, no Undo).
  ///
  /// In en, this message translates to:
  /// **'Delete this exercise?'**
  String get deleteExerciseConfirmTitle;

  /// AlertDialog body confirming exercise deletion (S-07).
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get deleteExerciseConfirmMessage;

  /// Snackbar shown when deleting an exercise fails (S-07).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the exercise'**
  String get deleteExerciseError;

  /// Snackbar shown when archiving/unarchiving an exercise fails (S-07).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the exercise'**
  String get archiveExerciseError;

  /// Title of the exercise form (S-08) when opened in edit mode from the exercise card (S-07).
  ///
  /// In en, this message translates to:
  /// **'Edit exercise'**
  String get editExerciseTitle;

  /// Menu action on the exercise card (S-07), only offered for user-created exercises (built-in ones can only be archived).
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editExerciseAction;

  /// Snackbar shown when saving edits to an exercise fails (S-07/S-08).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the exercise'**
  String get editExerciseError;

  /// Submit button label on the exercise form (S-08) when in edit mode.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Helper text under the disabled type dropdown on the exercise form (S-08) in edit mode, once DM 6.1's exerciseType lock applies.
  ///
  /// In en, this message translates to:
  /// **'Can\'t be changed: this exercise already has logged sets'**
  String get exerciseTypeLockedHint;

  /// Placeholder text in the search field on the Exercises list (S-06).
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchExercisesHint;

  /// Tooltip on the AppBar filter icon that opens the filter bottom sheet on the Exercises list (S-06).
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterExercisesTooltip;

  /// Title of the filter bottom sheet on the Exercises list (S-06).
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// "No filter" option for the type dropdown in the filter sheet (S-06) — distinct from exerciseNotSpecified, which means the exercise itself has no type.
  ///
  /// In en, this message translates to:
  /// **'Any type'**
  String get filterAnyType;

  /// Label for the muscle group filter in the filter sheet (S-06) — matches either the primary or a secondary muscle group, unlike the form's "primary muscle" field.
  ///
  /// In en, this message translates to:
  /// **'Muscle group'**
  String get filterMuscleGroupLabel;

  /// "No filter" option for the muscle group dropdown in the filter sheet (S-06).
  ///
  /// In en, this message translates to:
  /// **'Any muscle group'**
  String get filterAnyMuscleGroup;

  /// "No filter" option for the equipment dropdown in the filter sheet (S-06).
  ///
  /// In en, this message translates to:
  /// **'Any equipment'**
  String get filterAnyEquipment;

  /// Switch label in the filter sheet (S-06); off by default (04_UI_UX_SPEC.md, section 5).
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get filterShowArchived;

  /// Switch label in the filter sheet (S-06); off by default.
  ///
  /// In en, this message translates to:
  /// **'User-created only'**
  String get filterOnlyUserCreated;

  /// Button in the filter sheet (S-06) that clears type/muscle/equipment/archived/user-created back to defaults.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filterResetAction;

  /// Button in the filter sheet (S-06) that applies the selected filters and closes the sheet.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApplyAction;

  /// Empty state title on the Exercises list (S-06) when a search/filter is active but matches nothing — distinct from exercisesEmptyTitle (a genuinely empty catalog).
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get exercisesSearchEmptyTitle;

  /// Empty-state action on the Exercises list (S-06) when search/filters are active and return no matches.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFiltersAction;

  /// Menu action on an exercise card in the workout editor (S-03) that opens the past-results bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Past results'**
  String get pastResultsAction;

  /// Title of the past-results bottom sheet (S-03) — the last 5 completed occurrences of the exercise.
  ///
  /// In en, this message translates to:
  /// **'Past results'**
  String get pastResultsTitle;

  /// Empty state inside the past-results bottom sheet (S-03).
  ///
  /// In en, this message translates to:
  /// **'No completed occurrences of this exercise yet'**
  String get pastResultsEmpty;

  /// Error state inside the past-results bottom sheet (S-03).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load past results'**
  String get pastResultsLoadError;

  /// Menu action on an exercise card in the workout editor (S-03, TS 8 section 8) that copies the actual values of the most recent completed occurrence into the current sets' planned values.
  ///
  /// In en, this message translates to:
  /// **'Copy last performance'**
  String get copyLastPerformanceAction;

  /// Snackbar shown when "Copy last performance" is tapped but this exercise has no completed history yet (S-03).
  ///
  /// In en, this message translates to:
  /// **'No past results to copy yet'**
  String get copyLastPerformanceEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
