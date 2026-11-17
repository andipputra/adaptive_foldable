import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_action_group.dart';
import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:adaptive_foldable/src/model/nav_geometry.dart';
import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart'
    show ValueChanged, VoidCallback, listEquals;

/// The resolved navigation layout that a bar builder draws.
class NavLayout {
  /// Creates a layout.
  const NavLayout({
    required this.placement,
    required this.geometry,
    this.showBack = false,
    this.onBack,
    this.prominentAction,
    this.visibleActions = const [],
    this.overflowedActions = const [],
    this.headerActions = const [],
    this.tabsCompressed = false,
    this.destinations = const [],
    this.selectedIndex = 0,
    this.onSelected,
    this.paneCount = 1,
    this.posture = Posture.unknown,
  }) : assert(paneCount == 1 || paneCount == 2, 'paneCount must be 1 or 2');

  /// The edge holding the bar.
  final NavPlacement placement;

  /// Bar rectangle, skip region, item axis and clearances.
  final NavGeometry geometry;

  /// Whether the current page's navigator can pop.
  final bool showBack;

  /// Pops the current page's navigator; null when [showBack] is false.
  final VoidCallback? onBack;

  /// The pinned action, if any.
  final NavAction? prominentAction;

  /// Action groups that fit, in Apple's order.
  final List<NavActionGroup> visibleActions;

  /// Actions moved into the overflow menu.
  final List<NavAction> overflowedActions;

  /// Actions not moved into the rail, drawn in a pane header (Android).
  final List<NavActionGroup> headerActions;

  /// Whether the tab bar is minimized to one control (task mode).
  final bool tabsCompressed;

  /// The tabs.
  final List<NavDestination> destinations;

  /// Index of the selected tab.
  final int selectedIndex;

  /// Called with the index of a tapped tab.
  final ValueChanged<int>? onSelected;

  /// Number of visible panes, 1 or 2; always 1 until the fold kit (M3) reports two-pane layouts.
  final int paneCount;

  /// The device posture.
  final Posture posture;

  /// Returns a copy with the given fields replaced.
  ///
  /// Nullable fields keep their value when omitted; pass the matching `clear*`
  /// flag to reset one to null.
  NavLayout copyWith({
    NavPlacement? placement,
    NavGeometry? geometry,
    bool? showBack,
    VoidCallback? onBack,
    bool clearOnBack = false,
    NavAction? prominentAction,
    bool clearProminentAction = false,
    List<NavActionGroup>? visibleActions,
    List<NavAction>? overflowedActions,
    List<NavActionGroup>? headerActions,
    bool? tabsCompressed,
    List<NavDestination>? destinations,
    int? selectedIndex,
    ValueChanged<int>? onSelected,
    bool clearOnSelected = false,
    int? paneCount,
    Posture? posture,
  }) => NavLayout(
    placement: placement ?? this.placement,
    geometry: geometry ?? this.geometry,
    showBack: showBack ?? this.showBack,
    onBack: clearOnBack ? null : (onBack ?? this.onBack),
    prominentAction: clearProminentAction
        ? null
        : (prominentAction ?? this.prominentAction),
    visibleActions: visibleActions ?? this.visibleActions,
    overflowedActions: overflowedActions ?? this.overflowedActions,
    headerActions: headerActions ?? this.headerActions,
    tabsCompressed: tabsCompressed ?? this.tabsCompressed,
    destinations: destinations ?? this.destinations,
    selectedIndex: selectedIndex ?? this.selectedIndex,
    onSelected: clearOnSelected ? null : (onSelected ?? this.onSelected),
    paneCount: paneCount ?? this.paneCount,
    posture: posture ?? this.posture,
  );

  @override
  bool operator ==(Object other) =>
      other is NavLayout &&
      other.placement == placement &&
      other.geometry == geometry &&
      other.showBack == showBack &&
      other.onBack == onBack &&
      other.prominentAction == prominentAction &&
      listEquals(other.visibleActions, visibleActions) &&
      listEquals(other.overflowedActions, overflowedActions) &&
      listEquals(other.headerActions, headerActions) &&
      other.tabsCompressed == tabsCompressed &&
      listEquals(other.destinations, destinations) &&
      other.selectedIndex == selectedIndex &&
      other.onSelected == onSelected &&
      other.paneCount == paneCount &&
      other.posture == posture;

  @override
  int get hashCode => Object.hash(
    placement,
    geometry,
    showBack,
    onBack,
    prominentAction,
    Object.hashAll(visibleActions),
    Object.hashAll(overflowedActions),
    Object.hashAll(headerActions),
    tabsCompressed,
    Object.hashAll(destinations),
    selectedIndex,
    onSelected,
    paneCount,
    posture,
  );
}
