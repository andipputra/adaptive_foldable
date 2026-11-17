import 'dart:math' as math;

import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_action_group.dart';
import 'package:adaptive_foldable/src/model/nav_compression.dart';
import 'package:adaptive_foldable/src/model/page_actions.dart';

/// Smallest slot size in logical pixels: one tap target.
const double kMinItemExtent = 44;

/// What fits in the bar and what moved into the overflow menu.
class OverflowResult {
  /// Creates a result.
  const OverflowResult({
    required this.visibleGroups,
    required this.overflowed,
    required this.tabsCompressed,
  });

  /// Groups with the actions that fit, in original order; empty groups are dropped.
  final List<NavActionGroup> visibleGroups;

  /// Actions that did not fit in original order, then the page's `overflowItems`.
  final List<NavAction> overflowed;

  /// Whether the tab bar minimized to one control.
  final bool tabsCompressed;
}

/// Fits [actions] into [extent] logical pixels along the bar axis.
///
/// Slot size is `max(kMinItemExtent, itemExtent * max(1, textScale))`. Fit order
/// follows Apple: Back ([hasBack]), the prominent action, groups top to bottom,
/// then [tabCount] tabs at the foot. When space runs out:
///
/// - In [NavCompression.task] the tabs minimize to one control first.
/// - Then group actions overflow bottom-up. Removal order is by group rank
///   (the best item rank in the group, lowest first, later group first on a
///   tie), then by item rank inside the group (lowest first, later item first
///   on a tie). Item rank is `priority * 2`, plus 1 when the item has a badge.
/// - The ellipsis control takes one slot whenever anything overflows, including
///   the page's `overflowItems`.
/// - Back, the prominent action and the tabs never overflow; if they alone do
///   not fit, they are still returned.
///
/// Visible and overflowed actions together equal the input set, and both keep
/// the input order.
OverflowResult resolveOverflow({
  required PageActions actions,
  required double extent,
  required double itemExtent,
  required double textScale,
  required NavCompression mode,
  required int tabCount,
  bool hasBack = false,
}) {
  final slot = math.max(kMinItemExtent, itemExtent * math.max(1, textScale));
  final slots = extent.isNaN || extent <= 0
      ? 0
      : extent.isInfinite
      ? 1 << 30
      : (extent / slot).floor();

  var tabsCompressed = false;
  var tabSlots = tabCount;
  final fixed = (hasBack ? 1 : 0) + (actions.prominentAction != null ? 1 : 0);
  final total = actions.groupActionCount;
  final hasPageOverflow = actions.overflowItems.isNotEmpty;

  bool fits(int shown, int tabsUsed) {
    final overflowSlot = (shown < total || hasPageOverflow) ? 1 : 0;
    return fixed + shown + overflowSlot + tabsUsed <= slots;
  }

  var shown = total;
  if (!fits(shown, tabSlots) && mode == NavCompression.task && tabCount > 1) {
    tabsCompressed = true;
    tabSlots = 1;
  }

  final removalOrder = _removalOrder(actions.groups);
  final removed = <(int, int)>{};
  var cursor = 0;
  while (!fits(shown, tabSlots) && cursor < removalOrder.length) {
    removed.add(removalOrder[cursor++]);
    shown--;
  }

  final visible = <NavActionGroup>[];
  final overflowed = <NavAction>[];
  for (var g = 0; g < actions.groups.length; g++) {
    final kept = <NavAction>[];
    final items = actions.groups[g].actions;
    for (var i = 0; i < items.length; i++) {
      (removed.contains((g, i)) ? overflowed : kept).add(items[i]);
    }
    if (kept.isNotEmpty) visible.add(NavActionGroup(kept));
  }
  overflowed.addAll(actions.overflowItems);

  return OverflowResult(
    visibleGroups: visible,
    overflowed: overflowed,
    tabsCompressed: tabsCompressed,
  );
}

int _rank(NavAction a) =>
    a.priority.index * 2 + ((a.badgeCount ?? 0) > 0 ? 1 : 0);

/// Positions `(group, item)` in the order they leave the bar: lowest-ranked group and item first.
List<(int, int)> _removalOrder(List<NavActionGroup> groups) {
  final ranked =
      [
        for (var g = 0; g < groups.length; g++)
          (
            index: g,
            rank: groups[g].actions.isEmpty
                ? -1
                : groups[g].actions.map(_rank).reduce(math.max),
          ),
      ]..sort((a, b) {
        final byRank = a.rank.compareTo(b.rank);
        return byRank != 0 ? byRank : b.index.compareTo(a.index);
      });
  final order = <(int, int)>[];
  for (final g in ranked) {
    final items =
        [
          for (var i = 0; i < groups[g.index].actions.length; i++)
            (index: i, rank: _rank(groups[g.index].actions[i])),
        ]..sort((a, b) {
          final byRank = a.rank.compareTo(b.rank);
          return byRank != 0 ? byRank : b.index.compareTo(a.index);
        });
    order.addAll(items.map((e) => (g.index, e.index)));
  }
  return order;
}
