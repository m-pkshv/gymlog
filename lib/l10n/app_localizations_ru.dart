// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GymLog';

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabHistory => 'История';

  @override
  String get tabExercises => 'Упражнения';

  @override
  String get tabStats => 'Статистика';

  @override
  String get tabMore => 'Ещё';

  @override
  String get exercisesEmptyTitle => 'Упражнений пока нет';

  @override
  String get exercisesLoadError => 'Не удалось загрузить упражнения';

  @override
  String get createExerciseAction => 'Создать упражнение';

  @override
  String get createExerciseTitle => 'Новое упражнение';

  @override
  String get exerciseNameLabel => 'Название';

  @override
  String get exerciseNameRequiredError => 'Введите название';

  @override
  String get exerciseTypeLabel => 'Тип';

  @override
  String get exerciseTypeStrength => 'Силовое';

  @override
  String get exerciseTypeCardio => 'Кардио';

  @override
  String get exerciseTypeReps => 'На повторения';

  @override
  String get exerciseTypeTime => 'На время';

  @override
  String get exerciseTypeStretch => 'Растяжка';

  @override
  String get createExerciseError => 'Не удалось создать упражнение';

  @override
  String get actionCreate => 'Создать';

  @override
  String get actionCancel => 'Отмена';
}
