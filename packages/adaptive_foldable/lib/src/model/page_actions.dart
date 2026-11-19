import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_action_group.dart';
import 'package:adaptive_foldable/src/model/nav_action_placement.dart';
import 'package:adaptive_foldable/src/model/nav_compression.dart';
import 'package:flutter/foundation.dart' show listEquals;

/// The actions one page publishes to the navigation bar.
class PageActions {
  /// Creates a set of page actions.
  const PageActions({
    this.prominentAction,
    this.groups = const [],
    this.overflowItems = const [],
    this.compression = NavCompression.navigation,
    this.placement = NavActionPlacement.auto,
  });

  /// No actions: tabs only.
  static const PageActions empty = PageActions();

  /// The pinned action, if any.
  final NavAction? prominentAction;

  /// Action groups in display order.
  final List<NavActionGroup> groups;

  /// Actions that always live in the overflow menu.
  final List<NavAction> overflowItems;

  /// Which part of the bar gives way first when space runs out.
  final NavCompression compression;

  /// Where the actions are shown when there are several panes.
  final NavActionPlacement placement;

  /// Total number of actions in [groups].
  int get groupActionCount =>
      groups.fold(0, (sum, g) => sum + g.actions.length);

  /// Whether [other] would draw the same bar: equal in everything except the `onPressed` callbacks.
  ///
  /// Pages usually pass inline lambdas, which are never equal across rebuilds;
  /// comparing them would republish the actions on every rebuild.
  bool sameContentAs(PageActions other) =>
      _sameAction(prominentAction, other.prominentAction) &&
      groups.length == other.groups.length &&
      Iterable<int>.generate(groups.length).every(
        (i) => _sameActions(groups[i].actions, other.groups[i].actions),
      ) &&
      _sameActions(overflowItems, other.overflowItems) &&
      compression == other.compression &&
      placement == other.placement;

  static bool _sameAction(NavAction? a, NavAction? b) => a == null || b == null
      ? a == b
      : a.icon == b.icon &&
            a.sfSymbol == b.sfSymbol &&
            a.label == b.label &&
            a.priority == b.priority &&
            a.isDestructive == b.isDestructive &&
            a.enabled == b.enabled &&
            a.selected == b.selected &&
            a.badgeCount == b.badgeCount;

  static bool _sameActions(List<NavAction> a, List<NavAction> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((i) => _sameAction(a[i], b[i]));

  @override
  bool operator ==(Object other) =>
      other is PageActions &&
      other.prominentAction == prominentAction &&
      listEquals(other.groups, groups) &&
      listEquals(other.overflowItems, overflowItems) &&
      other.compression == compression &&
      other.placement == placement;

  @override
  int get hashCode => Object.hash(
    prominentAction,
    Object.hashAll(groups),
    Object.hashAll(overflowItems),
    compression,
    placement,
  );
}
