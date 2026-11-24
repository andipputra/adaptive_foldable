import 'dart:ui' show Rect, TextDirection;

import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Placement that follows Material 3 window size classes and foldable postures.
///
/// By default every width and posture keeps a bottom bar; the rail is opt-in
/// through [railOnWide]. Edges are logical ([NavEdge.leading]); the scaffold
/// maps them to a physical edge from the text direction. No rule ever yields a
/// navigation drawer. Rules, in order (the edge shown is for `railOnWide: true`):
/// 1. [ruleTabletop]: partially open with a horizontal hinge; bottom bar below
///    the hinge.
/// 2. [ruleBook]: partially open with a vertical hinge; rail on the leading edge.
/// 3. [ruleCompact]: width below [compactMaxWidth]; bottom bar.
/// 4. [ruleMedium]: width from [compactMaxWidth] below [expandedMinWidth]; rail.
/// 5. [ruleExpanded]: width of [expandedMinWidth] or more; rail.
class MaterialPolicy implements NavPlacementPolicy {
  /// Creates the policy.
  ///
  /// With [railOnWide] true, book pose and widths of [compactMaxWidth] or more
  /// use a leading rail instead of the bottom bar.
  const MaterialPolicy({this.railOnWide = false});

  /// Whether book pose and medium or expanded widths use a leading rail.
  final bool railOnWide;

  /// Width in dp at which the medium size class starts (exclusive upper bound of compact).
  static const double compactMaxWidth = 600;

  /// Width in dp at which the expanded size class starts.
  static const double expandedMinWidth = 840;

  /// Rule id: tabletop pose, bottom bar.
  static const String ruleTabletop = 'material.tabletop';

  /// Rule id: book pose, leading rail.
  static const String ruleBook = 'material.book';

  /// Rule id: compact width, bottom bar.
  static const String ruleCompact = 'material.compact';

  /// Rule id: medium width, leading rail.
  static const String ruleMedium = 'material.medium';

  /// Rule id: expanded width, leading rail.
  static const String ruleExpanded = 'material.expanded';

  @override
  NavPlacement resolve(FoldSignals signals, TextDirection direction) {
    final side = railOnWide ? NavEdge.leading : NavEdge.bottom;
    if (signals.posture == Posture.partiallyOpen) {
      final folds = signals.activeFolds;
      if (folds.any((Rect r) => r.width > r.height)) {
        return const NavPlacement(
          NavEdge.bottom,
          ruleId: ruleTabletop,
          actionsInHeader: true,
        );
      }
      if (folds.isNotEmpty) {
        return NavPlacement(side, ruleId: ruleBook, actionsInHeader: true);
      }
    }
    final width = signals.viewSize.width;
    if (width < compactMaxWidth) {
      return const NavPlacement(
        NavEdge.bottom,
        ruleId: ruleCompact,
        actionsInHeader: true,
      );
    }
    return NavPlacement(
      side,
      ruleId: width < expandedMinWidth ? ruleMedium : ruleExpanded,
      actionsInHeader: true,
    );
  }
}
