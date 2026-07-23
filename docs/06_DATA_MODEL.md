# 06_DATA_MODEL — Модель данных

## 1. Назначение документа
Единственный источник истины по структуре данных: сущности, поля, типы, обязательность, единицы, значения по умолчанию, связи, правила валидации, удаления и миграций, начальные данные (сиды). Реализуется в SQLite через `drift` (D-2). Термины — `01_PROJECT_OVERVIEW.md`, раздел 8; решения D-x — там же, раздел 6.

## 2. Область ответственности
Схема БД и правила целостности. Не входит: бизнес-формулы статистики (`03_TECHNICAL_SPEC.md`, раздел 9), формат CSV (`03_TECHNICAL_SPEC.md`, раздел 10), UI (`04_UI_UX_SPEC.md`).

## 3. Общие соглашения (применяются ко всем сущностям, если не указано иное)
- **Идентификаторы**: `id TEXT PRIMARY KEY` — UUID v4, генерируется приложением (D-13).
- **Служебные поля** каждой таблицы пользовательских данных: `createdAt TEXT NOT NULL` и `updatedAt TEXT NOT NULL` — UTC, ISO 8601 (`2026-07-19T14:03:00Z`); `isDeleted INTEGER NOT NULL DEFAULT 0` — мягкое удаление (0/1). Справочные таблицы-перечисления служебных полей не имеют.
- **Булевы** — `INTEGER` 0/1. **Enum** — `TEXT` со значением из фиксированного списка (валидация на уровне приложения + `CHECK` в SQL).
- **Единицы хранения** (D-5): масса — кг (`REAL`), дистанция — метры (`REAL`), длительность — секунды (`INTEGER`), замеры — см (`REAL`), пульс — уд/мин (`INTEGER`), наклон — % (`REAL`), сопротивление — безразмерный уровень (`REAL`).
- **Даты-«дни»** (дата тренировки, дата измерения) — `TEXT` `YYYY-MM-DD` в локальном времени пользователя. Моменты времени — UTC ISO 8601.
- Все запросы чтения по умолчанию фильтруют `isDeleted = 0`.
- Внешние ключи включены (`PRAGMA foreign_keys = ON`).

## 4. Перечисления (enum)
| Enum | Значения |
|---|---|
| `ExerciseType` | `strength`, `cardio`, `reps`, `time`, `stretch` |
| `WorkoutStatus` | `draft`, `planned`, `inProgress`, `completed`, `skipped`, `cancelled` |
| `ProgressionDecision` | `none` (по умолчанию), `increase`, `repeat`, `decrease` |
| `BodySide` | `none`, `left`, `right`, `both` |
| `MeasurementSource` | `manual` (MVP), зарезервировано: `import`, `health` |
| `RecordType` | `maxWeight`, `maxRepsAtWeight`, `max1RM`, `maxVolumeWorkout`, `maxDistance`, `bestPace`, `longestDuration` |
| `OperationType` | `export` (MVP), зарезервировано: `import` |
| `OperationStatus` | `inProgress`, `success`, `failed` |
| `UnitSystem` | `metric`, `imperial` |
| `AppTheme` | `system`, `light`, `dark` |
| `AppLocale` | `system`, `ru`, `en` |
| `EffortMetric` | `none`, `rpe`, `rir` |

### 4.1. Метрики подхода по типам упражнений (D-14)
| Тип | Метрики подхода (план/факт) | В статистике участвуют |
|---|---|---|
| `strength` | вес (кг), повторения, опционально RPE или RIR | вес, повторения, объём, 1ПМ |
| `cardio` | длительность, дистанция, сопротивление, наклон, средний пульс; скорость и темп **не хранятся** — вычисляются | длительность, дистанция, темп |
| `reps` | повторения, опционально доп. вес (кг) | повторения, вес |
| `time` | длительность | длительность |
| `stretch` | длительность, сторона тела | длительность |

«Количество подходов» всюду выражается числом записей `ExerciseSet`, отдельного поля нет.

## 5. Справочники (сид-таблицы, редактирование пользователем недоступно в MVP)

