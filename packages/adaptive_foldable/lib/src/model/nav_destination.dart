import 'package:flutter/widgets.dart' show IconData;

/// A tab the user can select in the navigation bar.
class NavDestination {
  /// Creates a destination; [label] must not be empty.
  const NavDestination({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
    this.sfSymbol,
  }) : assert(label != '', 'NavDestination.label must not be empty');

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Text used for the visible label, tooltip and screen reader.
  final String label;

  /// Icon shown when selected; falls back to [icon] when null.
  final IconData? selectedIcon;

  /// Number shown in a badge, or null for none.
  final int? badgeCount;

  /// SF Symbol name used by the native iOS bar; the Flutter [icon] is rendered instead when null.
  final String? sfSymbol;

  /// Returns a copy with the given fields replaced.
  NavDestination copyWith({
    IconData? icon,
    String? label,
    IconData? selectedIcon,
    bool clearSelectedIcon = false,
    int? badgeCount,
    bool clearBadgeCount = false,
    String? sfSymbol,
    bool clearSfSymbol = false,
  }) => NavDestination(
    icon: icon ?? this.icon,
    label: label ?? this.label,
    selectedIcon: clearSelectedIcon
        ? null
        : (selectedIcon ?? this.selectedIcon),
    badgeCount: clearBadgeCount ? null : (badgeCount ?? this.badgeCount),
    sfSymbol: clearSfSymbol ? null : (sfSymbol ?? this.sfSymbol),
  );

  @override
  bool operator ==(Object other) =>
      other is NavDestination &&
      other.icon == icon &&
      other.label == label &&
      other.selectedIcon == selectedIcon &&
      other.badgeCount == badgeCount &&
      other.sfSymbol == sfSymbol;

  @override
  int get hashCode =>
      Object.hash(icon, label, selectedIcon, badgeCount, sfSymbol);
}
