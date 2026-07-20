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

  @override
  String get newWorkoutAction => 'Новая тренировка';

  @override
  String get workoutEditorTitle => 'Тренировка';

  @override
  String get workoutLoadError => 'Не удалось загрузить тренировку';

  @override
  String get workoutStatusChangeError => 'Не удалось обновить тренировку';

  @override
  String get statusDraft => 'Черновик';

  @override
  String get statusInProgress => 'Выполняется';

  @override
  String get statusCompleted => 'Завершена';

  @override
  String get statusPlanned => 'Запланирована';

  @override
  String get statusSkipped => 'Пропущена';

  @override
  String get statusCancelled => 'Отменена';

  @override
  String get transitionScheduleAction => 'Запланировать';

  @override
  String get transitionResumeAction => 'Возобновить';

  @override
  String get transitionCancelAction => 'Отменить';

  @override
  String get transitionSkipAction => 'Пропустить';

  @override
  String get transitionBackToPlanAction => 'Вернуть в план';

  @override
  String get transitionBackToDraftAction => 'Вернуть в черновик';

  @override
  String get activeWorkoutConflictTitle => 'Уже есть активная тренировка';

  @override
  String get activeWorkoutConflictMessage =>
      'Одновременно может выполняться только одна тренировка. Сначала завершите или отмените текущую активную тренировку.';

  @override
  String get activeWorkoutConflictCancelOtherAction => 'Отменить её';

  @override
  String get activeWorkoutConflictFinishOtherAction => 'Завершить её';

  @override
  String get startWorkoutAction => 'Начать тренировку';

  @override
  String get finishWorkoutAction => 'Завершить';

  @override
  String get addExerciseAction => 'Добавить упражнение';

  @override
  String get addSetAction => 'Добавить подход';

  @override
  String get workoutExercisesEmpty => 'Пока нет упражнений';

  @override
  String get setColumnNumber => '№';

  @override
  String get setColumnWarmup => 'Разминка';

  @override
  String get setColumnPlan => 'План';

  @override
  String get setColumnFact => 'Факт';

  @override
  String get setColumnDone => 'Выполнено';

  @override
  String get setFieldWeightKg => 'Вес, кг';

  @override
  String get setFieldReps => 'Повторения';

  @override
  String get setFieldDistanceKm => 'Дистанция, км';

  @override
  String get setFieldDurationSec => 'Время, с';

  @override
  String get historyEmptyTitle => 'Завершённых тренировок пока нет';

  @override
  String get historyLoadError => 'Не удалось загрузить историю';

  @override
  String get workoutDefaultNamePrefix => 'Тренировка';

  @override
  String workoutExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count упражнений',
      many: '$count упражнений',
      few: '$count упражнения',
      one: '$count упражнение',
    );
    return '$_temp0';
  }

  @override
  String workoutDurationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get muscleGroupChest => 'Грудь';

  @override
  String get muscleGroupBack => 'Спина';

  @override
  String get muscleGroupShoulders => 'Плечи';

  @override
  String get muscleGroupRearDelts => 'Задние дельты';

  @override
  String get muscleGroupBiceps => 'Бицепс';

  @override
  String get muscleGroupTriceps => 'Трицепс';

  @override
  String get muscleGroupForearms => 'Предплечья';

  @override
  String get muscleGroupAbs => 'Пресс';

  @override
  String get muscleGroupObliques => 'Косые мышцы';

  @override
  String get muscleGroupHipFlexors => 'Сгибатели бедра';

  @override
  String get muscleGroupGlutes => 'Ягодицы';

  @override
  String get muscleGroupQuads => 'Квадрицепсы';

  @override
  String get muscleGroupAdductors => 'Приводящие мышцы';

  @override
  String get muscleGroupHamstrings => 'Бицепс бедра';

  @override
  String get muscleGroupCalves => 'Икры';

  @override
  String get muscleGroupFullBody => 'Всё тело';

  @override
  String get muscleGroupCardioSystem => 'Кардио';

  @override
  String get equipmentBarbell => 'Штанга';

  @override
  String get equipmentDumbbell => 'Гантели';

  @override
  String get equipmentKettlebell => 'Гиря';

  @override
  String get equipmentMachine => 'Тренажёр';

  @override
  String get equipmentCable => 'Блочный тренажёр';

  @override
  String get equipmentBodyweight => 'Свой вес';

  @override
  String get equipmentBand => 'Резинка-эспандер';

  @override
  String get equipmentCardioMachine => 'Кардиотренажёр';

  @override
  String get equipmentOther => 'Другое';

  @override
  String get effortMetricNone => 'Нет';

  @override
  String get effortMetricRpe => 'RPE';

  @override
  String get effortMetricRir => 'RIR';

  @override
  String get exercisePrimaryMuscleLabel => 'Основная группа мышц';

  @override
  String get exerciseSecondaryMusclesLabel => 'Дополнительные группы мышц';

  @override
  String get exerciseEquipmentLabel => 'Оборудование';

  @override
  String get exerciseEffortMetricLabel => 'Метрика усилия';

  @override
  String get exerciseDescriptionLabel => 'Описание';

  @override
  String get exerciseYoutubeUrlLabel => 'Ссылка на YouTube';

  @override
  String get exerciseYoutubeUrlWarning => 'Не похоже на ссылку YouTube';

  @override
  String get exerciseNotSpecified => 'Не указано';

  @override
  String get exerciseDetailLoadError => 'Не удалось загрузить упражнение';

  @override
  String get exerciseAboutTab => 'О упражнении';

  @override
  String get exerciseHistoryTab => 'История';

  @override
  String get exerciseHistoryEmpty =>
      'Пока нет завершённых тренировок с этим упражнением';

  @override
  String get exerciseArchivedBadge => 'В архиве';

  @override
  String get archiveExerciseAction => 'Архивировать';

  @override
  String get unarchiveExerciseAction => 'Разархивировать';

  @override
  String get deleteExerciseAction => 'Удалить';

  @override
  String get deleteExerciseConfirmTitle => 'Удалить упражнение?';

  @override
  String get deleteExerciseConfirmMessage => 'Это действие необратимо.';

  @override
  String get deleteExerciseError => 'Не удалось удалить упражнение';

  @override
  String get archiveExerciseError => 'Не удалось обновить упражнение';

  @override
  String get editExerciseTitle => 'Редактировать упражнение';

  @override
  String get editExerciseAction => 'Редактировать';

  @override
  String get editExerciseError => 'Не удалось сохранить упражнение';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get exerciseTypeLockedHint =>
      'Нельзя изменить: уже есть выполненные подходы';

  @override
  String get searchExercisesHint => 'Поиск по названию';

  @override
  String get filterExercisesTooltip => 'Фильтры';

  @override
  String get filtersTitle => 'Фильтры';

  @override
  String get filterAnyType => 'Любой тип';

  @override
  String get filterMuscleGroupLabel => 'Группа мышц';

  @override
  String get filterAnyMuscleGroup => 'Любая группа мышц';

  @override
  String get filterAnyEquipment => 'Любое оборудование';

  @override
  String get filterShowArchived => 'Показывать архивные';

  @override
  String get filterOnlyUserCreated => 'Только пользовательские';

  @override
  String get filterResetAction => 'Сбросить';

  @override
  String get filterApplyAction => 'Применить';

  @override
  String get exercisesSearchEmptyTitle => 'Ничего не найдено';

  @override
  String get resetFiltersAction => 'Сбросить фильтры';

  @override
  String get pastResultsAction => 'Прошлые результаты';

  @override
  String get pastResultsTitle => 'Прошлые результаты';

  @override
  String get pastResultsEmpty =>
      'Пока нет завершённых выполнений этого упражнения';

  @override
  String get pastResultsLoadError => 'Не удалось загрузить прошлые результаты';

  @override
  String get copyLastPerformanceAction =>
      'Копировать показатели прошлого выполнения';

  @override
  String get copyLastPerformanceEmpty =>
      'Нет прошлых результатов для копирования';

  @override
  String get workoutTagsAddAction => 'Добавить тег';

  @override
  String get workoutTagsSheetTitle => 'Теги тренировки';

  @override
  String get workoutTagsEmpty => 'Тегов пока нет';

  @override
  String get workoutTagsLoadError => 'Не удалось загрузить теги';

  @override
  String get createTagAction => 'Создать тег';

  @override
  String get createTagTitle => 'Новый тег';

  @override
  String get createTagError => 'Не удалось создать тег';

  @override
  String get tagNameLabel => 'Название';

  @override
  String get settingsShowTagsLabel => 'Показывать теги';

  @override
  String get settingsLoadError => 'Не удалось загрузить настройки';

  @override
  String get copyWorkoutAction => 'Копировать';

  @override
  String get copyWorkoutError => 'Не удалось скопировать тренировку';

  @override
  String get newWorkoutFromScratchAction => 'С нуля';

  @override
  String get newWorkoutFromCopyAction => 'Копией';

  @override
  String get newWorkoutFromTemplateAction => 'Из шаблона';

  @override
  String get comingSoonLabel => 'Скоро';

  @override
  String get copySourcePickerTitle => 'Копировать из…';

  @override
  String get copySourcePickerEmpty =>
      'Пока нет завершённых тренировок для копирования';

  @override
  String get filterWorkoutsTooltip => 'Фильтры';

  @override
  String get searchHistoryHint => 'Поиск по названию';

  @override
  String get filterDateFromLabel => 'С';

  @override
  String get filterDateToLabel => 'По';

  @override
  String get filterAnyDate => 'Любая дата';

  @override
  String get filterStatusesLabel => 'Статусы';

  @override
  String get filterTagsLabel => 'Теги';

  @override
  String get historySearchEmptyTitle => 'Ничего не найдено';

  @override
  String get moveExerciseUpAction => 'Переместить вверх';

  @override
  String get moveExerciseDownAction => 'Переместить вниз';
}
