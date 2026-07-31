# Промпты для Этапа 12 (имя приложения + иконка/сплеш)

Черновые промпты для сторонних нейросетей — не часть кода проекта, просто рабочий файл на время подбора имени/иконки. Можно удалить после того, как решения приняты.

## Промпт 1 — варианты имени приложения (текстовая нейросеть, любая: ChatGPT/Claude/Gemini)

```
Помоги придумать варианты названия для мобильного приложения.

Что это за приложение:
Офлайн-дневник тренировок в спортзале (Android + iOS). Пользователь ведёт
журнал тренировок: планирует тренировку (с нуля, из шаблона или как копию
прошлой), проводит её в специальном режиме с таймером отдыха и отметкой
подходов, смотрит историю с фильтрами, следит за статистикой и личными
рекордами (максимальный вес, расчётный 1ПМ, тоннаж), ведёт замеры тела
(вес, % жира, обхваты), экспортирует данные в CSV и PDF, делает резервные
копии. Все данные хранятся локально на устройстве, интернет не нужен.
Целевая аудитория — люди, которые тренируются в зале с отягощениями
(от новичков до серьёзных лифтеров), не только спортивные фанаты, но и
обычные посетители спортзала, которым лень/неудобно всё записывать в
заметки или таблицы.

Текущее рабочее (временное) имя — GymLog, его точно нужно сменить перед
публикацией в сторах.

Требования к вариантам:
- Короткое, легко произносится и на русском, и на английском (приложение
  двуязычное, RU/EN интерфейс).
- Не совпадает и не путается с уже известными приложениями для трекинга
  тренировок (Strava, Strong, Hevy, JEFIT, FitNotes, Jefit, StrongLifts
  и т.п.) — не хочу проблем с узнаваемостью/поиском в сторе.
- Без цифр и спецсимволов, желательно одно-два слова.
- Подходит и как имя в списке приложений на телефоне (короткое, не
  обрезается под иконкой), и как полноценное название в Google Play/App
  Store.
- Не привязано жёстко к слову "gym"/"зал" — можно и шире, про тренировки/
  прогресс/дисциплину в целом, если звучит сильнее.

Дай, пожалуйста:
1. 15–20 вариантов имени (можно вперемешку — русское звучание, английское
   звучание, нейтральное на латинице).
2. Для каждого — по одному предложению, почему оно может подойти (или чем
   рискованно, если видишь риск).
3. Для 5 лучших, по-твоему, вариантов — предложи technical slug для
   applicationId/bundle id в обратном доменном формате, например
   com.mycompany.appname (домен придумай нейтральный, я потом заменю на
   свой), используя английскую транслитерацию/перевод имени.
```

## Промпт 2 — иконка приложения и сплеш-экран (генератор изображений: Midjourney/DALL·E/Ideogram/Stable Diffusion)

```
App icon design for a mobile gym workout tracker app. Modern, minimal,
flat vector illustration style (Material You / Google Material Design 3
aesthetic) — NOT photorealistic, NOT 3D render, NOT skeuomorphic.

Primary color: deep blue #4C7BD9 as the dominant color.
Accent color: warm orange #E76C2B, used sparingly as a highlight/accent
detail only (small element, not the main color).
Background: solid color or simple flat gradient, no busy scenery.

Subject matter: a single bold, simple, instantly recognizable symbol
related to strength training / workout logging — pick ONE strong concept,
for example: a stylized barbell or dumbbell silhouette, a barbell combined
with a checkmark (logging/tracking idea), or an abstract geometric mark
suggesting progress/strength. Avoid literal photographic gym equipment —
keep it a clean, simplified icon-style mark.

Hard constraints:
- No text, no letters, no numbers anywhere in the image.
- Single focal object, centered, with generous empty margin around it
  (about 20% padding on each side) — this will be cropped into a rounded
  square/circle mask (Android adaptive icon), so nothing important should
  touch the edges.
- Must stay legible and recognizable when shrunk down to a very small
  size (like a 48x48 pixel phone home-screen icon) — bold shapes, high
  contrast, no fine detail or thin lines.
- Square canvas, 1:1 aspect ratio, 1024x1024px.
- Flat design, 2-3 colors max (the blue, the orange accent, and
  white/near-white), no photorealistic textures, no drop shadows beyond a
  very subtle flat one if any.

Please generate 4 distinct concept variations of this icon so I can pick
one direction.

Separately, also generate one simple splash-screen version: same color
palette (#4C7BD9 background, the same mark in white or the orange accent
color, centered), but simpler/flatter, meant to be shown briefly on a
solid-color screen while the app is loading — no clutter, just the mark
centered on a plain blue background.
```

## Как использовать
1. Промпт 1 — вставить в текстовую нейросеть, выбрать понравившееся имя (или несколько кандидатов), вернуться с решением.
2. Промпт 2 — вставить в генератор изображений, выбрать понравившийся вариант иконки. Если получившаяся картинка примерно то, что нужно, но не идеально — можно уточнять промпт итеративно (тот же чат обычно позволяет попросить "сделай вариант 2, но толще линии" и т.п.).
3. Готовые файлы (имя + иконка, желательно PNG 1024×1024 с прозрачным или сплошным фоном) прислать сюда — соберу через `flutter_launcher_icons`/`flutter_native_splash`.
