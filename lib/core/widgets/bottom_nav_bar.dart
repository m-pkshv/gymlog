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
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BottomNavBarDestination> destinations;

  /// A swipe anywhere on the bar switches to the neighboring tab -- one
  /// swipe, one tab, not a multi-tab fling (redesign v3, owner-requested).
  /// `null` when there's no neighbor in that direction (already on the
  /// first/last tab); the drag recognizer still attaches either way, it
  /// just has nothing to call. The `InkWell`s inside each
  /// [BottomNavBarItem] keep working alongside this: a plain tap never
  /// clears the gesture arena's touch-slop, so it's decided as a tap
  /// before this recognizer would ever see it as a drag.
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  /// Matches the stock `NavigationBar`'s default total height (icon +
  /// label + padding), so swapping this in doesn't shift the rest of the
  /// screen's layout.
  static const double _height = 80;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Below this cumulative horizontal travel (logical px), a drag that
  // still cleared the gesture arena's touch-slop reads as too small to
  // count as a deliberate swipe, not an actual "switch tabs" gesture.
  //
  // Deciding by *distance* covers the same ground `DragEndDetails.
  // primaryVelocity` would, without depending on it: `flutter_test`'s
  // synthetic `drag()` sends its move events with no reliable elapsed
  // time between them, so the velocity `VelocityTracker` computes from
  // them reads as ~0 regardless of how far the drag actually travelled --
  // a velocity-gated version of this passed `flutter analyze` and looked
  // right by inspection, but silently never fired in `flutter test`
  // (caught by the swipe tests below, not by eyeballing the diff).
  static const double _minSwipeDistance = 40;

  double _dragDelta = 0;

  void _handleDragStart(DragStartDetails details) {
    _dragDelta = 0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _dragDelta += details.delta.dx;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragDelta <= -_minSwipeDistance) {
      widget.onSwipeLeft?.call();
    } else if (_dragDelta >= _minSwipeDistance) {
      widget.onSwipeRight?.call();
    }
    _dragDelta = 0;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      elevation: 3,
      surfaceTintColor: scheme.surfaceTint,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _handleDragStart,
          onHorizontalDragUpdate: _handleDragUpdate,
          onHorizontalDragEnd: _handleDragEnd,
          child: SizedBox(
            height: BottomNavBar._height,
            child: Row(
              children: [
                for (var i = 0; i < widget.destinations.length; i++)
                  BottomNavBarItem(
                    destination: widget.destinations[i],
                    selected: i == widget.selectedIndex,
                    onTap: () => widget.onDestinationSelected(i),
                  ),
              ],
            ),
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
          // Owner-reported: sizing the pill to its own content (via `Center`
          // hugging a `mainAxisSize.min` child) made every pill a different
          // width depending on how long its label happened to be -- looked
          // uneven. The pill now always fills the item's full (equal) slot
          // width, with a small fixed gap to its neighbors instead of
          // shrink-wrapping around the text. (Owner-reported: tried
          // shrinking that gap, then removing it entirely -- neither read
          // as clearly wider on-device, so this is back to the original
          // gap; the corner radius is what actually changed this time.)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: selected ? scheme.primary : Colors.transparent,
                // Owner-reported: less rounded than the app-wide button
                // radius (AppRadius.button, 16dp) -- this pill is its own
                // shape, not a `FilledButton`/etc., so it isn't affected by
                // reducing the global button radius, and doesn't have to
                // match it.
                borderRadius: BorderRadius.circular(AppRadius.control),
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
                      // Owner-reported: labelSmall's default (11sp) still
                      // clips longer RU labels ("Упражнения", "Статистика")
                      // to an ellipsis on real devices -- shrink by 2sp.
                      fontSize:
                          (Theme.of(context).textTheme.labelSmall?.fontSize ??
                              11) -
                          2,
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