### 5.1. `MuscleGroup`
| Поле | Тип | Обяз. | Описание |
|---|---|---|---|
| id | TEXT PK | да | Стабильный слаг: `chest`, `back`, `shoulders`, `rear_delts`, `biceps`, `triceps`, `forearms`, `abs`, `obliques`, `hip_flexors`, `glutes`, `quads`, `adductors`, `hamstrings`, `calves`, `full_body`, `cardio_system` |
| sortOrder | INTEGER | да | Порядок в фильтрах |
Локализованные названия — в ARB-файлах по ключу `muscleGroup.<id>`, не в БД.
`rear_delts`/`obliques`/`hip_flexors`/`adductors` добавлены на Этапе 2 (2026-07-20) при импорте полного списка упражнений владельца (Q-1): исходно 13 групп не покрывали часть упражнений, где эти мышцы — основная (не дополнительная) группа, и их нельзя было без потери информации свести к более широким категориям. Решение владельца.

### 5.2. `Equipment`
Аналогично: `barbell`, `dumbbell`, `kettlebell`, `machine`, `cable`, `bodyweight`, `band`, `cardio_machine`, `other`. Поля: `id`, `sortOrder`; названия в ARB.

### 5.3. `MeasurementType`
| Поле | Тип | Обяз. | Описание |
|---|---|---|---|
| id | TEXT PK | да | UUID для пользовательских; стабильный слаг для встроенных |
| nameCustom | TEXT | нет | Название пользовательского типа (для встроенных NULL, имя из ARB) |
| unitKind | TEXT | да | `mass` (кг) / `percent` / `length` (см) |
| isBuiltIn | INTEGER | да | 1 — встроенный |
| isArchived | INTEGER | да, def 0 | Скрытие пользовательского типа |
| sortOrder | INTEGER | да | |
Встроенные типы (сид): `body_weight` (mass), `body_fat` (percent), и length-замеры: `neck`, `shoulders_girth`, `chest_girth`, `waist`, `hips`, `biceps_left`, `biceps_right`, `forearm_left`, `forearm_right`, `thigh_left`, `thigh_right`, `calf_left`, `calf_right`.
Валидация: `nameCustom` обязателен и непуст для пользовательских (1–60 симв., уникален среди неархивных без учёта регистра).

## 6. Основные сущности

### 6.1. `Exercise`
| Поле | Тип | Обяз. | Умолч. | Описание / валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | Для встроенных — стабильный слаг из сида (нужно для обновления сида при апдейтах приложения) |
| name | TEXT | да | — | 1–80 симв. после trim; единственное обязательное поле пользовательского упражнения. Уникальность не требуется; при совпадении с существующим — неблокирующее предупреждение в UI |
| description | TEXT | нет | NULL | ≤ 2000 симв. |
| youtubeUrl | TEXT | нет | NULL | Валидация: http/https URL хоста youtube.com / youtu.be; иначе — предупреждение, сохранение разрешено |
| imageAsset | TEXT | нет | NULL | Путь к ассету; заполняется только для встроенных (D-3) |
| exerciseType | TEXT enum | да | — | Из `ExerciseType`. **Неизменяем после создания**, если по упражнению есть хоть один подход в истории (иначе метрики истории потеряют смысл); UI блокирует смену с пояснением |
| primaryMuscleGroupId | TEXT FK→MuscleGroup | нет | NULL | |
| equipmentId | TEXT FK→Equipment | нет | NULL | |
| effortMetric | TEXT enum | да | `none` | Для `strength`: какая метрика усилия доступна — `none`/`rpe`/`rir` |
| statsMetricsJson | TEXT | нет | NULL | Зарезервировано (D-14); в MVP не читается — набор метрик статистики определяется типом |
| isBuiltIn | INTEGER | да | 0 | |
| isArchived | INTEGER | да | 0 | |
| createdAt / updatedAt / isDeleted | | | | По разделу 3 |

### 6.2. `ExerciseSecondaryMuscle` (связь M:N)
`exerciseId TEXT FK→Exercise`, `muscleGroupId TEXT FK→MuscleGroup`, PK — пара. Каскадное удаление вместе с упражнением (физическое удаление возможно только для пользовательских, не использованных в истории — раздел 10).

### 6.3. `WorkoutTag`
| Поле | Тип | Обяз. | Умолч. | Валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | |
| name | TEXT | да | — | 1–30 симв., уникально среди неудалённых без учёта регистра |
| colorHex | TEXT | да | `#4C7BD9` | `#RRGGBB`; палитра — `04_UI_UX_SPEC.md`, раздел 9 |
| isHidden | INTEGER | да | 0 | Скрытие в настройках; данные и привязки сохраняются (ТЗ) |
| createdAt / updatedAt / isDeleted | | | | |

