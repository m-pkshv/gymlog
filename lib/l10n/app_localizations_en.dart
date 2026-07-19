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
}
