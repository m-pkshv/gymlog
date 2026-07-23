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

  /// S-01 upcoming-workout card button: starts it directly (draft/planned -> inProgress, DM 6.4.1) via startWorkoutFlow.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get todayStartAction;

  /// S-01 empty state (04_UI_UX_SPEC.md section 5: "приветствие") shown when there's no inProgress and no upcoming draft/planned workout.
  ///
  /// In en, this message translates to:
  /// **'No workout planned today'**
  String get todayEmptyTitle;

  /// S-01 error state when inProgressWorkoutProvider or nextUpcomingWorkoutProvider fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load today\'s workout'**
  String get todayLoadError;

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

  /// Button on the storage-error state (04_UI_UX_SPEC.md, section 6: "Не удалось загрузить" + "Повторить") -- re-fetches via ErrorRetryState's onRetry, typically ref.invalidate(provider).
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

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

  /// Title of the conflict dialog (S-03, DM 6.4.1) shown when starting/resuming this workout would violate the "at most one inProgress" invariant.
  ///
  /// In en, this message translates to:
  /// **'A workout is already in progress'**
  String get activeWorkoutConflictTitle;

  /// Body of the conflict dialog (S-03, DM 6.4.1).
  ///
  /// In en, this message translates to:
  /// **'Only one workout can be in progress at a time. Finish or cancel the current one first.'**
  String get activeWorkoutConflictMessage;

  /// Conflict dialog action (S-03, DM 6.4.1) that cancels the other, currently inProgress workout.
  ///
  /// In en, this message translates to:
  /// **'Cancel it'**
  String get activeWorkoutConflictCancelOtherAction;

  /// Conflict dialog action (S-03, DM 6.4.1) that finishes the other, currently inProgress workout.
  ///
  /// In en, this message translates to:
  /// **'Finish it'**
  String get activeWorkoutConflictFinishOtherAction;

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

  /// Section heading on the exercise form (S-08) for the list of per-language name/description translations (DM 12, Stage 10).
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get exerciseLocalizationSectionTitle;

  /// Button that adds one more translation entry to the exercise form's localization section (DM 12, Stage 10).
  ///
  /// In en, this message translates to:
  /// **'Add localization'**
  String get exerciseAddLocalizationAction;

  /// Label for the language dropdown within one localization entry on the exercise form (DM 12, Stage 10).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get exerciseLocalizationLanguageLabel;

  /// Tooltip/semantic label for the icon button that removes one localization entry from the exercise form (DM 12, Stage 10).
  ///
  /// In en, this message translates to:
  /// **'Remove translation'**
  String get exerciseRemoveLocalizationAction;

  /// Validation message when a localization entry's name is left empty on submit (DM 12, Stage 10).
  ///
  /// In en, this message translates to:
  /// **'Enter a translated name or remove this entry'**
  String get exerciseLocalizationNameRequiredError;

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

  /// Trailing chip in the workout editor's tag row (S-03) that opens the tag picker sheet.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get workoutTagsAddAction;

  /// Title of the tag picker bottom sheet (S-03, DM 6.3/6.5).
  ///
  /// In en, this message translates to:
  /// **'Workout tags'**
  String get workoutTagsSheetTitle;

  /// Empty state inside the tag picker sheet (S-03) before any tag has been created.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get workoutTagsEmpty;

  /// Error state inside the tag picker sheet (S-03).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load tags'**
  String get workoutTagsLoadError;

  /// Button in the tag picker sheet (S-03) that opens the create-tag dialog.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get createTagAction;

  /// Title of the create-tag dialog (S-03, DM 6.3).
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get createTagTitle;

  /// Error shown in the create-tag dialog (S-03) when WorkoutTagService.create rejects the name (empty, too long, or a duplicate).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the tag'**
  String get createTagError;

  /// Text field label in the create-tag dialog (S-03, DM 6.3: 1-30 chars).
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tagNameLabel;

  /// S-17 settings screen title (AppBar) and its entry point label on the "More" screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Switch on the S-17 settings screen that toggles AppSettings.showTags (DM 6.12).
  ///
  /// In en, this message translates to:
  /// **'Show tags'**
  String get settingsShowTagsLabel;

  /// Switch on the S-17 settings screen that toggles AppSettings.unitSystem between metric/imperial (D-5).
  ///
  /// In en, this message translates to:
  /// **'Imperial units'**
  String get settingsUnitSystemLabel;

  /// Subtitle shown under settingsUnitSystemLabel when unitSystem is metric.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm)'**
  String get settingsUnitSystemMetric;

  /// Subtitle shown under settingsUnitSystemLabel when unitSystem is imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb, in)'**
  String get settingsUnitSystemImperial;

  /// Label above the theme segmented button on the S-17 settings screen (04_UI_UX_SPEC.md, section 9).
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeLabel;

  /// Theme segment: follow the OS light/dark setting (AppTheme.system).
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Theme segment: always light (AppTheme.light).
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Theme segment: always dark (AppTheme.dark).
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Label above the language segmented button on the S-17 settings screen (04_UI_UX_SPEC.md, section 5).
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// Language segment: follow the OS language, resolved against AppLocalizations.supportedLocales (AppLocale.system).
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsLanguageSystem;

  /// Language segment: pin the app to Russian (AppLocale.ru). Shown in Russian regardless of the app's current language, per convention -- language names name themselves, they aren't translated.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRu;

  /// Language segment: pin the app to English (AppLocale.en). Shown in English regardless of the app's current language, same convention as settingsLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// Label on the S-17 rest-timer-seconds text field (AppSettings.defaultRestTimerSec, DM 6.12, Q-4).
  ///
  /// In en, this message translates to:
  /// **'Default rest timer (sec)'**
  String get settingsRestTimerLabel;

  /// Inline error under the rest-timer-seconds field when the entered value is out of the DM 6.12 10-600 range, or not a whole number.
  ///
  /// In en, this message translates to:
  /// **'Enter a value from 10 to 600 seconds'**
  String get settingsRestTimerRangeError;

  /// Switch on the S-17 settings screen for AppSettings.restTimerAutoStart (DM 6.12).
  ///
  /// In en, this message translates to:
  /// **'Auto-start rest timer'**
  String get settingsRestTimerAutoStartLabel;

  /// Title of the S-17 notifications row (04_UI_UX_SPEC.md, section 5: status + link to OS settings).
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotificationsLabel;

  /// Notifications row subtitle when NotificationService.areNotificationsEnabled() is true.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get settingsNotificationsEnabled;

  /// Notifications row subtitle when NotificationService.areNotificationsEnabled() is false.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get settingsNotificationsDisabled;

  /// Button on the S-17 notifications row that opens the OS app-settings screen via permission_handler.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNotificationsOpenSettingsAction;

  /// Snackbar shown when NotificationService.openNotificationSettings() reports it could not open the OS settings screen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open system settings'**
  String get settingsNotificationsOpenSettingsError;

  /// Header above the S-17 'About' rows (04_UI_UX_SPEC.md, section 5: version, export format version).
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutLabel;

  /// Row title for the app version (ExportFormat.appVersion), shown as the row's trailing value.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsAboutVersionLabel;

  /// Row title for the CSV export format version (ExportFormat.formatVersion, D-9), shown as the row's trailing value.
  ///
  /// In en, this message translates to:
  /// **'Export format version'**
  String get settingsAboutExportFormatVersionLabel;

  /// Error state on the S-17 settings screen (and anywhere else appSettingsProvider is watched) when the settings row fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load settings'**
  String get settingsLoadError;

  /// "⋮" menu action on a History card (S-02, TS 8 section 8) that copies the workout's exercises/order/planned values into a new draft dated by the owner.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyWorkoutAction;

  /// Snackbar shown on the History screen (S-02) when copying a workout fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy the workout'**
  String get copyWorkoutError;

  /// Option in the History FAB's creation menu (Stage 3) that creates a blank draft, same as the old direct FAB tap.
  ///
  /// In en, this message translates to:
  /// **'From scratch'**
  String get newWorkoutFromScratchAction;

  /// Option in the History FAB's creation menu (Stage 3) that opens the copy-source picker.
  ///
  /// In en, this message translates to:
  /// **'From a copy'**
  String get newWorkoutFromCopyAction;

  /// Option in the History FAB's creation menu that opens the template-source picker (Stage 5).
  ///
  /// In en, this message translates to:
  /// **'From a template'**
  String get newWorkoutFromTemplateAction;

  /// AppBar title of the copy-source picker screen (Stage 3, "Копией").
  ///
  /// In en, this message translates to:
  /// **'Copy from...'**
  String get copySourcePickerTitle;

  /// Empty state on the copy-source picker screen (Stage 3) when there are no completed workouts.
  ///
  /// In en, this message translates to:
  /// **'No completed workouts to copy from yet'**
  String get copySourcePickerEmpty;

  /// AppBar action tooltip on History (S-02, Stage 3) that opens the filter bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterWorkoutsTooltip;

  /// Hint text of History's persistent search field (S-02, Stage 3).
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchHistoryHint;

  /// Label for the range-start date picker in History's filter sheet (S-02, Stage 3).
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filterDateFromLabel;

  /// Label for the range-end date picker in History's filter sheet (S-02, Stage 3).
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filterDateToLabel;

  /// UX 11 accessibility: label for the icon-only "clear" button next to the range-start date in History's filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Clear start date'**
  String get filterClearDateFromTooltip;

  /// UX 11 accessibility: label for the icon-only "clear" button next to the range-end date in History's filter sheet.
  ///
  /// In en, this message translates to:
  /// **'Clear end date'**
  String get filterClearDateToTooltip;

  /// Shown instead of a date when a History filter date-range bound isn't set.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get filterAnyDate;

  /// Section label above the status multi-select chips in History's filter sheet (S-02, Stage 3).
  ///
  /// In en, this message translates to:
  /// **'Statuses'**
  String get filterStatusesLabel;

  /// Section label above the tag multi-select chips in History's filter sheet (S-02, Stage 3); the whole section is hidden when AppSettings.showTags is off.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get filterTagsLabel;

  /// Empty state title on History (S-02, Stage 3) when a search/filter is active but matches nothing — distinct from historyEmptyTitle (genuinely no workouts yet).
  ///
  /// In en, this message translates to:
  /// **'No matches found'**
  String get historySearchEmptyTitle;

  /// Menu action on an exercise card in the workout editor (S-03, Stage 3) — the gesture-free alternative to the drag handle. Hidden when the card is already first.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveExerciseUpAction;

  /// Menu action on an exercise card in the workout editor (S-03, Stage 3) — the gesture-free alternative to the drag handle. Hidden when the card is already last.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveExerciseDownAction;

  /// UX 11 accessibility: Semantics label for the icon-only drag handle on an exercise card (workout editor S-03 and template editor S-13) -- the handle itself has no visible text; the "Move up"/"Move down" menu items are its gesture-free alternative.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderDragHandleLabel;

  /// Label of the workout-level comment field in the editor header (S-03, Stage 3, DM 6.4, max 2000 chars).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get workoutCommentLabel;

  /// Label of the per-exercise comment field on an exercise card (S-03, Stage 3, DM 6.6, max 1000 chars).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get exerciseCommentLabel;

  /// Tooltip on the per-set comment icon button in the sets table (S-03, Stage 3) that opens the comment dialog.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get setCommentAction;

  /// Title of the per-set comment dialog (S-03, Stage 3, DM 6.7, max 500 chars).
  ///
  /// In en, this message translates to:
  /// **'Set comment'**
  String get setCommentTitle;

  /// Text field label inside the per-set comment dialog (S-03, Stage 3).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get setCommentLabel;

  /// "⋮" menu action on a History card (S-02, Stage 3, DM 10) that soft-deletes the workout with a 5s Undo snackbar.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteWorkoutAction;

  /// Snackbar shown after deleting a workout from History (S-02, Stage 3), with an "Undo" action.
  ///
  /// In en, this message translates to:
  /// **'Workout deleted'**
  String get workoutDeletedMessage;

  /// Snackbar action label that reverses a soft delete within the Undo window (DM 10, D-19).
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// Snackbar shown on History (S-02) when deleting a workout is rejected (e.g. it's inProgress, DM 10) or fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the workout'**
  String get deleteWorkoutError;

  /// Label next to the progression-decision segmented button on an exercise card (S-03, DM 6.11).
  ///
  /// In en, this message translates to:
  /// **'Progression:'**
  String get progressionDecisionLabel;

  /// ProgressionDecision.none segment label (S-03) — no decision made yet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get progressionDecisionNone;

  /// ProgressionDecision.increase segment label (S-03) — increase next time.
  ///
  /// In en, this message translates to:
  /// **'↑'**
  String get progressionDecisionIncrease;

  /// ProgressionDecision.repeat segment label (S-03) — repeat next time.
  ///
  /// In en, this message translates to:
  /// **'='**
  String get progressionDecisionRepeat;

  /// ProgressionDecision.decrease segment label (S-03) — decrease next time.
  ///
  /// In en, this message translates to:
  /// **'↓'**
  String get progressionDecisionDecrease;

  /// D-7 stagnation-counter hint under the progression segment (S-03, TS 9.4) — only shown when count > 0.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} workout without growth} other{{count} workouts without growth}}'**
  String stagnationHint(num count);

  /// AppBar toggle tooltip on History (S-02, Stage 3) shown while in list mode, switches to the calendar view.
  ///
  /// In en, this message translates to:
  /// **'Calendar view'**
  String get historyViewCalendarTooltip;

  /// AppBar toggle tooltip on History (S-02, Stage 3) shown while in calendar mode, switches back to the list.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get historyViewListTooltip;

  /// Shown below the calendar grid (S-02, Stage 3) when the selected day has no workouts matching the active search/status/tag filters.
  ///
  /// In en, this message translates to:
  /// **'No workouts this day'**
  String get historyCalendarDayEmpty;

  /// UX 11 accessibility: label for the icon-only back-a-month button above the calendar grid.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get historyCalendarPreviousMonthTooltip;

  /// UX 11 accessibility: label for the icon-only forward-a-month button above the calendar grid.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get historyCalendarNextMonthTooltip;

  /// UX 11 accessibility: appended to a calendar day cell's Semantics label (e.g. "July 15, 2026, has a workout") so the marker dot's meaning isn't color-only.
  ///
  /// In en, this message translates to:
  /// **'has a workout'**
  String get historyCalendarDayHasWorkout;

  /// UX 11 accessibility: appended to a calendar day cell's Semantics label when it's the current date.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get historyCalendarDayToday;

  /// Tooltip on the workout timer's pause button (S-03, Stage 4, TS 7.1), shown while the timer is running.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get workoutTimerPauseAction;

  /// Tooltip on the workout timer's resume button (S-03, Stage 4, TS 7.1), shown while the timer is paused.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get workoutTimerResumeAction;

  /// Label on the rest-timer bar (S-04, Stage 4, TS 7.2), shown only while a rest timer is running.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get restTimerLabel;

  /// Tooltip on the rest-timer bar's shorten button (S-04, Stage 4).
  ///
  /// In en, this message translates to:
  /// **'-15 s'**
  String get restTimerMinus15Tooltip;

  /// Tooltip on the rest-timer bar's extend button (S-04, Stage 4).
  ///
  /// In en, this message translates to:
  /// **'+15 s'**
  String get restTimerPlus15Tooltip;

  /// Button on the rest-timer bar (S-04, Stage 4) that cancels the running rest timer early.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get restTimerSkipAction;

  /// Recovery banner (Stage 4, TS 7.2 step 5) shown on the tab shell whenever a workout is inProgress -- including right after a cold start with one already running.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress, {minutes} min'**
  String workoutContinuingBannerMessage(int minutes);

  /// Action button on the recovery banner (Stage 4) that opens the inProgress workout in the editor.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWorkoutAction;

  /// Title of the confirmation dialog (Stage 4, TS 7.2 step 6) shown when finishing a workout that still has unmarked working sets.
  ///
  /// In en, this message translates to:
  /// **'Finish workout?'**
  String get finishWithIncompleteSetsTitle;

  /// Body of the confirmation dialog (Stage 4, TS 7.2 step 6). Shown when any set is left unchecked (Stage 10, 2026-07-23: the warm-up concept was removed -- every set counts).
  ///
  /// In en, this message translates to:
  /// **'Mark the remaining sets as not completed and finish?'**
  String get finishWithIncompleteSetsMessage;

  /// Title of the app's own explanatory dialog (Stage 4, TS 7.3) shown once, before the system permission prompt, the first time a rest timer would start.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications?'**
  String get notificationPermissionRationaleTitle;

  /// Body of the notification-permission rationale dialog (Stage 4, TS 7.3).
  ///
  /// In en, this message translates to:
  /// **'Get notified when your rest between sets is over, even if the app is in the background.'**
  String get notificationPermissionRationaleMessage;

  /// Declines the rationale dialog (Stage 4, TS 7.3) -- the system permission prompt is not shown in this case.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationPermissionNotNowAction;

  /// Accepts the rationale dialog (Stage 4, TS 7.3) and triggers the actual OS permission prompt.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notificationPermissionAllowAction;

  /// Title of the scheduled local notification fired when the rest timer ends (Stage 4, TS 7.2 step 3).
  ///
  /// In en, this message translates to:
  /// **'Rest timer'**
  String get restTimerNotificationTitle;

  /// Body of the scheduled local notification fired when the rest timer ends (Stage 4, TS 7.2 step 3).
  ///
  /// In en, this message translates to:
  /// **'Rest is over — next set'**
  String get restTimerNotificationBody;

  /// Unobtrusive note on the rest-timer bar (Stage 4, TS 7.3) shown when notifications are currently disabled -- no settings deep-link (would need an additional package).
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsOffHint;

  /// AppBar title of the S-05 workout summary screen, shown right after finishing a workout.
  ///
  /// In en, this message translates to:
  /// **'Workout summary'**
  String get workoutSummaryTitle;

  /// Caption under the duration figure on S-05.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutSummaryDurationLabel;

  /// Caption under the exercise-count figure on S-05.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutSummaryExercisesLabel;

  /// Caption under the set-count figure on S-05.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get workoutSummarySetsLabel;

  /// Caption under the tonnage figure on S-05 (03_TECHNICAL_SPEC.md, section 9: Σ actualWeightKg × actualReps).
  ///
  /// In en, this message translates to:
  /// **'Tonnage'**
  String get workoutSummaryTonnageLabel;

  /// Formatted tonnage figure on S-05 -- always metric (ASSUMPTION(fixed-metric-unit)).
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String workoutSummaryTonnageValue(String value);

  /// S-05 section title shown only when this workout set at least one PersonalRecord (Stage 7).
  ///
  /// In en, this message translates to:
  /// **'New records'**
  String get workoutSummaryNewRecordsTitle;

  /// Button on S-05 that returns to History.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get workoutSummaryDoneAction;

  /// AppBar title of the S-12 template list, and its entry on the 'More' menu (S-11).
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// Empty state on S-12 when there are no templates at all.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get templatesEmptyTitle;

  /// Error state on S-12.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load templates'**
  String get templatesLoadError;

  /// Exercise count on a template list card (S-12).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} exercise} other{{count} exercises}}'**
  String templateExerciseCount(int count);

  /// FAB tooltip and empty-state button on S-12 (create from scratch).
  ///
  /// In en, this message translates to:
  /// **'Create template'**
  String get createTemplateAction;

  /// Title of the create-template dialog opened from S-12's FAB.
  ///
  /// In en, this message translates to:
  /// **'New template'**
  String get createTemplateTitle;

  /// Shown in the create-template dialog when WorkoutTemplateService.create fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the template'**
  String get createTemplateError;

  /// Label for the template name field, both in the create dialog and the S-13 editor header.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get templateNameLabel;

  /// AppBar title of the S-13 template editor.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get templateEditorTitle;

  /// Label for the template-level comment field on S-13 (06_DATA_MODEL.md, section 6.8).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get templateCommentLabel;

  /// Error state on S-13.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the template'**
  String get templateLoadError;

  /// Empty state on S-13 before any exercise has been added.
  ///
  /// In en, this message translates to:
  /// **'No exercises yet'**
  String get templateExercisesEmpty;

  /// S-12 card menu item that archives a template.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTemplateAction;

  /// S-12 card menu item that unarchives a template.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchiveTemplateAction;

  /// Shown when archiving/unarchiving a template fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the template'**
  String get archiveTemplateError;

  /// S-12 card menu item that soft-deletes a template (D-19).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTemplateAction;

  /// Snackbar shown after deleting a template, with the Undo action (D-19, 5s window).
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeletedMessage;

  /// Shown when deleting a template fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the template'**
  String get deleteTemplateError;

  /// S-02 workout card '⋮' menu item that creates a template from that workout's structure and planned values (TS 8 section 8).
  ///
  /// In en, this message translates to:
  /// **'Create template'**
  String get createTemplateFromWorkoutAction;

  /// S-12 template card '⋮' menu item that creates a workout from that template's structure and planned values (TS 8 section 8, reverse of createTemplateFromWorkoutAction).
  ///
  /// In en, this message translates to:
  /// **'Create workout'**
  String get createWorkoutFromTemplateAction;

  /// Shown when WorkoutRepository.createFromTemplate fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the workout'**
  String get createWorkoutFromTemplateError;

  /// AppBar title of the template-source picker screen (Stage 5, "Из шаблона").
  ///
  /// In en, this message translates to:
  /// **'Create from template...'**
  String get templateSourcePickerTitle;

  /// Empty state on the template-source picker screen (Stage 5) when there are no templates.
  ///
  /// In en, this message translates to:
  /// **'No templates to create a workout from yet'**
  String get templateSourcePickerEmpty;

  /// S-12 card menu item that clones a template (04_UI_UX_SPEC.md section 5).
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateTemplateAction;

  /// Title of the name-prompt dialog opened by the S-12 'Дублировать' menu item -- reuses CreateTemplateDialog with this title override.
  ///
  /// In en, this message translates to:
  /// **'Duplicate template'**
  String get duplicateTemplateTitle;

  /// AppBar title of the S-14 measurements screen, and its entry on the 'More' menu (S-11, Stage 6).
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsTitle;

  /// Display label for the built-in 'body_weight' MeasurementType (06_DATA_MODEL.md, section 5.3).
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get measurementTypeBodyWeight;

  /// Display label for the built-in 'body_fat' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Body fat %'**
  String get measurementTypeBodyFat;

  /// Display label for the built-in 'neck' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get measurementTypeNeck;

  /// Display label for the built-in 'shoulders_girth' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get measurementTypeShouldersGirth;

  /// Display label for the built-in 'chest_girth' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measurementTypeChestGirth;

  /// Display label for the built-in 'waist' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measurementTypeWaist;

  /// Display label for the built-in 'hips' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get measurementTypeHips;

  /// Display label for the built-in 'biceps_left' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Biceps (left)'**
  String get measurementTypeBicepsLeft;

  /// Display label for the built-in 'biceps_right' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Biceps (right)'**
  String get measurementTypeBicepsRight;

  /// Display label for the built-in 'forearm_left' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Forearm (left)'**
  String get measurementTypeForearmLeft;

  /// Display label for the built-in 'forearm_right' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Forearm (right)'**
  String get measurementTypeForearmRight;

  /// Display label for the built-in 'thigh_left' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Thigh (left)'**
  String get measurementTypeThighLeft;

  /// Display label for the built-in 'thigh_right' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Thigh (right)'**
  String get measurementTypeThighRight;

  /// Display label for the built-in 'calf_left' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Calf (left)'**
  String get measurementTypeCalfLeft;

  /// Display label for the built-in 'calf_right' MeasurementType.
  ///
  /// In en, this message translates to:
  /// **'Calf (right)'**
  String get measurementTypeCalfRight;

  /// Display label for MeasurementUnitKind.mass, shown in the create-custom-type dialog (S-14).
  ///
  /// In en, this message translates to:
  /// **'Weight (kg/lb)'**
  String get measurementUnitKindMass;

  /// Display label for MeasurementUnitKind.percent.
  ///
  /// In en, this message translates to:
  /// **'Percent (%)'**
  String get measurementUnitKindPercent;

  /// Display label for MeasurementUnitKind.length.
  ///
  /// In en, this message translates to:
  /// **'Length (cm/in)'**
  String get measurementUnitKindLength;

  /// Mass unit suffix, metric (D-5).
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// Mass unit suffix, imperial (D-5).
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// Length unit suffix, metric (D-5).
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// Length unit suffix, imperial (D-5).
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get unitIn;

  /// S-14 tab label for the body_weight type.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get measurementsTabWeight;

  /// S-14 tab label for the body_fat type.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get measurementsTabBodyFat;

  /// S-14 tab label for the 13 built-in girth types, picked via a sub-selector.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get measurementsTabMeasurements;

  /// S-14 tab label for user-created measurement types.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get measurementsTabCustom;

  /// Empty state in MeasurementTypeDetail when a type has no logged entries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get measurementsEmptyState;

  /// Shown when the measurements stream/type list fails to load.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load measurements'**
  String get measurementsLoadError;

  /// Label for the girth-type dropdown on S-14's 'Measurements' tab.
  ///
  /// In en, this message translates to:
  /// **'Measurement'**
  String get measurementGirthSelectorLabel;

  /// S-14 'Свои' tab list item that opens the create-custom-type dialog (DM 5.3).
  ///
  /// In en, this message translates to:
  /// **'Add custom measurement…'**
  String get addCustomMeasurementTypeAction;

  /// Empty state on S-14's 'Свои' tab when there are no custom types.
  ///
  /// In en, this message translates to:
  /// **'No custom measurement types yet'**
  String get measurementsCustomEmptyState;

  /// Title of the create-custom-type dialog (S-14, DM 5.3).
  ///
  /// In en, this message translates to:
  /// **'New measurement type'**
  String get createMeasurementTypeTitle;

  /// Label for the custom measurement type's name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get measurementTypeNameLabel;

  /// Label for the custom measurement type's unit-kind dropdown.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get measurementTypeUnitKindLabel;

  /// Shown in the create-custom-type dialog when MeasurementTypeService.create fails (e.g. duplicate name).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create the measurement type'**
  String get createMeasurementTypeError;

  /// Menu item that archives a custom measurement type (DM 10).
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveMeasurementTypeAction;

  /// Menu item that unarchives a custom measurement type.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchiveMeasurementTypeAction;

  /// Shown when archiving/unarchiving a custom measurement type fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the measurement type'**
  String get archiveMeasurementTypeError;

  /// Menu item that permanently deletes an unused custom measurement type (DM 10). Only shown when MeasurementTypeService.canDelete is true.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteMeasurementTypeAction;

  /// Shown when deleting a custom measurement type fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the measurement type'**
  String get deleteMeasurementTypeError;

  /// Title of the confirm dialog before permanently deleting a custom measurement type (DM 10, no Undo).
  ///
  /// In en, this message translates to:
  /// **'Delete measurement type?'**
  String get deleteMeasurementTypeConfirmTitle;

  /// Body of the delete-measurement-type confirm dialog.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this measurement type. This can\'t be undone.'**
  String get deleteMeasurementTypeConfirmMessage;

  /// Snackbar shown after deleting a BodyMeasurement entry, with the Undo action (DM 10, 5s window).
  ///
  /// In en, this message translates to:
  /// **'Measurement deleted'**
  String get measurementEntryDeletedMessage;

  /// Tooltip on the trailing delete icon of a measurement entry row (S-14).
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteMeasurementEntryAction;

  /// AppBar title of the S-15 measurement entry form.
  ///
  /// In en, this message translates to:
  /// **'Log measurement'**
  String get measurementFormTitle;

  /// Label for the type dropdown on the S-15 form.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get measurementTypeFieldLabel;

  /// Label for the date field on the S-15 form.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get measurementDateFieldLabel;

  /// Label for the value field on the S-15 form.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get measurementValueFieldLabel;

  /// Label for the optional comment field on the S-15 form (DM 6.9, 500 chars).
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get measurementCommentFieldLabel;

  /// Shown on the S-15 form when the value field is empty or unparseable.
  ///
  /// In en, this message translates to:
  /// **'Enter a value'**
  String get measurementValueRequiredError;

  /// Shown on the S-15 form when BodyMeasurementService.create/update fails (e.g. out of range, DM 6.9).
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the measurement'**
  String get saveMeasurementError;

  /// Title of the same-day-duplicate confirm dialog (DM 6.9).
  ///
  /// In en, this message translates to:
  /// **'Replace existing value?'**
  String get replaceMeasurementConfirmTitle;

  /// Body of the same-day-duplicate confirm dialog, showing the existing entry's value in the display unit.
  ///
  /// In en, this message translates to:
  /// **'There\'s already an entry for this day: {value} {unit}. Replace it with the new value?'**
  String replaceMeasurementConfirmMessage(String value, String unit);

  /// Confirm button of the same-day-duplicate dialog.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceMeasurementConfirmAction;

  /// Tooltip on the S-14 '+' FAB that opens the S-15 entry form.
  ///
  /// In en, this message translates to:
  /// **'Log measurement'**
  String get addMeasurementEntryAction;

  /// S-09 card title for the body_weight dynamics chart (Stage 7).
  ///
  /// In en, this message translates to:
  /// **'Body weight'**
  String get statsWeightCardTitle;

  /// S-09 card title for the body_fat dynamics chart.
  ///
  /// In en, this message translates to:
  /// **'Body fat %'**
  String get statsBodyFatCardTitle;

  /// S-09 card title for the girth/custom measurement dynamics chart with its own type dropdown.
  ///
  /// In en, this message translates to:
  /// **'Measurements'**
  String get statsMeasurementsCardTitle;

  /// S-09 period selector label for the 7-day preset (03_TECHNICAL_SPEC.md section 9).
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get statsPeriodWeek;

  /// S-09 period selector label for the 30-day preset.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get statsPeriodMonth;

  /// S-09 period selector label for the 90-day preset.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get statsPeriodThreeMonths;

  /// S-09 period selector label for the 365-day preset.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get statsPeriodYear;

  /// S-09 period selector label for the unbounded 'all time' preset.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statsPeriodAllTime;

  /// S-09 period selector label that opens a date-range picker.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get statsPeriodCustom;

  /// Empty state shown on an S-09 chart when the selected period has no data.
  ///
  /// In en, this message translates to:
  /// **'No entries in this period'**
  String get statsEmptyPeriod;

  /// S-09 card title for the completed-workout count/frequency/tonnage card (Stage 7).
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get statsWorkoutsCardTitle;

  /// Label under the completed-workout count figure on the S-09 Workouts card.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get statsWorkoutsCountLabel;

  /// Label under the workout-frequency figure on the S-09 Workouts card. Hidden for the 'all time' period, which has no defined length.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get statsWorkoutsFrequencyLabel;

  /// Formatted frequency figure: completed workouts divided by the period's length in weeks, one decimal place (TS 9).
  ///
  /// In en, this message translates to:
  /// **'{value} / wk'**
  String statsWorkoutsFrequencyValue(String value);

  /// S-09 entry point card title for S-10's per-exercise progress screen (Stage 7).
  ///
  /// In en, this message translates to:
  /// **'Exercise progress'**
  String get statsExerciseProgressCardTitle;

  /// Button on the S-09 entry card that opens the exercise search picker.
  ///
  /// In en, this message translates to:
  /// **'Choose exercise'**
  String get statsExerciseProgressSearchAction;

  /// AppBar title of the search picker that leads into S-10.
  ///
  /// In en, this message translates to:
  /// **'Choose exercise'**
  String get exerciseProgressPickerTitle;

  /// Error state on S-10 when the exercise itself can't be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercise'**
  String get exerciseProgressLoadError;

  /// S-10 records list row label for RecordType.maxWeight.
  ///
  /// In en, this message translates to:
  /// **'Max weight'**
  String get recordTypeMaxWeight;

  /// S-10 records list row label for RecordType.max1RM (Epley formula, D-6).
  ///
  /// In en, this message translates to:
  /// **'Estimated 1RM'**
  String get recordTypeMax1RM;

  /// S-10 records list row label for RecordType.maxVolumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout tonnage'**
  String get recordTypeMaxVolumeWorkout;

  /// S-10 records list row label for RecordType.maxDistance (cardio).
  ///
  /// In en, this message translates to:
  /// **'Max distance'**
  String get recordTypeMaxDistance;

  /// S-10 records list row label for RecordType.bestPace (cardio).
  ///
  /// In en, this message translates to:
  /// **'Best pace'**
  String get recordTypeBestPace;

  /// S-10 records list row label for RecordType.longestDuration (cardio).
  ///
  /// In en, this message translates to:
  /// **'Longest duration'**
  String get recordTypeLongestDuration;

  /// Small caption next to the 1RM record value (04_UI_UX_SPEC.md S-10: "пометка «расчётный»").
  ///
  /// In en, this message translates to:
  /// **'estimated'**
  String get statsEstimatedBadge;

  /// S-10 section title for the general records list (excludes the reps-at-weight table, shown separately).
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get statsRecordsSectionTitle;

  /// Empty state for S-10's records section.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get statsRecordsEmptyState;

  /// S-10 table title for RecordType.maxRepsAtWeight rows (one per distinct weight ever used).
  ///
  /// In en, this message translates to:
  /// **'Reps at weight'**
  String get statsRepsAtWeightTableTitle;

  /// Column header of the S-10 reps-at-weight table.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get statsRepsAtWeightWeightColumn;

  /// Column header of the S-10 reps-at-weight table.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get statsRepsAtWeightRepsColumn;

  /// Column header of the S-10 reps-at-weight table.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get statsRepsAtWeightDateColumn;

  /// Generic kg-valued figure on S-10 (max weight, 1RM, tonnage) -- always metric (ASSUMPTION(fixed-metric-unit), Stage 1).
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String statsKgValue(String value);

  /// Generic km-valued figure on S-10 (max distance) -- always metric.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String statsKmValue(String value);

  /// Best-pace record value on S-10: an m:ss/km string from UnitConverter.formatPace plus a unit suffix.
  ///
  /// In en, this message translates to:
  /// **'{value} / km'**
  String statsPaceValue(String value);

  /// S-16 AppBar title (Stage 8).
  ///
  /// In en, this message translates to:
  /// **'Import/Export'**
  String get exportScreenTitle;

  /// S-16's main export button.
  ///
  /// In en, this message translates to:
  /// **'Export data (CSV)'**
  String get exportAction;

  /// Snackbar shown when ExportService.export throws.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get exportError;

  /// S-16's disabled "Import" stub row title.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;

  /// Subtitle under the disabled "Import" stub row (04_UI_UX_SPEC.md S-16: import is post-MVP, TS 10.6).
  ///
  /// In en, this message translates to:
  /// **'Coming in future versions'**
  String get importComingSoonLabel;

  /// S-16 row that opens the built-in CSV format help screen.
  ///
  /// In en, this message translates to:
  /// **'CSV format description'**
  String get exportFormatHelpAction;

  /// AppBar title of the CSV format help screen.
  ///
  /// In en, this message translates to:
  /// **'CSV format description'**
  String get exportFormatHelpTitle;

  /// General CSV export rules, from 03_TECHNICAL_SPEC.md section 10.1.
  ///
  /// In en, this message translates to:
  /// **'Export produces a ZIP archive with three CSV files and manifest.json. UTF-8 encoding with a byte-order mark (opens correctly in Excel and Google Sheets, including Cyrillic text). Comma-separated, values are always metric regardless of the unit system setting. Dates use the YYYY-MM-DD format. Only non-deleted data is exported; archived exercises are included, since workout history still references them.'**
  String get exportFormatHelpIntro;

  /// Literal file name, not translated.
  ///
  /// In en, this message translates to:
  /// **'manifest.json'**
  String get exportFormatHelpManifestTitle;

  /// TS 10.2 manifest.json contents, in prose.
  ///
  /// In en, this message translates to:
  /// **'Format version, app version, export timestamp, and row counts for each file.'**
  String get exportFormatHelpManifestDescription;

  /// TS 10.3 workouts.csv row shape.
  ///
  /// In en, this message translates to:
  /// **'One row per set. A workout with no exercises, or an exercise with no sets, still gets its own row with the remaining fields empty.'**
  String get exportFormatHelpWorkoutsDescription;

  /// TS 10.4 measurements.csv row shape.
  ///
  /// In en, this message translates to:
  /// **'One row per measurement entry.'**
  String get exportFormatHelpMeasurementsDescription;

  /// TS 10.5 exercises.csv row shape.
  ///
  /// In en, this message translates to:
  /// **'One row per catalog exercise.'**
  String get exportFormatHelpExercisesDescription;

  /// Label preceding the literal (untranslated) column-name list for each CSV file.
  ///
  /// In en, this message translates to:
  /// **'Columns:'**
  String get exportFormatHelpColumnsLabel;

  /// S-16 section title for the ImportExportOperation journal list.
  ///
  /// In en, this message translates to:
  /// **'Operations log'**
  String get exportJournalTitle;

  /// Empty state for the S-16 journal.
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get exportJournalEmpty;

  /// Error state for the S-16 journal stream.
  ///
  /// In en, this message translates to:
  /// **'Failed to load the log'**
  String get exportJournalLoadError;

  /// ImportExportOperationStatus.inProgress label.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get exportStatusInProgress;

  /// ImportExportOperationStatus.success label.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get exportStatusSuccess;

  /// ImportExportOperationStatus.failed label.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get exportStatusFailed;

  /// Compact counts line on a successful S-16 journal row.
  ///
  /// In en, this message translates to:
  /// **'{workouts} workouts · {sets} sets · {measurements} measurements · {exercises} exercises'**
  String exportJournalCounts(
    int workouts,
    int sets,
    int measurements,
    int exercises,
  );
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
