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
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<BottomNavBarDestination> destinations;

  /// Matches the stock `NavigationBar`'s default total height (icon +
  /// label + padding), so swapping this in doesn't shift the rest of the
  /// screen's layout.
  static const double _height = 80;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Drag-the-pill state (redesign v3, owner-requested; merges what used to
  // be two separate gestures -- a plain swipe to the neighboring tab, and a
  // long-press-then-drag to any tab -- into one). Any horizontal drag
  // anywhere on the bar, no hold required, teleports the pill to the
  // touch point right away and tracks the finger from there; releasing
  // snaps to whichever tab is currently under it, however far that is from
  // where the drag started. A plain tap (no meaningful movement) never
  // reaches these handlers at all -- the gesture arena resolves it as a
  // tap on the `InkWell` inside the item before this recognizer's own
  // touch-slop clears, so it keeps switching tabs immediately as before.
  bool _isDraggingPill = false;
  double _pillDragLocalX = 0;
  int _pillTargetIndex = 0;

  // Owner-reported: giving the flying pill's reveal window the full 80dp
  // bar height (matching `BottomNavBar._height`, since that's what a
  // `Positioned` needs *some* explicit height to size against) made its
  // rounded shape stretch down well past a real pill's own bottom edge --
  // rounded top, but a flat, unrounded bottom where the clip boundary cut
  // across empty space below the actual content. A real pill's height is
  // content-driven (icon + label + padding), not the bar's own -- rather
  // than re-deriving that from scratch (and re-litigating exactly which
  // constraint-propagation rule of `Stack`/`Positioned` governs it, which
  // is precisely how the *previous* attempt at this same fix went wrong),
  // this measures one directly off a real, already-laid-out pill slot and
  // reuses that exact number, so the two can't help but match.
  final GlobalKey _pillHeightMeasureKey = GlobalKey();
  double? _pillHeight;

  void _schedulePillHeightMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final measured = _pillHeightMeasureKey.currentContext?.size?.height;
      if (measured != null && measured != _pillHeight) {
        setState(() => _pillHeight = measured);
      }
    });
  }

  int _indexForX(double x, double barWidth) {
    final itemWidth = barWidth / widget.destinations.length;
    final index = (x / itemWidth).floor();
    return index.clamp(0, widget.destinations.length - 1);
  }

  void _handleDragStart(DragStartDetails details, double barWidth) {
    setState(() {
      _isDraggingPill = true;
      _pillDragLocalX = details.localPosition.dx;
      _pillTargetIndex = _indexForX(_pillDragLocalX, barWidth);
    });
  }

  void _handleDragUpdate(DragUpdateDetails details, double barWidth) {
    setState(() {
      _pillDragLocalX = details.localPosition.dx;
      _pillTargetIndex = _indexForX(_pillDragLocalX, barWidth);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    // Release anywhere -- between two tabs, or past either edge -- always
    // snaps to whichever tab `_pillTargetIndex` already tracked as the
    // nearest one, so the gesture never "gets lost". A single fast, far
    // drag can land several tabs away from where it started (owner-
    // requested): whatever is under the finger at release wins, not just
    // an immediate neighbor of the tab that was active before the drag.
    final target = _pillTargetIndex;
    setState(() {
      _isDraggingPill = false;
    });
    if (target != widget.selectedIndex) {
      widget.onDestinationSelected(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    _schedulePillHeightMeasurement();
    final scheme = Theme.of(context).colorScheme;
    // Falls back to the full bar height only until the first post-frame
    // measurement lands (a single frame, in practice) -- after that,
    // `_pillHeight` always reflects a real pill's own content-driven
    // height.
    final pillHeight = _pillHeight ?? BottomNavBar._height;
    return Material(
      color: scheme.surface,
      elevation: 3,
      surfaceTintColor: scheme.surfaceTint,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final itemWidth = barWidth / widget.destinations.length;
            final pillLeft = _isDraggingPill
                ? (_pillDragLocalX - itemWidth / 2).clamp(
                    0.0,
                    barWidth - itemWidth,
                  )
                : 0.0;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (details) =>
                  _handleDragStart(details, barWidth),
              onHorizontalDragUpdate: (details) =>
                  _handleDragUpdate(details, barWidth),
              onHorizontalDragEnd: _handleDragEnd,
              child: SizedBox(
                height: BottomNavBar._height,
                child: Stack(
                  children: [
                    // A measuring instance -- `selected: true, glass:
                    // true`, exactly matching what the reveal window's own
                    // duplicate row actually renders -- laid out (for its
                    // real size) but never painted or hit-tested
                    // (`Offstage`). Owner-reported, twice over: measuring
                    // whichever slot the row's own base items happened to
                    // be in undershot by ~2px whenever that slot wasn't
                    // both `selected: true` *and* `glass: true` at the
                    // time -- a bold ("selected") label's line-height
                    // measures very slightly taller than the regular-
                    // weight one, and `glass`'s own `Border.all()` (its
                    // default 1.0-width side) adds its own 1px top + 1px
                    // bottom via the container's `decoration.padding`,
                    // which a plain, non-glass "selected" measurement
                    // (the first round of this same fix) doesn't carry
                    // either. This is pinned to exactly what the reveal
                    // window renders, not what the real row happens to be
                    // showing at the moment, so the two can't help but
                    // match.
                    Positioned(
                      left: 0,
                      top: 0,
                      width: itemWidth,
                      child: Offstage(
                        offstage: true,
                        child: BottomNavBarItem(
                          key: _pillHeightMeasureKey,
                          destination: widget.destinations[0],
                          selected: true,
                          glass: true,
                          onTap: () {},
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < widget.destinations.length; i++)
                          Expanded(
                            child: BottomNavBarItem(
                              destination: widget.destinations[i],
                              // The active tab's own pill hides for the
                              // duration of the drag -- the reveal window
                              // below takes over showing "selected" style
                              // content, precisely wherever it's currently
                              // covering.
                              selected:
                                  !_isDraggingPill && i == widget.selectedIndex,
                              onTap: () => widget.onDestinationSelected(i),
                            ),
                          ),
                      ],
                    ),
                    if (_isDraggingPill)
                      Positioned(
                        left: pillLeft,
                        top: 0,
                        width: itemWidth,
                        height: pillHeight,
                        // Never a tap/hit-test target of its own (the
                        // drag recognizer above already owns this whole
                        // gesture) -- also drops it from the semantics
                        // tree, so it doesn't announce a second,
                        // momentarily-duplicate "selected" tab alongside
                        // the one still in the row underneath.
                        child: IgnorePointer(
                          // Owner-reported, three rounds over: a floating
                          // copy of just the *origin* tab's icon read as
                          // "stuck" on the wrong tab once dragged
                          // elsewhere; a follow-up frosted-glass version
                          // (referencing iOS 26's "Liquid Glass") fixed
                          // that by hiding its own icon and relying on
                          // `BackdropFilter` to blur the real row
                          // underneath -- but blurring the real icons made
                          // them unreadable, which defeats the point of a
                          // "preview". This is a reveal window instead, no
                          // blur: a full second copy of the row, every tab
                          // drawn in its "selected" look (bright icon/label
                          // on a translucent glass-tinted pill), laid out
                          // at the exact same x-offsets as the real row and
                          // then clipped down to just this `itemWidth`-
                          // wide, rounded slice at the pill's current
                          // position (`Positioned(left: -pillLeft, width:
                          // barWidth)` shifts the *whole* duplicate row
                          // left so the correct slice of it lands inside
                          // the clip). Whatever tab(s) the window is over
                          // -- even straddling two of them mid-drag --
                          // show through sharp and fully legible, styled
                          // exactly like a real selected pill; nothing
                          // here is blurred, since nothing here is a
                          // filter over the real content -- it *is* real
                          // (icon+label) content, just windowed. The clip
                          // window's own height is `pillHeight` (measured
                          // above), not the full bar height -- a rounded
                          // window taller than a real pill's own content
                          // (owner-reported: it was, twice) reads as
                          // rounded on top but flat/square on the bottom,
                          // where the clip boundary cuts across empty
                          // space well below the actual content.
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppRadius.control,
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: -pillLeft,
                                  top: 0,
                                  width: barWidth,
                                  height: pillHeight,
                                  child: Row(
                                    children: [
                                      for (final destination
                                          in widget.destinations)
                                        Expanded(
                                          child: BottomNavBarItem(
                                            destination: destination,
                                            selected: true,
                                            glass: true,
                                            onTap: () {},
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
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
///
/// No longer wraps itself in an `Expanded` (redesign v3, owner-requested
/// pill-drag gesture): `BottomNavBar` now builds two different presentations
/// of the same item -- one `Expanded` inside the ordinary `Row` of tabs, and
/// a second copy used (windowed, see `BottomNavBar`'s own doc comment)
/// inside the reveal window while dragging the selection pill to another
/// tab -- so the sizing decision belongs to whichever parent is placing it,
/// not to the item itself.
class BottomNavBarItem extends StatelessWidget {
  const BottomNavBarItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
    this.glass = false,
  });

  final BottomNavBarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  /// A translucent, glass-tinted fill (with a thin light rim) instead of a
  /// flat, fully-opaque one -- used only for the copies inside the
  /// mid-drag reveal window (redesign v3, owner-requested, referencing iOS
  /// 26's "Liquid Glass" material). The icon/label on top are never
  /// affected by this -- only the background fill's own opacity changes,
  /// so they stay exactly as sharp and legible as the ordinary (non-glass)
  /// selected pill's.
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Semantics(
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
              color: selected
                  ? (glass
                        ? scheme.primary.withValues(alpha: 0.32)
                        : scheme.primary)
                  : Colors.transparent,
              // Owner-reported: less rounded than the app-wide button
              // radius (AppRadius.button, 16dp) -- this pill is its own
              // shape, not a `FilledButton`/etc., so it isn't affected by
              // reducing the global button radius, and doesn't have to
              // match it.
              borderRadius: BorderRadius.circular(AppRadius.control),
              border: glass
                  ? Border.all(color: Colors.white.withValues(alpha: 0.4))
                  : null,
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
    );
  }
}
