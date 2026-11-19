import 'dart:ui' show TextDirection;

import 'package:adaptive_foldable/src/model/nav_action_placement.dart';
import 'package:adaptive_foldable/src/model/page_actions.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Pure assignment result of page actions across panes in a multi-pane layout.
class PaneActionAssignment {
  /// Creates an assignment.
  const PaneActionAssignment({
    required this.columnPaneId,
    required this.columnActions,
    required this.headerPaneActions,
  });

  /// The pane that owns the primary/side navigation column.
  final String columnPaneId;

  /// Actions assigned to the side navigation column.
  final PageActions columnActions;

  /// Actions assigned to individual pane header bars, keyed by pane ID.
  final Map<String, PageActions> headerPaneActions;
}

/// Resolves the owner pane for the side column and partitions actions between
/// the column and pane header strips.
PaneActionAssignment resolvePaneActions({
  required List<String> activePaneIds,
  required NavEdge? barEdge,
  required Map<String, PageActions> publishedActions,
  required TextDirection textDirection,
  String primaryPaneId = 'start',
  String secondaryPaneId = 'end',
  String singlePaneId = 'main',
}) {
  if (activePaneIds.isEmpty) {
    return PaneActionAssignment(
      columnPaneId: singlePaneId,
      columnActions: publishedActions[singlePaneId] ?? PageActions.empty,
      headerPaneActions: const {},
    );
  }

  if (activePaneIds.length == 1) {
    final solePane = activePaneIds.first;
    return PaneActionAssignment(
      columnPaneId: solePane,
      columnActions: publishedActions[solePane] ?? PageActions.empty,
      headerPaneActions: const {},
    );
  }

  // Two or more active panes
  final String columnOwner = resolveColumnOwnerPaneId(
    activePaneIds: activePaneIds,
    barEdge: barEdge,
    textDirection: textDirection,
    primaryPaneId: primaryPaneId,
    secondaryPaneId: secondaryPaneId,
    singlePaneId: singlePaneId,
  );

  final Map<String, PageActions> headerActions = {};
  PageActions columnActions =
      publishedActions[columnOwner] ?? PageActions.empty;

  // Process each pane's actions respecting placement overrides
  for (final paneId in activePaneIds) {
    final actions = publishedActions[paneId];
    if (actions == null || actions.isEmpty) continue;

    switch (actions.placement) {
      case NavActionPlacement.column:
        if (paneId == columnOwner) {
          // Already in column
        } else {
          // Merge into column actions
          columnActions = PageActions(
            prominentAction:
                columnActions.prominentAction ?? actions.prominentAction,
            groups: [...columnActions.groups, ...actions.groups],
            overflowItems: [
              ...columnActions.overflowItems,
              ...actions.overflowItems,
            ],
            compression: columnActions.compression,
            placement: NavActionPlacement.column,
          );
        }
      case NavActionPlacement.paneHeader:
        headerActions[paneId] = actions;
        if (paneId == columnOwner) {
          columnActions = PageActions.empty;
        }
      case NavActionPlacement.auto:
        if (paneId == columnOwner) {
          // Already assigned to column
        } else {
          headerActions[paneId] = actions;
        }
    }
  }

  return PaneActionAssignment(
    columnPaneId: columnOwner,
    columnActions: columnActions,
    headerPaneActions: headerActions,
  );
}

/// Resolves which pane physically touches the navigation column.
String resolveColumnOwnerPaneId({
  required List<String> activePaneIds,
  required NavEdge? barEdge,
  required TextDirection textDirection,
  String primaryPaneId = 'start',
  String secondaryPaneId = 'end',
  String singlePaneId = 'main',
}) {
  if (activePaneIds.length <= 1) {
    return activePaneIds.isNotEmpty ? activePaneIds.first : singlePaneId;
  }

  if (barEdge == null) {
    return activePaneIds.contains(secondaryPaneId)
        ? secondaryPaneId
        : activePaneIds.first;
  }

  final isLtr = textDirection == TextDirection.ltr;
  final bool isLeftEdge;
  final bool isRightEdge;

  switch (barEdge) {
    case NavEdge.left:
      isLeftEdge = true;
      isRightEdge = false;
    case NavEdge.right:
      isLeftEdge = false;
      isRightEdge = true;
    case NavEdge.leading:
      isLeftEdge = isLtr;
      isRightEdge = !isLtr;
    case NavEdge.trailing:
      isLeftEdge = !isLtr;
      isRightEdge = isLtr;
    case NavEdge.bottom:
      // Horizontal bar: default to secondary (detail) pane if active
      return activePaneIds.contains(secondaryPaneId)
          ? secondaryPaneId
          : activePaneIds.first;
  }

  // In LTR: primaryPane (start) is on left, secondaryPane (end) is on right.
  // In RTL: primaryPane (start) is on right, secondaryPane (end) is on left.
  final touchesStart = isLtr ? isLeftEdge : isRightEdge;
  final touchesEnd = isLtr ? isRightEdge : isLeftEdge;

  if (touchesStart && activePaneIds.contains(primaryPaneId)) {
    return primaryPaneId;
  }
  if (touchesEnd && activePaneIds.contains(secondaryPaneId)) {
    return secondaryPaneId;
  }

  return activePaneIds.first;
}
