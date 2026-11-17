import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';

/// Colours a default bar applies to its items.
class NavBarColors {
  /// Creates a colour set.
  const NavBarColors({
    required this.background,
    required this.active,
    required this.inactive,
    this.indicator,
  });

  /// Bar background.
  final Color background;

  /// Selected content.
  final Color active;

  /// Unselected content.
  final Color inactive;

  /// Pill behind the selected icon, or null.
  final Color? indicator;
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
    enabled: a.enabled,
    onTap: a.onPressed,
    badgeCount: a.badgeCount,
    activeColor: a.isDestructive ? const Color(0xFFB3261E) : colors.active,
    inactiveColor: a.isDestructive ? const Color(0xFFB3261E) : colors.inactive,
  );

  final leading = <Widget>[
    if (layout.showBack)
      NavBarItem(
        icon: Icons.arrow_back,
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
  ];
  final tabs = <Widget>[
    for (var i = 0; i < layout.destinations.length; i++)
      NavBarItem(
        icon: i == layout.selectedIndex
            ? layout.destinations[i].selectedIcon ?? layout.destinations[i].icon
            : layout.destinations[i].icon,
        label: layout.destinations[i].label,
        selected: i == layout.selectedIndex,
        badgeCount: layout.destinations[i].badgeCount,
        indicatorColor: colors.indicator,
        activeColor: colors.active,
        inactiveColor: colors.inactive,
        onTap: () => layout.onSelected?.call(i),
      ),
  ];
  return [
    ...leading,
    if (tabsExpand) ...[for (final t in tabs) Expanded(child: t)] else ...tabs,
  ];
}
