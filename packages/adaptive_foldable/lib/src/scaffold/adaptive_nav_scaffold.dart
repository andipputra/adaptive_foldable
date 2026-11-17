import 'package:adaptive_foldable/src/debug/fold_debug_overlay.dart';
import 'package:adaptive_foldable/src/layout/geometry_resolver.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:adaptive_foldable/src/model/nav_geometry.dart';
import 'package:adaptive_foldable/src/model/nav_insets.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:adaptive_foldable/src/policy/apple_policy.dart';
import 'package:adaptive_foldable/src/policy/material_policy.dart';
import 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
import 'package:adaptive_foldable/src/scaffold/nav_transitions.dart';
import 'package:adaptive_foldable/src/scaffold/placeholder_nav_bar.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/fold_signals_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Draws the navigation bar for a resolved [NavLayout].
typedef NavBarBuilder = Widget Function(BuildContext context, NavLayout layout);

/// Draws the overflow menu for actions that did not fit; used from M2.
typedef NavOverflowBuilder = Widget Function(
  BuildContext context,
  List<NavAction> overflowed,
);

/// Places a navigation bar at the bottom or side edge and keeps the body in a fixed spot.
///
/// The widget tree is always a [Stack]: the body is padded, never reparented,
/// so scroll offsets, text fields and selected tabs survive every layout switch.
/// Requires a [FoldSignalsScope] above it.
class AdaptiveNavScaffold extends StatefulWidget {
  /// Creates a scaffold; [destinations] must not be empty and [selectedIndex] must be valid.
  const AdaptiveNavScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.body,
    this.policy,
    this.barBuilder,
    this.overflowBuilder,
    this.transitions = const NavTransitions(),
    this.debugOverlay = false,
    this.nativeOverflowMenu = false,
  }) : assert(destinations.length > 0, 'destinations must not be empty'),
       assert(
         selectedIndex >= 0 && selectedIndex < destinations.length,
         'selectedIndex is out of range',
       );

  /// The tabs.
  final List<NavDestination> destinations;

  /// Index of the selected tab.
  final int selectedIndex;

  /// Called with the index of a tapped tab.
  final ValueChanged<int> onSelected;

  /// The app content, usually the router shell.
  final Widget body;

  /// Placement policy; null means [ApplePolicy] on iOS and [MaterialPolicy] elsewhere.
  final NavPlacementPolicy? policy;

  /// Draws the bar; null uses a minimal placeholder bar until the default bars ship.
  final NavBarBuilder? barBuilder;

  /// Reserved for M2: draws the overflow menu. Accepted but unused; experimental.
  final NavOverflowBuilder? overflowBuilder;

  /// How layouts change visually; behaviour is wired in ANS-M1-008.
  final NavTransitions transitions;

  /// Whether to draw the signals overlay (debug builds only).
  final bool debugOverlay;

  /// Reserved: iOS native overflow menu. Accepted but ignored; experimental.
  final bool nativeOverflowMenu;

  @override
  State<AdaptiveNavScaffold> createState() => _AdaptiveNavScaffoldState();
}

class _AdaptiveNavScaffoldState extends State<AdaptiveNavScaffold> {
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'AdaptiveNavScaffold.body');

  NavPlacementPolicy get _policy =>
      widget.policy ??
      (defaultTargetPlatform == TargetPlatform.iOS
          ? const ApplePolicy()
          : const MaterialPolicy());

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final direction = Directionality.of(context);
    var signals = FoldSignals.of(context);
    if (signals.viewSize.isEmpty) {
      signals = FoldSignalsSnapshot.from(signals)
          .copyWith(viewSize: media.size);
    }

    final placement = _policy.resolve(signals, direction);
    final geometry = resolveGeometry(
      placement: placement,
      signals: signals,
      viewPadding: NavInsets(
        left: media.viewPadding.left,
        top: media.viewPadding.top,
        right: media.viewPadding.right,
        bottom: media.viewPadding.bottom,
      ),
      direction: direction,
    );
    final layout = NavLayout(
      placement: placement,
      geometry: geometry,
      destinations: widget.destinations,
      selectedIndex: widget.selectedIndex,
      onSelected: widget.onSelected,
      posture: signals.posture,
    );

    final bar =
        widget.barBuilder?.call(context, layout) ??
        PlaceholderNavBar(layout: layout);
    final inset = _bodyInsets(geometry, signals.viewSize);

    return FoldDebugOverlay(
      enabled: widget.debugOverlay,
      ruleLabel: placement.ruleId.isEmpty ? null : placement.ruleId,
      child: Stack(
        textDirection: direction,
        children: [
          Positioned.fill(
            child: Padding(
              padding: inset,
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: inset.left > 0,
                removeRight: inset.right > 0,
                removeBottom: inset.bottom > 0,
                child: KeyedSubtree(key: _bodyKey, child: widget.body),
              ),
            ),
          ),
          Positioned.fromRect(rect: geometry.barRect, child: bar),
        ],
      ),
    );
  }

  /// Padding that keeps the body clear of the bar, derived from where the bar sits.
  EdgeInsets _bodyInsets(NavGeometry geometry, Size size) {
    final r = geometry.barRect;
    if (r.isEmpty) return EdgeInsets.zero;
    if (r.width >= size.width - 0.5) {
      return EdgeInsets.only(
        bottom: (size.height - r.top).clamp(0, size.height),
      );
    }
    if (r.left <= 0.5) {
      return EdgeInsets.only(left: r.right.clamp(0, size.width));
    }
    return EdgeInsets.only(right: (size.width - r.left).clamp(0, size.width));
  }
}