### 6.4. `Workout`
| Поле | Тип | Обяз. | Умолч. | Валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | |
| date | TEXT `YYYY-MM-DD` | да | сегодня | Дата проведения/плана |
| name | TEXT | нет | NULL | ≤ 80 симв.; при NULL UI показывает «Тренировка + дата» |
| status | TEXT enum | да | `draft` | Переходы — раздел 6.4.1 |
| comment | TEXT | нет | NULL | ≤ 2000 симв. |
| startedAt | TEXT UTC | нет | NULL | Момент старта активного режима |
| finishedAt | TEXT UTC | нет | NULL | Момент завершения |
| actualDurationSec | INTEGER | нет | NULL | Фактическая длительность; ≥ 0; учитывает паузы (см. `03`, раздел 7) |
| createdAt / updatedAt / isDeleted | | | | |

#### 6.4.1. Диаграмма статусов (D-15)
Разрешённые переходы (все остальные запрещены на уровне сервиса):
- `draft` → `planned` (действие «Запланировать»), `draft` → `inProgress` («Начать»), `draft` → удаление.
- `planned` → `inProgress`, `planned` → `skipped` (вручную или предложением UI, автоматической смены нет), `planned` → `cancelled`, `planned` → `draft`.
- `inProgress` → `completed` («Завершить»), `inProgress` → `cancelled`. Инвариант: не более одной тренировки в `inProgress`; попытка начать вторую → диалог «Завершить/отменить текущую?».
- `completed` → `inProgress` («Возобновить», в течение 24 ч после `finishedAt`; предположение — подтвердить).
- `skipped`/`cancelled` → `planned` («Вернуть в план»).
Перенос на другую дату меняет `date` и допустим в любом статусе, кроме `inProgress`.

### 6.5. `WorkoutTagLink` (M:N)
`workoutId FK→Workout`, `tagId FK→WorkoutTag`, PK — пара.

### 6.6. `WorkoutExercise`
| Поле | Тип | Обяз. | Умолч. | Валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | |
| workoutId | TEXT FK→Workout | да | — | |
| exerciseId | TEXT FK→Exercise | да | — | Одно и то же упражнение может входить в тренировку несколько раз (суперсеты) |
| orderIndex | INTEGER | да | max+1 | Непрерывность не требуется; сортировка по значению |
| comment | TEXT | нет | NULL | ≤ 1000 симв. |
| progressionDecision | TEXT enum | да | `none` | Решение для следующей тренировки |
| createdAt / updatedAt / isDeleted | | | | |

### 6.7. `ExerciseSet`
Одна таблица с nullable-колонками под все типы (D-14). Приложение показывает/валидирует только колонки, соответствующие `exerciseType` упражнения. Понятие «разминочный подход» (`isWarmup`) удалено из приложения (Этап 10, 2026-07-23, решение владельца) — все подходы равноценны и учитываются в статистике/рекордах/прогрессии/тоннаже одинаково; колонка удалена схемной миграцией v1→v2 (раздел 11.1).

| Поле | Тип | Обяз. | Умолч. | Единицы / валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | |
| workoutExerciseId | TEXT FK→WorkoutExercise | да | — | |
| setNumber | INTEGER | да | max+1 | ≥ 1; перенумерация при удалении — на уровне сервиса |
| isCompleted | INTEGER | да | 0 | Отметка выполнения |
| plannedWeightKg | REAL | нет | NULL | 0–1000; шаг ввода 0.25 кг / 0.5 lb |
| plannedReps | INTEGER | нет | NULL | 0–1000 |
| actualWeightKg | REAL | нет | NULL | 0–1000 |
| actualReps | INTEGER | нет | NULL | 0–1000 |
| rpe | REAL | нет | NULL | 1–10, шаг 0.5; заполняется, если `effortMetric = rpe` |
| rir | INTEGER | нет | NULL | 0–10; если `effortMetric = rir`; одновременное заполнение rpe и rir запрещено |
| plannedDurationSec / actualDurationSec | INTEGER | нет | NULL | 0–86400 |
| plannedDistanceM / actualDistanceM | REAL | нет | NULL | 0–1 000 000 |
| resistance | REAL | нет | NULL | 0–100 |
| inclinePercent | REAL | нет | NULL | −10–40 |
| avgHeartRate | INTEGER | нет | NULL | 30–250 |
| side | TEXT enum | да | `none` | Только для `stretch` |
| comment | TEXT | нет | NULL | ≤ 500 симв. |
| createdAt / updatedAt / isDeleted | | | | |

