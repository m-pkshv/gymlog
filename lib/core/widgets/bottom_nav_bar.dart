import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

/// One tab of [BottomNavBar] -- an icon + a short label, nothing else
/// (`BottomNavBar` owns selection/tap-handling).
class BottomNavBarDestination {
  const BottomNavBarDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The app's bottom tab bar (Stage 10 redesign, owner-reported, mockup
/// screenshot). Replaces the stock Material 3 `NavigationBar`: that
/// widget's selection indicator is hard-coded to a `StadiumBorder` sitting
/// behind the icon only -- the label below gets a color change but no
/// background of its own, and neither detail is reachable through
/// `NavigationBarThemeData` (it's baked into the widget's internal
/// layout, not exposed as a style knob). The mockup wants a single
/// rounded-rectangle indicator behind icon *and* label together, so this
/// is a plain `Row` of tappable items instead.
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BottomNavBarDestination> destinations;

  /// Matches the stock `NavigationBar`'s default total height (icon +
  /// label + padding), so swapping this in doesn't shift the rest of the
  /// screen's layout.
  static const double _height = 80;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      surfaceTintColor: scheme.surfaceTint,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                BottomNavBarItem(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  onTap: () => onDestinationSelected(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One tappable tab -- a rounded-rectangle (`AppRadius.button`) filled
/// with `colorScheme.primary` behind icon+label when [selected], nothing
/// behind them otherwise. A public top-level widget (not a private class
/// inside `BottomNavBar`) so tests can assert on it directly, the same way
/// they used to assert on the stock `NavigationDestination`.
class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final BottomNavBarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: destination.label,
        child: InkWell(
          onTap: onTap,
          // The pill itself (colorScheme.primary once selected) is already
          // the tap feedback -- owner-reported: the default M3 ripple's
          // rectangular gray highlight, spanning the full (wider) tap
          // target rather than the pill, showed as a separate, oddly-
          // shaped flash behind it.
          splashFactory: NoSplash.splashFactory,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selected ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(destination.icon, color: foreground, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
