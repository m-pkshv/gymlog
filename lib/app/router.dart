import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/exercises/screen.dart';
import '../features/history/screen.dart';
import '../features/more/screen.dart';
import '../features/stats/screen.dart';
import '../features/today/screen.dart';
import '../l10n/app_localizations.dart';

/// App routes (04_UI_UX_SPEC.md, section 4). Stage 0 only wires the 5 tab
/// roots; nested routes (`/history/workout/:id`, `/exercises/:id`, the
/// full-screen `/active` route, etc.) are added alongside the features
/// that need them.
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
            GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercises',
              builder: (_, _) => const ExercisesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/more', builder: (_, _) => const MoreScreen()),
          ],
        ),
      ],
    ),
  ],
);

/// Bottom navigation shell for the 5 tabs (04_UI_UX_SPEC.md, section 4).
/// Android back on a tab root falls through to the system default (leave
/// the app); `StatefulShellRoute` keeps each tab's own navigation stack.
class _MainTabScaffold extends StatelessWidget {
  const _MainTabScaffold({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
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
