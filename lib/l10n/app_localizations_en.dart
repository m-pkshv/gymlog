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
}
