import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/bottom_nav_bar.dart';
import '../domain/models/exercise.dart';
import '../features/exercises/create_exercise_screen.dart';
import '../features/exercises/exercise_detail_screen.dart';
import '../features/exercises/screen.dart';
import '../features/export/export_format_help_screen.dart';
import '../features/export/export_screen.dart';
import '../features/history/copy_source_picker_screen.dart';
import '../features/history/screen.dart';
import '../features/history/template_picker_screen.dart';
import '../features/measurements/custom_measurement_type_screen.dart';
import '../features/measurements/measurement_form_screen.dart';
import '../features/measurements/measurement_girths_bulk_entry_screen.dart';
import '../features/measurements/screen.dart';
import '../features/more/screen.dart';
import '../features/settings/screen.dart';
import '../features/stats/exercise_progress_picker_screen.dart';
import '../features/stats/exercise_progress_screen.dart';
import '../features/stats/screen.dart';
import '../features/tags/screen.dart';
import '../features/template_editor/screen.dart';
import '../features/templates/screen.dart';
import '../features/today/screen.dart';
import '../features/workout_editor/add_exercise_screen.dart';
import '../features/workout_editor/screen.dart';
import '../features/workout_summary/screen.dart';
import '../l10n/app_localizations.dart';

/// App routes (04_UI_UX_SPEC.md, section 4). Stage 0 wired the 5 tab roots.
/// `/workout/:workoutId` (S-03) and its nested "summary"/"add exercise"/
/// "create exercise" routes, plus `/copy-source` and `/template-source`
/// (the creation menu's "Копией"/"Из шаблона" pickers), are top-level
/// siblings of the tab shell below, not nested inside any branch (Stage 10
/// redesign, owner-reported bug): all four are reachable from every tab
/// (Сегодня, История, Статистика's records, шаблоны...), and nesting any of
/// them inside History's branch — as they used to be — meant `go_router`'s
/// `StatefulShellRoute` always switched the active tab to History on open,
/// and "back" (or finishing a workout created this way) always landed on
/// History's root/branch, regardless of which tab the owner actually opened
/// it from. As routes outside the shell entirely, opening any of them is a
/// `context.push` (never `context.go` — see `today/screen.dart`'s doc
/// comment) that layers a page on top of the *current* Navigator via the
/// root Navigator, leaving the shell (and whichever tab/stack was active
/// underneath) completely untouched; popping it — including the system/
/// hardware back button, which needs no special handling — reveals exactly
/// what was there before, on whichever tab that was. Remaining nested
/// routes (`/exercises/:id`, etc.) arrive with the features that need them.
final GoRouter appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
    GoRoute(
      path: '/workout/:workoutId',
      builder: (_, state) => WorkoutEditorScreen(
        workoutId: state.pathParameters['workoutId']!,
      ),
      routes: [
        GoRoute(
          path: 'summary',
          // S-05, Stage 4: replaces the editor in the stack right after
          // "Завершить" (WorkoutEditorScreen calls pushReplacement), so
          // "back" from here lands wherever "back" would have from the
          // editor -- whichever tab/screen the editor was opened from.
          builder: (_, state) => WorkoutSummaryScreen(
            workoutId: state.pathParameters['workoutId']!,
          ),
        ),
        GoRoute(
          path: 'add-exercise',
          // Exercise pickers/creation forms are full-screen modals
          // (04_UI_UX_SPEC.md, section 6).
          pageBuilder: (_, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: AddExerciseScreen(
              addExerciseRoute:
                  '/workout/${state.pathParameters['workoutId']}/add-exercise',
            ),
          ),
          routes: [
            GoRoute(
              path: 'new',
              pageBuilder: (_, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: const CreateExerciseScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/copy-source',
      // "Копией" in the creation menu — a picker, so a full-screen modal
      // like the other pickers/forms (04_UI_UX_SPEC.md, section 6). A
      // top-level sibling of `/workout/:workoutId` (see the top comment),
      // not nested under `/history` (Stage 10 redesign, owner-reported).
      pageBuilder: (_, state) => MaterialPage(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const CopySourcePickerScreen(),
      ),
    ),
    GoRoute(
      path: '/template-source',
      // "Из шаблона" in the creation menu — same full-screen modal picker
      // pattern as "Копией" above (Stage 5; moved out of `/history`
      // alongside it, Stage 10 redesign, owner-reported).
      pageBuilder: (_, state) => MaterialPage(
        key: state.pageKey,
        fullscreenDialog: true,
        child: const TemplatePickerScreen(),
      ),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainTabScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/today', builder: (_, _) => const TodayScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercises',
              builder: (_, _) => const ExercisesScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  // Creation forms are full-screen modals (04_UI_UX_SPEC.md,
                  // section 6).
                  pageBuilder: (_, state) => MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: const CreateExerciseScreen(),
                  ),
                ),
                GoRoute(
                  path: ':exerciseId',
                  builder: (_, state) => ExerciseDetailScreen(
                    exerciseId: state.pathParameters['exerciseId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      // Edit form is a full-screen modal, like creation
                      // (04_UI_UX_SPEC.md, section 6). The exercise is
                      // passed via `extra` — the detail screen already has
                      // it loaded, no need to re-fetch.
                      pageBuilder: (_, state) => MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: CreateExerciseScreen(
                          exercise: state.extra as Exercise,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (_, _) => const StatsScreen(),
              routes: [
                GoRoute(
                  path: 'exercise-search',
                  // S-10's exercise picker -- a full-screen modal, like the
                  // other pickers (04_UI_UX_SPEC.md, section 6).
                  pageBuilder: (_, state) => MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: const ExerciseProgressPickerScreen(),
                  ),
                ),
                GoRoute(
                  path: 'exercise/:exerciseId',
                  builder: (_, state) => ExerciseProgressScreen(
                    exerciseId: state.pathParameters['exerciseId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              builder: (_, _) => const MoreScreen(),
              routes: [
                GoRoute(
                  path: 'templates',
                  builder: (_, _) => const TemplateListScreen(),
                  routes: [
                    GoRoute(
                      path: ':templateId',
                      builder: (_, state) => TemplateEditorScreen(
                        templateId: state.pathParameters['templateId']!,
                      ),
                      routes: [
                        GoRoute(
                          path: 'add-exercise',
                          // Exercise pickers/creation forms are full-screen
                          // modals (04_UI_UX_SPEC.md, section 6).
                          pageBuilder: (_, state) => MaterialPage(
                            key: state.pageKey,
                            fullscreenDialog: true,
                            child: AddExerciseScreen(
                              addExerciseRoute:
                                  '/more/templates/${state.pathParameters['templateId']}/add-exercise',
                            ),
                          ),
                          routes: [
                            GoRoute(
                              path: 'new',
                              pageBuilder: (_, state) => MaterialPage(
                                key: state.pageKey,
                                fullscreenDialog: true,
                                child: const CreateExerciseScreen(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                GoRoute(
                  path: 'tags',
                  builder: (_, _) => const TagListScreen(),
                ),
                GoRoute(
                  path: 'measurements',
                  builder: (_, _) => const MeasurementsScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      // S-15 form — a full-screen modal like the other
                      // creation forms (04_UI_UX_SPEC.md, section 6).
                      pageBuilder: (_, state) => MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: MeasurementFormScreen(
                          initialTypeId: state.extra as String?,
                        ),
                      ),
                    ),
                    GoRoute(
                      path: 'custom/:typeId',
                      builder: (_, state) => CustomMeasurementTypeScreen(
                        typeId: state.pathParameters['typeId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'girths',
                      // S-14 "Замеры" bulk entry (Stage 10, owner-reported)
                      // — a full-screen modal like the single-entry form.
                      pageBuilder: (_, state) => MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: const MeasurementGirthsBulkEntryScreen(),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'export',
                  builder: (_, _) => const ExportScreen(),
                  routes: [
                    GoRoute(
                      path: 'format',
                      // Read-only help content, not a creation form -- a
                      // regular push, not a full-screen modal
                      // (04_UI_UX_SPEC.md, section 6 reserves modals for
                      // forms).
                      builder: (_, _) => const ExportFormatHelpScreen(),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'settings',
                  builder: (_, _) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Bottom navigation shell for the 5 tabs (04_UI_UX_SPEC.md, section 4).
/// Android back on a tab root falls through to the system default (leave
/// the app); `StatefulShellRoute` keeps each tab's own navigation stack.
///
/// Used to also host a "Тренировка продолжается" recovery banner across
/// every tab (Stage 4, TS 7.2 step 5); removed entirely (Stage 10,
/// owner-reported) -- it reserved a status-bar-tall gap above every tab's
/// own AppBar even while hidden (see the removed `_ResumeWorkoutBanner` in
/// git history for the two rounds of fixing that before this), and the
/// owner decided screen space matters more than the reminder. The Today
/// tab's own "Continue" card (`today/screen.dart`) already covers the same
/// "get back into the active workout" need from that tab; from elsewhere,
/// History still reaches it too.
///
/// Used to also conditionally hide [BottomNavBar] while viewing the active
/// workout's own editor screen (Stage 10, owner-reported, mockup attached)
/// -- via a `ListenableBuilder` on `GoRouter.routerDelegate` checking the
/// current URL against `/history/workout/:id`, since that route used to be
/// nested *inside* this very shell. Removed entirely (Stage 10, owner-
/// reported: opening a workout always switched the active tab to History
/// and "back" always landed on History's root, regardless of which tab it
/// was opened from) now that `/workout/:workoutId` (`app/router.dart`'s top
/// comment) is a route outside the shell altogether: its own `Scaffold`
/// (`WorkoutEditorScreen`) fully covers this one, for every workout status,
/// not just while `inProgress` -- there's no bottom nav left to hide, and
/// no URL-watching needed to decide when to hide it.
class _MainTabScaffold extends StatelessWidget {
  const _MainTabScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // Stage 10, owner-reported: tapping the already-active tab while
          // deeper in its stack (e.g. "Ещё" -> "Шаблоны" -> tap "Ещё"
          // again) resets that branch back to its root instead of doing
          // nothing.
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          BottomNavBarDestination(
            icon: Icons.today_outlined,
            label: l10n.tabToday,
          ),
          BottomNavBarDestination(
            icon: Icons.history_outlined,
            label: l10n.tabHistory,
          ),
          BottomNavBarDestination(
            icon: Icons.fitness_center_outlined,
            label: l10n.tabExercises,
          ),
          BottomNavBarDestination(
            icon: Icons.bar_chart_outlined,
            label: l10n.tabStats,
          ),
          BottomNavBarDestination(
            icon: Icons.more_horiz_outlined,
            label: l10n.tabMore,
          ),
        ],
      ),
    );
  }
}
