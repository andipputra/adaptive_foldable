import 'package:adaptive_foldable/src/model/nav_priority.dart';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/widgets.dart' show IconData;

/// A command shown in the navigation bar or its overflow menu.
class NavAction {
  /// Creates an action; [label] must not be empty.
  const NavAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.sfSymbol,
    this.priority = NavPriority.normal,
    this.isDestructive = false,
    this.enabled = true,
    this.selected = false,
    this.badgeCount,
  }) : assert(label != '', 'NavAction.label must not be empty');

  /// Icon used by Flutter-drawn bars and menus.
  final IconData icon;

  /// SF Symbol name for the native iOS menu; optional.
  final String? sfSymbol;

  /// Text used for the tooltip, overflow menu and screen reader.
  final String label;

  /// Called when the action is activated.
  final VoidCallback onPressed;

  /// Overflow order; lower values overflow first.
  final NavPriority priority;

  /// Whether the action is drawn in the destructive style.
  final bool isDestructive;

  /// Whether the action can be activated.
  final bool enabled;

  /// Whether the action shows a checked state.
  final bool selected;

  /// Number shown in a badge; actions with a badge rank higher in overflow.
  final int? badgeCount;

  /// Returns a copy with the given fields replaced.
  NavAction copyWith({
    IconData? icon,
    String? sfSymbol,
    bool clearSfSymbol = false,
    String? label,
    VoidCallback? onPressed,
    NavPriority? priority,
    bool? isDestructive,
    bool? enabled,
    bool? selected,
    int? badgeCount,
    bool clearBadgeCount = false,
  }) => NavAction(
    icon: icon ?? this.icon,
    sfSymbol: clearSfSymbol ? null : (sfSymbol ?? this.sfSymbol),
    label: label ?? this.label,
    onPressed: onPressed ?? this.onPressed,
    priority: priority ?? this.priority,
    isDestructive: isDestructive ?? this.isDestructive,
    enabled: enabled ?? this.enabled,
    selected: selected ?? this.selected,
    badgeCount: clearBadgeCount ? null : (badgeCount ?? this.badgeCount),
  );

  @override
  bool operator ==(Object other) =>
      other is NavAction &&
      other.icon == icon &&
      other.sfSymbol == sfSymbol &&
      other.label == label &&
      other.onPressed == onPressed &&
      other.priority == priority &&
      other.isDestructive == isDestructive &&
      other.enabled == enabled &&
      other.selected == selected &&
      other.badgeCount == badgeCount;

  @override
  int get hashCode => Object.hash(
    icon,
    sfSymbol,
    label,
    onPressed,
    priority,
    isDestructive,
    enabled,
    selected,
    badgeCount,
  );
}
