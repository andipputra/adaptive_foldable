import 'dart:async';
import 'dart:math' as math;

import 'package:adaptive_foldable/src/bars/cupertino/cupertino_style_nav_bar.dart';
import 'package:adaptive_foldable/src/bars/material/material_nav_bar.dart';
import 'package:adaptive_foldable/src/debug/fold_debug_overlay.dart';
import 'package:adaptive_foldable/src/layout/geometry_resolver.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_axis.dart';
import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:adaptive_foldable/src/model/nav_geometry.dart';
import 'package:adaptive_foldable/src/model/nav_insets.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:adaptive_foldable/src/policy/apple_policy.dart';
import 'package:adaptive_foldable/src/policy/material_policy.dart';
import 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
import 'package:adaptive_foldable/src/scaffold/nav_transitions.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/fold_signals_scope.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/widgets.dart';

/// Draws the navigation bar for a resolved [NavLayout].
typedef NavBarBuilder = Widget Function(BuildContext context, NavLayout layout);

/// Called when placement, pane count or posture changes, once the change has settled.
typedef NavLayoutChanged = void Function(NavLayout previous, NavLayout next);

/// Settle time after the last signal change before [AdaptiveNavScaffold.onLayoutChanged] fires.
///
/// Reserved regions lag the hinge by up to about a second on iOS; revisited on
/// the simulator in ANS-M1-013.
const Duration kLayoutSettleDelay = Duration(milliseconds: 150);

/// Draws the overflow menu for actions that did not fit; used from M2.
typedef NavOverflowBuilder = Widget Function(
  BuildContext context,
  List<NavAction> overflowed,
);

/// Places a navigation bar at the bottom or side edge and keeps the body in a fixed spot.
///
/// The widget tree is always a [Stack]: the body is padded, never reparented,
/// so scroll offsets, text fields and selected tabs survive every layout switch.
/// Requires a [FoldSignalsScope] above it, and must fill the Flutter view:
/// the bar rectangle is resolved in view coordinates.
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
    this.onLayoutChanged,
    this.extendBodyBehindBar = false,
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

  /// Draws the bar; null uses [cupertinoBarBuilder] on iOS and macOS and [materialBarBuilder] elsewhere.
  final NavBarBuilder? barBuilder;

  /// Reserved for M2: draws the overflow menu. Accepted but unused; experimental.
  final NavOverflowBuilder? overflowBuilder;

  /// How layouts change visually.
  final NavTransitions transitions;

  /// Whether to draw the signals overlay (debug builds only).
  final bool debugOverlay;

  /// Reserved: iOS native overflow menu. Accepted but ignored; experimental.
  final bool nativeOverflowMenu;

  /// Called once per settled change of placement, pane count or posture; never on ordinary rebuilds.
  final NavLayoutChanged? onLayoutChanged;

  /// Whether the body background runs under a side column.
  ///
  /// Content stays clear: `MediaQuery.padding` still reserves the bar extent.
  /// Has no effect on a bottom bar, or when a fold cut the bar short.
  final bool extendBodyBehindBar;

  @override
  State<AdaptiveNavScaffold> createState() => _AdaptiveNavScaffoldState();
}

class _AdaptiveNavScaffoldState extends State<AdaptiveNavScaffold> {
  final GlobalKey _bodyKey = GlobalKey(debugLabel: 'AdaptiveNavScaffold.body');

  // Updated after each frame, never during build.
  NavLayout? _lastSeen;
  Size? _lastSize;
  NavLayout? _lastReported;
  NavLayout? _pending;
  Timer? _settleTimer;
  NavLayout? _frameLayout;
  Size _frameSize = Size.zero;
  bool _trackScheduled = false;

  TargetPlatform get _platform => defaultTargetPlatform;

  bool get _isApple =>
      _platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS;

  NavPlacementPolicy get _policy =>
      widget.policy ??
      (_platform == TargetPlatform.iOS
          ? const ApplePolicy()
          : const MaterialPolicy());