Правило «выполненности»: при `isCompleted = 1` и пустых фактических значениях сервис копирует плановые в фактические (поведение «выполнил как запланировано»). Отметка снимается — скопированные значения остаются (пользователь может править).

### 6.8. Шаблоны (D-16)
**`WorkoutTemplate`**: `id`, `name` (обяз., 1–80), `comment` (≤2000), `isArchived` (def 0), служебные поля.
**`TemplateExercise`**: `id`, `templateId FK`, `exerciseId FK`, `orderIndex`, `comment`, служебные.
**`TemplateSet`**: `id`, `templateExerciseId FK`, `setNumber`, только плановые метрики (`plannedWeightKg`, `plannedReps`, `plannedDurationSec`, `plannedDistanceM`, `side`), служебные.
Создание тренировки из шаблона копирует структуру в `Workout/WorkoutExercise/ExerciseSet` (плановые поля), связь с шаблоном не хранится (предположение; при необходимости аналитики «сколько раз использован шаблон» добавить `sourceTemplateId` в `Workout` — решение владельца).

### 6.9. `BodyMeasurement`
| Поле | Тип | Обяз. | Умолч. | Валидация |
|---|---|---|---|---|
| id | TEXT PK | да | UUID | |
| measurementTypeId | TEXT FK→MeasurementType | да | — | |
| date | TEXT `YYYY-MM-DD` | да | сегодня | Не более одной записи на тип в день: при совпадении — предложение заменить |
| valueMetric | REAL | да | — | mass: 20–400 кг; percent: 1–75; length: 1–300 см |
| source | TEXT enum | да | `manual` | |
| comment | TEXT | нет | NULL | ≤ 500 симв. |
| createdAt / updatedAt / isDeleted | | | | |

### 6.10. `PersonalRecord` (кэш, D-8)
Не является источником истины; полностью перестраивается из истории.
| Поле | Тип | Описание |
|---|---|---|
| exerciseId | TEXT FK→Exercise | |
| recordType | TEXT enum | Из `RecordType` |
| keyValue | REAL | Для `maxRepsAtWeight` — вес (кг), иначе NULL |
| value | REAL | Значение рекорда в метрических единицах |
| workoutId | TEXT FK→Workout | Тренировка-источник |
| exerciseSetId | TEXT FK→ExerciseSet | Подход-источник (NULL для `maxVolumeWorkout`) |
| achievedAt | TEXT `YYYY-MM-DD` | Дата тренировки |
| computedAt | TEXT UTC | Момент пересчёта |
PK: (`exerciseId`, `recordType`, `keyValue`). Триггеры пересчёта: завершение/возобновление/удаление тренировки, изменение подхода завершённой тренировки, архивация упражнения — пересчёт затронутого `exerciseId`. Источник — только рабочие подходы завершённых (`completed`) тренировок с `isCompleted = 1`.

### 6.11. `ExerciseProgressionState` (кэш счётчика стагнации, D-7)
| Поле | Тип | Описание |
|---|---|---|
| exerciseId | TEXT PK FK→Exercise | |
| stagnationCount | INTEGER | Число последовательных завершённых тренировок без роста |
| lastCountedWorkoutId | TEXT FK→Workout | |
| computedAt | TEXT UTC | |
Алгоритм расчёта — `03_TECHNICAL_SPEC.md`, раздел 9.4. Триггеры пересчёта — те же, что в 6.10.

### 6.12. `AppSettings` (одна строка, `id = 'singleton'`)
| Поле | Тип | Умолч. | Описание |
|---|---|---|---|
| unitSystem | TEXT enum | `metric` | D-5 |
| theme | TEXT enum | `system` | |
| locale | TEXT enum | `system` | |
| showTags | INTEGER | 1 | Глобальное скрытие тегов в UI (данные не трогаются) |
| defaultRestTimerSec | INTEGER | 120 | 10–600 (Q-4) |
| restTimerAutoStart | INTEGER | 1 | Автозапуск таймера отдыха после отметки подхода |
| updatedAt | TEXT UTC | | |

