import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/exercise.dart';
import '../features/exercises/create_exercise_screen.dart';
import '../features/exercises/exercise_detail_screen.dart';
import '../features/exercises/screen.dart';
import '../features/history/copy_source_picker_screen.dart';
import '../features/history/screen.dart';
import '../features/history/template_picker_screen.dart';
import '../features/measurements/custom_measurement_type_screen.dart';
import '../features/measurements/measurement_form_screen.dart';
import '../features/measurements/screen.dart';
import '../features/more/screen.dart';
import '../features/stats/exercise_progress_picker_screen.dart';
import '../features/stats/exercise_progress_screen.dart';
import '../features/stats/screen.dart';
import '../features/template_editor/screen.dart';
import '../features/templates/screen.dart';
import '../features/today/screen.dart';
import '../features/workout_editor/add_exercise_screen.dart';
import '../features/workout_editor/screen.dart';
import '../features/workout_summary/screen.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';

/// App routes (04_UI_UX_SPEC.md, section 4). Stage 0 wired the 5 tab roots;
/// `/history/workout/:workoutId` (S-03, Stage 1) and its nested
/// "add exercise"/"create exercise" modals were added alongside the workout
/// editor. Remaining nested routes (`/exercises/:id`, the full-screen
/// `/active` route, etc.) arrive with the features that need them.
final GoRouter appRouter = GoRouter(
  initialLocation: '/today',
  routes: [
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
            GoRoute(
              path: '/history',
              builder: (_, _) => const HistoryScreen(),
              routes: [
                GoRoute(
                  path: 'copy-source',
                  // "Копией" in the creation menu — a picker, so a
                  // full-screen modal like the other pickers/forms
                  // (04_UI_UX_SPEC.md, section 6).
                  pageBuilder: (_, state) => MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: const CopySourcePickerScreen(),
                  ),
                ),
                GoRoute(
                  path: 'template-source',
                  // "Из шаблона" in the creation menu — same full-screen
                  // modal picker pattern as "Копией" above (Stage 5).
                  pageBuilder: (_, state) => MaterialPage(
                    key: state.pageKey,
                    fullscreenDialog: true,
                    child: const TemplatePickerScreen(),
                  ),
                ),
                GoRoute(
                  path: 'workout/:workoutId',
                  builder: (_, state) => WorkoutEditorScreen(
                    workoutId: state.pathParameters['workoutId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'summary',
                      // S-05, Stage 4: replaces the editor in the stack
                      // right after "Завершить" (WorkoutEditorScreen calls
                      // pushReplacement), so system back from here goes to
                      // History, same as it did from the editor.
                      builder: (_, state) => WorkoutSummaryScreen(
                        workoutId: state.pathParameters['workoutId']!,
                      ),
                    ),
                    GoRoute(
                      path: 'add-exercise',
                      // Exercise pickers/creation forms are full-screen
                      // modals (04_UI_UX_SPEC.md, section 6).
                      pageBuilder: (_, state) => MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: AddExerciseScreen(
                          addExerciseRoute:
                              '/history/workout/${state.pathParameters['workoutId']}/add-exercise',
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
                  ],
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
/// Also hosts the "Тренировка продолжается" recovery banner (Stage 4, TS
/// 7.2 step 5) — visible on every tab, including right after a cold start
/// with a workout already `inProgress` (the anchor-based timers need no
/// extra recovery work of their own; this banner is purely about giving the
/// owner a way back in).
class _MainTabScaffold extends ConsumerWidget {
  const _MainTabScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          const _ResumeWorkoutBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            label: l10n.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            label: l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            label: l10n.tabExercises,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            label: l10n.tabStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_outlined),
            label: l10n.tabMore,
          ),
        ],
      ),
    );
  }
}

/// "Тренировка продолжается, N мин" (Stage 4, TS 7.2 step 5) — shown
/// whenever `inProgressWorkoutProvider` has a workout, on top of whichever
/// tab is active. The elapsed minutes shown are computed once per rebuild
/// (start/pause/resume of the workout, or a fresh app start) rather than
/// ticking every second — this is a passive reminder, not a live clock, so
/// per-minute staleness between those events is an acceptable simplification
/// that avoids yet another `Timer.periodic` alongside the ones already
/// living inside the workout editor.
class _ResumeWorkoutBanner extends ConsumerWidget {
  const _ResumeWorkoutBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(inProgressWorkoutProvider);
    final workout = workoutAsync.value;
    if (workout == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final activeStateAsync = ref.watch(activeWorkoutStateProvider(workout.id));
    final activeState = activeStateAsync.value;
    final minutes = activeState == null
        ? 0
        : ref
                  .read(activeWorkoutTimerServiceProvider)
                  .elapsedSeconds(activeState) ~/
              60;

    return MaterialBanner(
      content: Text(l10n.workoutContinuingBannerMessage(minutes)),
      actions: [
        TextButton(
          onPressed: () => context.push('/history/workout/${workout.id}'),
          child: Text(l10n.continueWorkoutAction),
        ),
      ],
    );
  }
}
