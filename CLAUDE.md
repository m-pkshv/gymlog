# GymLog — дневник тренировок (Flutter)

Ты — ИИ-исполнитель этого проекта. Твой регламент работы — `docs/05_AI_INSTRUCTIONS.md`.
Прочитай его ПЕРВЫМ и строго следуй ему, включая порядок чтения остальных документов,
формат отчётов по шагам и Definition of Done.

## Ключевые правила (дубль критичного из регламента)
- Не выходи за объём текущего этапа из `docs/02_DEVELOPMENT_PLAN.md`.
- Не меняй решения D-1…D-19 и схему БД без моего явного подтверждения.
- Все предположения помечай `ASSUMPTION` и выноси в отчёт шага.
- После каждого шага: `flutter analyze` без ошибок, тесты зелёные, отчёт по формату 8.4 регламента.

## Команды проекта
- Запуск: `flutter run`
- Тесты: `flutter test`
- Анализ: `flutter analyze`

## Текущий этап
**Этап 0** — Каркас проекта (см. `docs/02_DEVELOPMENT_PLAN.md`, раздел 4)

Обновляй эту строку при переходе на следующий этап после моего подтверждения.

## История работы
Журнал шагов внутри этапов; обновляй после каждого завершённого шага (кратко: что сделано, PR/файлы, что дальше). Полные отчёты по формату 8.4 — в истории чата/PR, здесь только краткая сводка для быстрого старта в новой сессии.

### Этап 0 — Каркас проекта
- ✅ **Шаг 1** (2026-07-19, PR [#1](https://github.com/m-pkshv/gymlog/pull/1), ветка `stage0/project-init-and-deps`, смёржен в `main`): инициализация проекта.
  Сделано: удалены неиспользуемые платформы `web/linux/macos/windows` (вне D-10); `applicationId`/bundle id → `dev.gymlog.app` на Android и iOS, портретная блокировка на обеих платформах; зафиксированы зависимости D-17/TS 3 в `pubspec.yaml`/`pubspec.lock` (riverpod, go_router, drift, sqlite3_flutter_libs, flutter_localizations/intl, fl_chart, flutter_local_notifications, share_plus, path_provider, archive, csv, uuid + dev: build_runner, drift_dev, mocktail, integration_test); усилен `analysis_options.yaml`; демо-код `lib/main.dart` заменён на минимальную заглушку (`ProviderScope` + пустой `MaterialApp`); создан каркас каталогов `lib/{app,core,data,domain,services,features,l10n}`, `assets/{seed,images/exercises}`, `integration_test/` по TS 4.1.
  Проверено: `flutter analyze` — 0 ошибок; `flutter test` — зелёные; `flutter build apk --debug` — успешно.
  Открытый вопрос владельцу (не блокирует продолжение, блокирует закрытие Этапа 0): iOS-сборка не проверена — в рабочей среде нет macOS/Xcode-тулчейна; нужно прогнать `flutter build ios --no-codesign` на Mac/CI.
- ✅ **Шаг 2** (2026-07-19, коммит напрямую в `main`): core-слой.
  Сделано: `lib/core/result.dart` — `sealed class Result<T, E>` (`Ok`/`Err`, `fold`/`map`/`getOrNull`/`errorOrNull`); `lib/core/app_error.dart` — `sealed class AppError` (`StorageError`/`ValidationError`/`UnknownError`); `lib/core/units/unit_converter.dart` (D-5, TS 6) — конвертация масса кг↔lb, дистанция м↔км/мили, замеры см↔дюймы, темп (сек/км, сек/милю, формат `m:ss`), парсинг ввода с `.`/`,` как разделителем.
  Проверено: 24 unit-теста (`test/core/result_test.dart`, `test/core/units/unit_converter_test.dart`) — зелёные; `flutter analyze` — 0 ошибок.
  Предположения: `UnitSystem` объявлен в `core/units/unit_converter.dart` (домен переиспользует этот enum для `AppSettings.unitSystem`, не дублирует); `AppError.message` — пока обычная EN-строка, не ARB-ключ (заменится при подключении l10n).
- ⏭️ **Шаг 3** (следующий, не начат): drift-схема v1 целиком по всем таблицам DM разделов 5–6 + DAO + миграционный тест «пустая/заполненная БД → схема применилась».
- Дальше по плану Этапа 0 (порядок ориентировочный, может уточняться): сиды справочников (MuscleGroup/Equipment/MeasurementType) и заглушечный сид 5 упражнений (DM 12); домен-модели и интерфейсы репозиториев (D-13); `go_router` с маршрутами (UX 4) + темы Material 3 из seed-цвета (UX 9) + каркас ARB RU/EN; логгер (TS 11.7, уровни debug/info/error, без `print`).