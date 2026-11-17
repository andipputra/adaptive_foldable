import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Back arrow glyph (Material Icons `arrow_back`, mirrored in right-to-left).
///
/// Needs the Material Icons font, which Flutter bundles when `uses-material-design` is true (the default).
const IconData kBackIcon = IconData(
  0xe092,
  fontFamily: 'MaterialIcons',
  matchTextDirection: true,
);

/// More-horizontal glyph (Material Icons `more_horiz`) for the overflow control.
const IconData kOverflowIcon = IconData(0xe404, fontFamily: 'MaterialIcons');

/// Colours a default bar applies to its items.
class NavBarColors {
  /// Creates a colour set.
  const NavBarColors({
    required this.background,
    required this.active,
    required this.inactive,
    this.indicator,
    this.border,
  });

  /// Bar background.
  final Color background;

  /// Selected content.
  final Color active;

  /// Unselected content.
  final Color inactive;

  /// Pill behind the selected icon, or null.
  final Color? indicator;

  /// Hairline between the bar and the body, or null.
  final Color? border;
}

/// Builds the items of a default bar in Apple's order: Back, prominent action, groups, tabs.
///
/// The same order is used for drawing and for semantics, so focus follows the visual order.
List<Widget> buildNavBarItems(
  NavLayout layout,
  NavBarColors colors, {
  required bool tabsExpand,
}) {
  NavBarItem action(NavAction a) => NavBarItem(
    icon: a.icon,
    label: a.label,
    selected: a.selected,
    isSelectable: false,
    isToggle: a.selected,
    enabled: a.enabled,
    onTap: a.onPressed,
    badgeCount: a.badgeCount,
    activeColor: a.isDestructive ? kDestructiveColor : colors.active,
    inactiveColor: a.isDestructive ? kDestructiveColor : colors.inactive,
  );

  final leading = <Widget>[
    if (layout.showBack)
      NavBarItem(
        icon: kBackIcon,
        label: BarStrings.back,
        selected: false,
        isSelectable: false,
        onTap: layout.onBack,
        activeColor: colors.active,
        inactiveColor: colors.inactive,
      ),
    if (layout.prominentAction != null) action(layout.prominentAction!),
    for (final group in layout.visibleActions)
      for (final a in group.actions) action(a),
    if (layout.onOverflow != null)
      _OverflowItem(layout: layout, colors: colors),
  ];
  final count = layout.destinations.length;
  // Compressed tabs show only the selected destination; tapping moves to the next one.
  final tabIndexes = layout.tabsCompressed
      ? [layout.selectedIndex]
      : [for (var i = 0; i < count; i++) i];
  final tabs = <Widget>[
    for (final i in tabIndexes)
      NavBarItem(
        icon: i == layout.selectedIndex
            ? layout.destinations[i].selectedIcon ?? layout.destinations[i].icon
            : layout.destinations[i].icon,
        label: layout.destinations[i].label,
        selected: i == layout.selectedIndex,
        badgeCount: layout.destinations[i].badgeCount,
        indicatorColor: colors.indicator,
        position: BarStrings.tabPosition(i + 1, count),
        activeColor: colors.active,
        inactiveColor: colors.inactive,
        onTap: () => layout.onSelected?.call(
          layout.tabsCompressed ? (i + 1) % count : i,
        ),
      ),
  ];
  final fading = layout.actionsOpacity < 1;
  return [
    for (final w in leading)
      fading
          ? IgnorePointer(
              ignoring: layout.actionsOpacity < 0.5,
              child: Opacity(opacity: layout.actionsOpacity, child: w),
            )
          : w,
    if (tabsExpand) ...[for (final t in tabs) Expanded(child: t)] else ...tabs,
  ];
}

/// The ellipsis control; reports its own global rectangle when tapped.
class _OverflowItem extends StatelessWidget {
  const _OverflowItem({required this.layout, required this.colors});

  final NavLayout layout;
  final NavBarColors colors;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => NavBarItem(
        icon: kOverflowIcon,
        label: BarStrings.overflow,
        selected: false,
        isSelectable: false,
        activeColor: colors.active,
        inactiveColor: colors.inactive,
        onTap: () {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || !box.hasSize) return;
          layout.onOverflow?.call(box.localToGlobal(Offset.zero) & box.size);
        },
      ),
    );
  }
}