### 6.13. `ImportExportOperation`
| Поле | Тип | Обяз. | Описание |
|---|---|---|---|
| id | TEXT PK | да | UUID |
| operationType | TEXT enum | да | `export` в MVP |
| status | TEXT enum | да | `inProgress`/`success`/`failed` |
| formatVersion | INTEGER | да | Версия формата CSV (`03`, раздел 10) |
| startedAt / finishedAt | TEXT UTC | да/нет | |
| itemCountsJson | TEXT | нет | `{"workouts":N,"sets":N,"measurements":N,"exercises":N}` |
| errorSummary | TEXT | нет | Текст ошибки при `failed` |
Записи — журнал для пользователя (экран «Импорт/экспорт») и опора будущего импорта. Хранятся последние 50, старые удаляются физически.

### 6.14. `ActiveWorkoutState` (одна строка, восстановление активного режима)
`workoutId FK`, `startedAtUtc`, `accumulatedActiveSec` (набежавшее активное время до последней паузы), `isPaused`, `pauseStartedAtUtc`, `restTimerEndsAtUtc` (NULL, если таймер не идёт), `restTimerDurationSec`, `updatedAt`. Обновляется при каждом событии режима; логика восстановления — `03_TECHNICAL_SPEC.md`, раздел 7.

## 7. Диаграмма связей (текстом)
```
MuscleGroup 1─* Exercise (primary)          Equipment 1─* Exercise
Exercise *─* MuscleGroup (secondary, через ExerciseSecondaryMuscle)
Exercise 1─* WorkoutExercise *─1 Workout    Workout *─* WorkoutTag (через WorkoutTagLink)
WorkoutExercise 1─* ExerciseSet
WorkoutTemplate 1─* TemplateExercise (*─1 Exercise) 1─* TemplateSet
MeasurementType 1─* BodyMeasurement
Exercise 1─* PersonalRecord (кэш)           Exercise 1─1 ExerciseProgressionState (кэш)
```

## 8. Индексы (минимум)
- `Workout(date)`, `Workout(status)`, `Workout(isDeleted)`
- `WorkoutExercise(workoutId)`, `WorkoutExercise(exerciseId)`
- `ExerciseSet(workoutExerciseId)`
- `BodyMeasurement(measurementTypeId, date)`
- `Exercise(name COLLATE NOCASE)`, `Exercise(isArchived)`
- `WorkoutTagLink(tagId)`

## 9. Правила валидации — принципы применения
1. Валидация выполняется в слое сервисов до записи (см. `03`, раздел 4); UI дополнительно ограничивает ввод (маски, клавиатуры, шаги).
2. Нарушение «мягких» правил (дубликат имени, сомнительный URL) — предупреждение, сохранение разрешено. Нарушение «жёстких» (диапазоны, обязательность, недопустимый переход статуса) — сохранение блокируется с локализованным сообщением (`04`, раздел 7).
3. Автосохранение (ТЗ): каждое подтверждённое изменение поля пишется в БД немедленно, отдельной кнопки «Сохранить» в редакторах подходов нет.

## 10. Правила удаления и архивирования (D-19)
| Сущность | Правило |
|---|---|
| Встроенное упражнение | Физическое удаление невозможно. Доступна только архивация (`isArchived = 1`): скрывается из каталога и выбора, история не меняется. |
| Пользовательское упражнение, есть в истории/шаблонах | Только архивация. UI вместо «Удалить» показывает «Архивировать» с пояснением. |
| Пользовательское упражнение без использования | Физическое удаление после подтверждения (включая `ExerciseSecondaryMuscle`). |
| Тренировка | Мягкое удаление + Undo 5 с; связанные `WorkoutExercise`/`ExerciseSet` помечаются `isDeleted` той же транзакцией. Удаление `inProgress` запрещено (сначала отменить). |
| WorkoutExercise / ExerciseSet | Мягкое удаление + Undo; перенумерация `setNumber`/`orderIndex` в той же транзакции. |
| Шаблон | Архивация (основной путь) или мягкое удаление с подтверждением. |
| Тег | Мягкое удаление с подтверждением «Тег будет снят с N тренировок» (связи `WorkoutTagLink` помечаются удалёнными). Скрытие (`isHidden`) данные не меняет. |
| Измерение | Мягкое удаление + Undo. |
| MeasurementType пользовательский | Если есть измерения — только архивация; иначе физическое удаление. |
| Физическая очистка | Записи с `isDeleted = 1` старше 30 дней вычищаются фоновой задачей при старте приложения (кроме сущностей, на которые ссылаются неудалённые записи). |

