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
