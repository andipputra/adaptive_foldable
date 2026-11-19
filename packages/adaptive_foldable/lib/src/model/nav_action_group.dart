import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:flutter/foundation.dart' show listEquals;

/// Actions that stay together and are separated from other groups in the bar.
class NavActionGroup {
  /// Creates a group holding [actions].
  const NavActionGroup(this.actions);

  /// The actions in display order.
  final List<NavAction> actions;

  @override
  bool operator ==(Object other) =>
      other is NavActionGroup && listEquals(other.actions, actions);

  @override
  int get hashCode => Object.hashAll(actions);
}
