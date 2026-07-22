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
  String get todayStartAction => 'Начать';

  @override
  String get todayEmptyTitle => 'Тренировок пока не запланировано';

  @override
  String get todayLoadError => 'Не удалось загрузить тренировку';

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
  String get retryAction => 'Повторить';

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
  String get settingsTitle => 'Настройки';

  @override
  String get settingsShowTagsLabel => 'Показывать теги';

  @override
  String get settingsUnitSystemLabel => 'Имперские единицы';

  @override
  String get settingsUnitSystemMetric => 'Метрические (кг, см)';

  @override
  String get settingsUnitSystemImperial => 'Имперские (фунты, дюймы)';

  @override
  String get settingsThemeLabel => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsLanguageLabel => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsLanguageRu => 'Русский';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsRestTimerLabel => 'Таймер отдыха по умолчанию (сек)';

  @override
  String get settingsRestTimerRangeError =>
      'Введите значение от 10 до 600 секунд';

  @override
  String get settingsRestTimerAutoStartLabel => 'Автозапуск таймера отдыха';

  @override
  String get settingsNotificationsLabel => 'Уведомления';

  @override
  String get settingsNotificationsEnabled => 'Включены';

  @override
  String get settingsNotificationsDisabled => 'Выключены';

  @override
  String get settingsNotificationsOpenSettingsAction => 'Настройки';

  @override
  String get settingsNotificationsOpenSettingsError =>
      'Не удалось открыть системные настройки';

  @override
  String get settingsAboutLabel => 'О приложении';

  @override
  String get settingsAboutVersionLabel => 'Версия';

  @override
  String get settingsAboutExportFormatVersionLabel => 'Версия формата экспорта';

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
  String get filterClearDateFromTooltip => 'Очистить начальную дату';

  @override
  String get filterClearDateToTooltip => 'Очистить конечную дату';

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

  @override
  String get reorderDragHandleLabel => 'Перетащить, чтобы изменить порядок';

  @override
  String get workoutCommentLabel => 'Комментарий';

  @override
  String get exerciseCommentLabel => 'Комментарий';

  @override
  String get setCommentAction => 'Комментарий';

  @override
  String get setCommentTitle => 'Комментарий к подходу';

  @override
  String get setCommentLabel => 'Комментарий';

  @override
  String get deleteWorkoutAction => 'Удалить';

  @override
  String get workoutDeletedMessage => 'Тренировка удалена';

  @override
  String get undoAction => 'Отменить';

  @override
  String get deleteWorkoutError => 'Не удалось удалить тренировку';

  @override
  String get progressionDecisionLabel => 'Прогрессия:';

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
      other: '$count тренировок без роста',
      many: '$count тренировок без роста',
      few: '$count тренировки без роста',
      one: '$count тренировка без роста',
    );
    return '$_temp0';
  }

  @override
  String get historyViewCalendarTooltip => 'Вид календаря';

  @override
  String get historyViewListTooltip => 'Вид списком';

  @override
  String get historyCalendarDayEmpty => 'В этот день нет тренировок';

  @override
  String get historyCalendarPreviousMonthTooltip => 'Предыдущий месяц';

  @override
  String get historyCalendarNextMonthTooltip => 'Следующий месяц';

  @override
  String get historyCalendarDayHasWorkout => 'есть тренировка';

  @override
  String get historyCalendarDayToday => 'сегодня';

  @override
  String get workoutTimerPauseAction => 'Пауза';

  @override
  String get workoutTimerResumeAction => 'Продолжить';

  @override
  String get restTimerLabel => 'Отдых';

  @override
  String get restTimerMinus15Tooltip => '-15 с';

  @override
  String get restTimerPlus15Tooltip => '+15 с';

  @override
  String get restTimerSkipAction => 'Пропустить';

  @override
  String workoutContinuingBannerMessage(int minutes) {
    return 'Тренировка продолжается, $minutes мин';
  }

  @override
  String get continueWorkoutAction => 'Продолжить';

  @override
  String get finishWithIncompleteSetsTitle => 'Завершить тренировку?';

  @override
  String get finishWithIncompleteSetsMessage =>
      'Отметить оставшиеся подходы невыполненными и завершить?';

  @override
  String get notificationPermissionRationaleTitle => 'Включить уведомления?';

  @override
  String get notificationPermissionRationaleMessage =>
      'Получайте уведомление, когда время отдыха между подходами закончится, даже если приложение свёрнуто.';

  @override
  String get notificationPermissionNotNowAction => 'Не сейчас';

  @override
  String get notificationPermissionAllowAction => 'Разрешить';

  @override
  String get restTimerNotificationTitle => 'Таймер отдыха';

  @override
  String get restTimerNotificationBody => 'Отдых окончен — следующий подход';

  @override
  String get notificationsOffHint => 'Уведомления выключены';

  @override
  String get workoutSummaryTitle => 'Итог тренировки';

  @override
  String get workoutSummaryDurationLabel => 'Длительность';

  @override
  String get workoutSummaryExercisesLabel => 'Упражнения';

  @override
  String get workoutSummarySetsLabel => 'Подходы';

  @override
  String get workoutSummaryTonnageLabel => 'Тоннаж';

  @override
  String workoutSummaryTonnageValue(String value) {
    return '$value кг';
  }

  @override
  String get workoutSummaryNewRecordsTitle => 'Новые рекорды';

  @override
  String get workoutSummaryDoneAction => 'Готово';

  @override
  String get templatesTitle => 'Шаблоны';

  @override
  String get templatesEmptyTitle => 'Шаблонов пока нет';

  @override
  String get templatesLoadError => 'Не удалось загрузить шаблоны';

  @override
  String templateExerciseCount(int count) {
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
  String get createTemplateAction => 'Создать шаблон';

  @override
  String get createTemplateTitle => 'Новый шаблон';

  @override
  String get createTemplateError => 'Не удалось создать шаблон';

  @override
  String get templateNameLabel => 'Название';

  @override
  String get templateEditorTitle => 'Шаблон';

  @override
  String get templateCommentLabel => 'Комментарий';

  @override
  String get templateLoadError => 'Не удалось загрузить шаблон';

  @override
  String get templateExercisesEmpty => 'Пока нет упражнений';

  @override
  String get archiveTemplateAction => 'Архивировать';

  @override
  String get unarchiveTemplateAction => 'Разархивировать';

  @override
  String get archiveTemplateError => 'Не удалось обновить шаблон';

  @override
  String get deleteTemplateAction => 'Удалить';

  @override
  String get templateDeletedMessage => 'Шаблон удалён';

  @override
  String get deleteTemplateError => 'Не удалось удалить шаблон';

  @override
  String get createTemplateFromWorkoutAction => 'Создать шаблон';

  @override
  String get createWorkoutFromTemplateAction => 'Создать тренировку';

  @override
  String get createWorkoutFromTemplateError => 'Не удалось создать тренировку';

  @override
  String get templateSourcePickerTitle => 'Создать из шаблона...';

  @override
  String get templateSourcePickerEmpty =>
      'Пока нет шаблонов, из которых можно создать тренировку';

  @override
  String get duplicateTemplateAction => 'Дублировать';

  @override
  String get duplicateTemplateTitle => 'Дублировать шаблон';

  @override
  String get measurementsTitle => 'Измерения';

  @override
  String get measurementTypeBodyWeight => 'Вес тела';

  @override
  String get measurementTypeBodyFat => '% жира';

  @override
  String get measurementTypeNeck => 'Шея';

  @override
  String get measurementTypeShouldersGirth => 'Плечи';

  @override
  String get measurementTypeChestGirth => 'Грудь';

  @override
  String get measurementTypeWaist => 'Талия';

  @override
  String get measurementTypeHips => 'Бёдра';

  @override
  String get measurementTypeBicepsLeft => 'Бицепс (левый)';

  @override
  String get measurementTypeBicepsRight => 'Бицепс (правый)';

  @override
  String get measurementTypeForearmLeft => 'Предплечье (левое)';

  @override
  String get measurementTypeForearmRight => 'Предплечье (правое)';

  @override
  String get measurementTypeThighLeft => 'Бедро (левое)';

  @override
  String get measurementTypeThighRight => 'Бедро (правое)';

  @override
  String get measurementTypeCalfLeft => 'Голень (левая)';

  @override
  String get measurementTypeCalfRight => 'Голень (правая)';

  @override
  String get measurementUnitKindMass => 'Вес (кг/фунты)';

  @override
  String get measurementUnitKindPercent => 'Процент (%)';

  @override
  String get measurementUnitKindLength => 'Длина (см/дюймы)';

  @override
  String get unitKg => 'кг';

  @override
  String get unitLb => 'фунт';

  @override
  String get unitCm => 'см';

  @override
  String get unitIn => 'дюйм';

  @override
  String get measurementsTabWeight => 'Вес';

  @override
  String get measurementsTabBodyFat => '% жира';

  @override
  String get measurementsTabMeasurements => 'Замеры';

  @override
  String get measurementsTabCustom => 'Свои';

  @override
  String get measurementsEmptyState => 'Пока нет записей';

  @override
  String get measurementsLoadError => 'Не удалось загрузить измерения';

  @override
  String get measurementGirthSelectorLabel => 'Замер';

  @override
  String get addCustomMeasurementTypeAction => 'Добавить замер…';

  @override
  String get measurementsCustomEmptyState => 'Пока нет своих типов измерений';

  @override
  String get createMeasurementTypeTitle => 'Новый тип измерения';

  @override
  String get measurementTypeNameLabel => 'Название';

  @override
  String get measurementTypeUnitKindLabel => 'Единица';

  @override
  String get createMeasurementTypeError => 'Не удалось создать тип измерения';

  @override
  String get archiveMeasurementTypeAction => 'Архивировать';

  @override
  String get unarchiveMeasurementTypeAction => 'Разархивировать';

  @override
  String get archiveMeasurementTypeError => 'Не удалось обновить тип измерения';

  @override
  String get deleteMeasurementTypeAction => 'Удалить';

  @override
  String get deleteMeasurementTypeError => 'Не удалось удалить тип измерения';

  @override
  String get deleteMeasurementTypeConfirmTitle => 'Удалить тип измерения?';

  @override
  String get deleteMeasurementTypeConfirmMessage =>
      'Тип измерения будет удалён без возможности восстановления.';

  @override
  String get measurementEntryDeletedMessage => 'Запись удалена';

  @override
  String get deleteMeasurementEntryAction => 'Удалить';

  @override
  String get measurementFormTitle => 'Новое измерение';

  @override
  String get measurementTypeFieldLabel => 'Тип';

  @override
  String get measurementDateFieldLabel => 'Дата';

  @override
  String get measurementValueFieldLabel => 'Значение';

  @override
  String get measurementCommentFieldLabel => 'Комментарий';

  @override
  String get measurementValueRequiredError => 'Введите значение';

  @override
  String get saveMeasurementError => 'Не удалось сохранить измерение';

  @override
  String get replaceMeasurementConfirmTitle =>
      'Заменить существующее значение?';

  @override
  String replaceMeasurementConfirmMessage(String value, String unit) {
    return 'За этот день уже есть запись: $value $unit. Заменить её новым значением?';
  }

  @override
  String get replaceMeasurementConfirmAction => 'Заменить';

  @override
  String get addMeasurementEntryAction => 'Добавить измерение';

  @override
  String get statsWeightCardTitle => 'Вес тела';

  @override
  String get statsBodyFatCardTitle => '% жира';

  @override
  String get statsMeasurementsCardTitle => 'Замеры';

  @override
  String get statsPeriodWeek => 'Нед';

  @override
  String get statsPeriodMonth => 'Мес';

  @override
  String get statsPeriodThreeMonths => '3М';

  @override
  String get statsPeriodYear => 'Год';

  @override
  String get statsPeriodAllTime => 'Всё';

  @override
  String get statsPeriodCustom => 'Свой';

  @override
  String get statsEmptyPeriod => 'Нет записей за этот период';

  @override
  String get statsWorkoutsCardTitle => 'Тренировки';

  @override
  String get statsWorkoutsCountLabel => 'Тренировок';

  @override
  String get statsWorkoutsFrequencyLabel => 'Частота';

  @override
  String statsWorkoutsFrequencyValue(String value) {
    return '$value / нед.';
  }

  @override
  String get statsExerciseProgressCardTitle => 'Прогресс по упражнению';

  @override
  String get statsExerciseProgressSearchAction => 'Выбрать упражнение';

  @override
  String get exerciseProgressPickerTitle => 'Выбор упражнения';

  @override
  String get exerciseProgressLoadError => 'Не удалось загрузить упражнение';

  @override
  String get recordTypeMaxWeight => 'Макс. вес';

  @override
  String get recordTypeMax1RM => 'Расчётный 1ПМ';

  @override
  String get recordTypeMaxVolumeWorkout => 'Тоннаж тренировки';

  @override
  String get recordTypeMaxDistance => 'Макс. дистанция';

  @override
  String get recordTypeBestPace => 'Лучший темп';

  @override
  String get recordTypeLongestDuration => 'Наибольшая длительность';

  @override
  String get statsEstimatedBadge => 'расчётный';

  @override
  String get statsRecordsSectionTitle => 'Рекорды';

  @override
  String get statsRecordsEmptyState => 'Пока нет рекордов';

  @override
  String get statsRepsAtWeightTableTitle => 'Повторения при весе';

  @override
  String get statsRepsAtWeightWeightColumn => 'Вес';

  @override
  String get statsRepsAtWeightRepsColumn => 'Повторения';

  @override
  String get statsRepsAtWeightDateColumn => 'Дата';

  @override
  String statsKgValue(String value) {
    return '$value кг';
  }

  @override
  String statsKmValue(String value) {
    return '$value км';
  }

  @override
  String statsPaceValue(String value) {
    return '$value / км';
  }

  @override
  String get exportScreenTitle => 'Импорт/экспорт';

  @override
  String get exportAction => 'Экспортировать данные (CSV)';

  @override
  String get exportError => 'Не удалось экспортировать данные';

  @override
  String get importAction => 'Импорт';

  @override
  String get importComingSoonLabel => 'Появится в следующих версиях';

  @override
  String get exportFormatHelpAction => 'Описание формата CSV';

  @override
  String get exportFormatHelpTitle => 'Описание формата CSV';

  @override
  String get exportFormatHelpIntro =>
      'Экспорт создаёт ZIP-архив с тремя CSV-файлами и manifest.json. Кодировка UTF-8 с BOM (открывается в Excel и Google Таблицах без искажений кириллицы). Разделитель — запятая, значения всегда в метрических единицах независимо от настройки единиц измерения. Даты — в формате ГГГГ-ММ-ДД. Экспортируются только неудалённые данные; заархивированные упражнения экспортируются, так как на них ссылается история тренировок.';

  @override
  String get exportFormatHelpManifestTitle => 'manifest.json';

  @override
  String get exportFormatHelpManifestDescription =>
      'Версия формата, версия приложения, время экспорта и число строк в каждом файле.';

  @override
  String get exportFormatHelpWorkoutsDescription =>
      'Одна строка на подход. Тренировка без упражнений или упражнение без подходов — отдельная строка с пустыми полями.';

  @override
  String get exportFormatHelpMeasurementsDescription =>
      'Одна строка на запись измерения.';

  @override
  String get exportFormatHelpExercisesDescription =>
      'Одна строка на упражнение из каталога.';

  @override
  String get exportFormatHelpColumnsLabel => 'Колонки:';

  @override
  String get exportJournalTitle => 'Журнал операций';

  @override
  String get exportJournalEmpty => 'Пока нет операций';

  @override
  String get exportJournalLoadError => 'Не удалось загрузить журнал';

  @override
  String get exportStatusInProgress => 'Выполняется';

  @override
  String get exportStatusSuccess => 'Успешно';

  @override
  String get exportStatusFailed => 'Ошибка';

  @override
  String exportJournalCounts(
    int workouts,
    int sets,
    int measurements,
    int exercises,
  ) {
    return '$workouts трен. · $sets подх. · $measurements изм. · $exercises упр.';
  }
}
