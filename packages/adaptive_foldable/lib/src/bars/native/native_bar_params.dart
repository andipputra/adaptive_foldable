import 'package:adaptive_foldable/src/model/nav_destination.dart';

/// View type of the native tab bar platform view.
const String kNativeBarViewType = 'dev.adaptivefoldable/native_bar';

/// Encodes [destinations] and the selection as creation and update params for the native bar.
///
/// [icons] maps a destination index to PNG bytes (`icon`) and, when present, its
/// selected variant (`selectedIcon`); destinations with an `sfSymbol` need none.
Map<String, Object?> buildNativeBarParams({
  required List<NavDestination> destinations,
  required int selectedIndex,
  Map<int, ({List<int>? icon, List<int>? selectedIcon})> icons = const {},
}) => {
  'selectedIndex': selectedIndex,
  'items': [
    for (var i = 0; i < destinations.length; i++)
      {
        'label': destinations[i].label,
        'sfSymbol': destinations[i].sfSymbol,
        'icon': icons[i]?.icon,
        'selectedIcon': icons[i]?.selectedIcon,
        'badge': destinations[i].badgeCount,
      },
  ],
};
