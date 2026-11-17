import 'dart:ui' show Rect, TextDirection;

import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/policy/fallback_heuristic.dart';
import 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Placement that mirrors the iOS system bar decision.
///
/// Edges are physical and never flip in right-to-left layout, so `direction`
/// is ignored. Rules, in order:
/// 1. [ruleSystemEdge]: the system reports a bar edge; use it (Duo cover display,
///    inner landscape, book pose).
/// 2. [ruleTabletop]: partially open with a horizontal hinge; the system
///    decides, so use a bottom bar.
/// 3. [ruleBridgeNoEdge]: the bridge answered without an edge (regular iPhone,
///    iPad, Duo inner portrait, or no Duo SDK); use a bottom bar.
/// 4. [ruleFallback]: the bridge is unavailable and the SDK flag is unknown;
///    use the fallback heuristic.
class ApplePolicy implements NavPlacementPolicy {
  /// Creates the policy.
  const ApplePolicy();

  /// Rule id: the system-reported physical edge.
  static const String ruleSystemEdge = 'apple.system-edge';

  /// Rule id: tabletop pose, bottom bar.
  static const String ruleTabletop = 'apple.tabletop';

  /// Rule id: bridge answered with no edge, bottom bar.
  static const String ruleBridgeNoEdge = 'apple.bridge-no-edge';

  /// Rule id: fallback heuristic result.
  static const String ruleFallback = 'apple.fallback';

  @override
  NavPlacement resolve(FoldSignals signals, TextDirection direction) {
    final edge = signals.verticalBarEdge;
    if (edge != null) {
      return NavPlacement(edge, ruleId: ruleSystemEdge);
    }
    if (_isTabletop(signals)) {
      return const NavPlacement(NavEdge.bottom, ruleId: ruleTabletop);
    }
    if (signals.isAvailable || signals.sdk271) {
      return const NavPlacement(NavEdge.bottom, ruleId: ruleBridgeNoEdge);
    }
    return NavPlacement(
      fallbackBarEdge(signals, direction),
      ruleId: ruleFallback,
    );
  }

  static bool _isTabletop(FoldSignals signals) {
    if (signals.posture != Posture.partiallyOpen) return false;
    return signals.activeFolds.any((Rect r) => r.width > r.height);
  }
}