## 11. Миграции схемы
- Механизм: `drift` `schemaVersion` (целое, старт = 1) + `MigrationStrategy.onUpgrade` с пошаговыми миграциями `N → N+1`. Понижение версии не поддерживается (при обнаружении — экран ошибки с предложением экспорта/переустановки, без затирания данных).
- Каждая миграция: (1) описана в `CHANGELOG` раздела 11.1 этого документа; (2) идемпотентно применима к пустой и заполненной БД; (3) покрыта тестом «БД версии N с данными → миграция → проверка данных и версии N+1» (см. `02`, сквозные требования).
- Запрещено: удаление колонок с потерей данных без явного решения владельца; изменение семантики колонки без переименования.
- Перед миграцией drift выполняет её в транзакции; при исключении БД остаётся на прежней версии, приложение показывает ошибку и не продолжает работу с частично мигрированной схемой.

### 11.1. CHANGELOG схемы
| Версия | Дата | Изменения |
|---|---|---|
| 1 | Этап 0 | Начальная схема: все таблицы разделов 5–6 |
| 2 | Этап 10, 2026-07-23 | Удалены `ExerciseSets.isWarmup`/`TemplateSets.isWarmup` (понятие разминки убрано из приложения, решение владельца) — `Migrator.dropColumn` для обеих таблиц, покрыто тестом `test/data/database_migration_v1_to_v2_test.dart` |

## 12. Начальные данные (сиды)
- Загружаются при первом запуске в транзакции; факт загрузки — по наличию строк, версия сида хранится в `AppSettings`-подобной служебной таблице `SeedInfo(seedVersion INTEGER)`.
- Файл сида упражнений: `assets/seed/exercises_v1.json`. Шаблон элемента (заполняет владелец, D-4):
```json
{
  "id": "bench_press",
  "name": {"ru": "Жим штанги лёжа", "en": "Barbell Bench Press"},
  "description": {"ru": "...", "en": "..."},
  "youtubeUrl": "https://youtu.be/...",
  "image": "exercises/bench_press.webp",
  "type": "strength",
  "primaryMuscle": "chest",
  "secondaryMuscles": ["triceps", "shoulders"],
  "equipment": "barbell",
  "effortMetric": "rpe"
}
```
- Локализованные `name`/`description` встроенных упражнений при сиде записываются в отдельную таблицу `ExerciseL10n(exerciseId, locale, name, description)`; поле `Exercise.name` для встроенных хранит английское имя как каноническое (используется в CSV и поиске вместе с локализованным).
- Обновление сида при обновлении приложения: новые встроенные упражнения добавляются; существующие обновляются только в неизменённых пользователем полях (в MVP встроенные нередактируемы, поэтому обновляются целиком, кроме `isArchived`).
- До получения контента от владельца — заглушечный сид из 5 упражнений (по одному на тип) с плейсхолдер-изображением.

## 13. Открытые вопросы документа
| ID | Вопрос | Статус |
|---|---|---|
| DM-1 | Хранить ли `sourceTemplateId` в `Workout` (раздел 6.8) | Закрыт (2026-07-21): не хранить. Ни один пункт функциональности/критериев приёмки Этапа 5 не требует показывать источник тренировки или считать использования шаблона — решение владельца через `AskUserQuestion`. Можно добавить позже additive-миграцией (nullable-колонка), если появится реальная потребность. |
| DM-2 | Окно «Возобновить» завершённую тренировку 24 ч (6.4.1) | Предположение; подтвердить |

## 14. Критерии готовности документа
- [x] Все 11 сущностей ТЗ описаны с полями, обязательностью, единицами, умолчаниями, связями, валидацией, правилами удаления и миграций.
- [x] Метрики всех 5 типов упражнений отображены в схему `ExerciseSet`.
- [x] Правила D-5, D-8, D-13, D-16, D-19 реализованы схемой.
- [x] Определён формат сида и процедура его обновления.
- [ ] Получен контент 20 упражнений (Q-1) — не блокирует Этапы 0–1.
