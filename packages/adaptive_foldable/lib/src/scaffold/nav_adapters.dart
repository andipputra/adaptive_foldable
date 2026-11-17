import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:flutter/material.dart'
    show BottomNavigationBarItem, NavigationDestination;
import 'package:flutter/widgets.dart';

IconData _iconOf(Widget widget, String what) {
  if (widget is Icon && widget.icon != null) return widget.icon!;
  throw ArgumentError.value(
    widget,
    what,
    'must be an Icon widget with an IconData; other widgets cannot be '
    'converted to a NavDestination. Build NavDestination values directly instead.',
  );
}

/// Converts Material [NavigationDestination]s to [NavDestination]s.
///
/// Only [Icon] widgets carry an [IconData]; any other icon widget throws an
/// [ArgumentError]. `enabled`, `tooltip` and `badge` of the source are not carried over.
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
/// Every item needs a non-empty label (checked with an [ArgumentError]); only
/// [Icon] widgets can be converted. `tooltip` and `backgroundColor` are not carried over.
List<NavDestination> destinationsFromBottomNavigationBarItems(
  List<BottomNavigationBarItem> items,
) => [
  for (final i in items)
    NavDestination(
      icon: _iconOf(i.icon, 'BottomNavigationBarItem.icon'),
      selectedIcon: _iconOf(i.activeIcon, 'BottomNavigationBarItem.activeIcon'),
      label: _labelOf(i),
    ),
];

String _labelOf(BottomNavigationBarItem item) {
  final label = item.label;
  if (label == null || label.isEmpty) {
    throw ArgumentError.value(
      item,
      'item',
      'BottomNavigationBarItem needs a label',
    );
  }
  return label;
}
