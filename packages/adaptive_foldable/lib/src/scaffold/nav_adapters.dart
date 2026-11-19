import 'package:adaptive_foldable/src/model/nav_destination.dart';
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

/// Builds a [NavDestination] from the icon widgets an existing navigation bar already uses.
///
/// Migration helper for `NavigationDestination(icon:, selectedIcon:, label:)` and
/// `BottomNavigationBarItem(icon:, activeIcon:, label:)` lists:
///
/// ```dart
/// destinations: [
///   for (final d in oldDestinations)
///     navDestinationFromIcons(icon: d.icon, selectedIcon: d.selectedIcon, label: d.label),
/// ]
/// ```
///
/// Only [Icon] widgets carry an [IconData]; any other widget throws an
/// [ArgumentError], as does an empty [label]. Tooltips, badges and enabled
/// state of the source are not carried over.
NavDestination navDestinationFromIcons({
  required Widget icon,
  Widget? selectedIcon,
  required String label,
  int? badgeCount,
}) {
  if (label.isEmpty) {
    throw ArgumentError.value(label, 'label', 'must not be empty');
  }
  return NavDestination(
    icon: _iconOf(icon, 'icon'),
    selectedIcon: selectedIcon == null
        ? null
        : _iconOf(selectedIcon, 'selectedIcon'),
    label: label,
    badgeCount: badgeCount,
  );
}
