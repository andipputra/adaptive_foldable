import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:flutter/material.dart'
    show BottomNavigationBarItem, NavigationDestination;
import 'package:flutter/widgets.dart';

IconData _iconOf(Widget widget, String what) {
  assert(
    widget is Icon && widget.icon != null,
    '$what must be an Icon widget with an IconData; other widgets cannot be '
    'converted to a NavDestination. Build NavDestination values directly instead.',
  );
  return (widget as Icon).icon!;
}

/// Converts Material [NavigationDestination]s to [NavDestination]s.
///
/// Only [Icon] widgets carry an [IconData]; any other icon widget fails an assert.
List<NavDestination> destinationsFromNavigationDestinations(
  List<NavigationDestination> items,
) => [
  for (final d in items)
    NavDestination(
      icon: _iconOf(d.icon, 'NavigationDestination.icon'),
      selectedIcon: d.selectedIcon == null
          ? null
          : _iconOf(d.selectedIcon!, 'NavigationDestination.selectedIcon'),
      label: d.label,
    ),
];

/// Converts [BottomNavigationBarItem]s to [NavDestination]s.
///
/// Every item needs a non-empty label; only [Icon] widgets can be converted.
List<NavDestination> destinationsFromBottomNavigationBarItems(
  List<BottomNavigationBarItem> items,
) => [
  for (final i in items)
    NavDestination(
      icon: _iconOf(i.icon, 'BottomNavigationBarItem.icon'),
      selectedIcon: _iconOf(i.activeIcon, 'BottomNavigationBarItem.activeIcon'),
      label: () {
        assert(
          i.label != null && i.label!.isNotEmpty,
          'BottomNavigationBarItem needs a label',
        );
        return i.label ?? '';
      }(),
    ),
];