  @override
  void didUpdateWidget(AdaptiveNavScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onLayoutChanged != widget.onLayoutChanged) {
      _settleTimer?.cancel();
      _pending = null;
      _lastReported = _lastSeen;
    }
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    super.dispose();
  }

  bool _sameKey(NavLayout a, NavLayout b) =>
      a.placement == b.placement &&
      a.paneCount == b.paneCount &&
      a.posture == b.posture;

  /// Chooses the bar transition for [layout] by comparing with the last settled frame.
  Duration _transitionFor(NavLayout layout, Size size, bool reduceMotion) {
    final seen = _lastSeen;
    if (seen == null || seen.placement == layout.placement) {
      return Duration.zero;
    }
    final t = widget.transitions;
    final kind = seen.posture != layout.posture
        ? t.onFoldChange
        : (_lastSize != size ? t.onResize : NavTransition.instant);
    final instant =
        kind == NavTransition.instant ||
        (t.respectReduceMotion && reduceMotion);
    return instant ? Duration.zero : t.duration;
  }

  void _scheduleTrack(NavLayout layout, Size size) {
    _frameLayout = layout;
    _frameSize = size;
    if (_trackScheduled) return;
    _trackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackScheduled = false;
      if (!mounted) return;
      _track(_frameLayout!, _frameSize);
    });
  }

  void _track(NavLayout layout, Size size) {
    _lastSeen = layout;
    _lastSize = size;
    final reported = _lastReported;
    if (widget.onLayoutChanged == null || reported == null) {
      _lastReported = layout;
      _settleTimer?.cancel();
      _pending = null;
      return;
    }
    if (_sameKey(reported, layout)) {
      _pending = null;
      _settleTimer?.cancel();
      return;
    }
    if (_pending == null || !_sameKey(_pending!, layout)) {
      _settleTimer?.cancel();
      _settleTimer = Timer(kLayoutSettleDelay, _fireLayoutChanged);
    }
    _pending = layout;
  }

  void _fireLayoutChanged() {
    final next = _lastSeen;
    final previous = _lastReported;
    _pending = null;
    if (next == null || previous == null || _sameKey(previous, next)) return;
    _lastReported = next;
    widget.onLayoutChanged?.call(previous, next);
  }

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
      textScale: media.textScaler.scale(1),
    );
    final layout = NavLayout(
      placement: placement,
      geometry: geometry,
      destinations: widget.destinations,
      selectedIndex: widget.selectedIndex,
      onSelected: widget.onSelected,
      posture: signals.posture,
    );
    final duration = _transitionFor(
      layout,
      signals.viewSize,
      media.disableAnimations,
    );
    _scheduleTrack(layout, signals.viewSize);

    final bar =
        widget.barBuilder?.call(context, layout) ??
        (_isApple
            ? cupertinoBarBuilder(context, layout)
            : materialBarBuilder(context, layout));
    final inset = _bodyInsets(geometry, signals.viewSize);
    final extend =
        widget.extendBodyBehindBar &&
        placement.isVertical &&
        geometry.foldClearance == 0;

    return FoldDebugOverlay(
      enabled: widget.debugOverlay,
      ruleLabel: placement.ruleId.isEmpty ? null : placement.ruleId,
      child: Stack(
        textDirection: direction,
        children: [
          Positioned.fill(
            child: Padding(
              padding: extend ? EdgeInsets.zero : inset,
              child: MediaQuery(
                data: _bodyMedia(media, inset, extend),
                child: KeyedSubtree(key: _bodyKey, child: widget.body),
              ),
            ),
          ),
          Positioned.fromRect(
            rect: geometry.barRect,
            child: AnimatedSwitcher(
              duration: duration,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, ?current],
              ),
              child: KeyedSubtree(
                key: ValueKey<NavEdge>(placement.edge),
                child: bar,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Body media: the bar extent is removed from padding when the body is
  /// inset, or added to it when the body runs under the bar. The bottom
  /// keyboard inset is reduced by the bar height the body already clears.
  MediaQueryData _bodyMedia(
    MediaQueryData media,
    EdgeInsets inset,
    bool extend,
  ) {
    EdgeInsets adjust(EdgeInsets p) => extend
        ? EdgeInsets.fromLTRB(
            math.max(p.left, inset.left),
            p.top,
            math.max(p.right, inset.right),
            math.max(p.bottom, inset.bottom),
          )
        : EdgeInsets.fromLTRB(
            inset.left > 0 ? 0 : p.left,
            p.top,
            inset.right > 0 ? 0 : p.right,
            inset.bottom > 0 ? 0 : p.bottom,
          );
    final insets = media.viewInsets;
    return media.copyWith(
      padding: adjust(media.padding),
      viewPadding: adjust(media.viewPadding),
      viewInsets: EdgeInsets.fromLTRB(
        insets.left,
        insets.top,
        insets.right,
        extend ? insets.bottom : math.max(0, insets.bottom - inset.bottom),
      ),
    );
  }

  /// Padding that keeps the body clear of the bar, derived from where the bar sits.
  EdgeInsets _bodyInsets(NavGeometry geometry, Size size) {
    final r = geometry.barRect;
    if (r.isEmpty) return EdgeInsets.zero;
    if (geometry.itemAxis == NavAxis.horizontal) {
      return EdgeInsets.only(
        bottom: (size.height - r.top).clamp(0, size.height),
      );
    }
    if (r.center.dx < size.width / 2) {
      return EdgeInsets.only(left: r.right.clamp(0, size.width));
    }
    return EdgeInsets.only(right: (size.width - r.left).clamp(0, size.width));
  }
}
