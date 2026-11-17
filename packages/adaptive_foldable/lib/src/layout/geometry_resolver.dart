import 'dart:math' as math;
import 'dart:ui' show Rect, TextDirection;

import 'package:adaptive_foldable/src/model/nav_axis.dart';
import 'package:adaptive_foldable/src/model/nav_geometry.dart';
import 'package:adaptive_foldable/src/model/nav_insets.dart';
import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Thickness in dp of a bottom bar, excluding the home-indicator inset.
///
/// Initial value; revisited against the simulator in ANS-M1-013.
const double kBottomBarThickness = 56;

/// Thickness in dp of a side rail or column, excluding any side inset.
///
/// Initial value; revisited against the simulator in ANS-M1-013.
const double kSideBarThickness = 80;

/// Space in dp kept between the bar and an active fold it was cut away from.
const double kFoldClearance = 4;

/// Resolves where the bar sits for [placement].
///
/// All rectangles are in view coordinates: logical pixels, origin at the top
/// left of the Flutter view. [viewPadding] is the system inset (status bar,
/// home indicator, rounded corners).
///
/// - Bottom bar: spans the view width, [kBottomBarThickness] plus the bottom
///   inset tall; [NavGeometry.homeIndicatorGap] is that inset.
/// - Side column: [kSideBarThickness] plus the inset on its side, starting
///   below the status and camera region ([NavGeometry.skipRegion]) and ending
///   above the home-indicator gap.
/// - Logical edges resolve through [direction]; physical edges do not flip.
/// - The result never intersects an active fold: the bar is cut to its largest
///   remaining piece, [kFoldClearance] away from the fold, and
///   [NavGeometry.foldClearance] reports that distance (0 when no cut was needed).
NavGeometry resolveGeometry({
  required NavPlacement placement,
  required FoldSignals signals,
  NavInsets viewPadding = NavInsets.zero,
  TextDirection direction = TextDirection.ltr,
}) {
  final size = signals.viewSize;
  final gap = viewPadding.bottom;
  final isVertical = placement.isVertical;

  late Rect bar;
  Rect? skip;
  if (!isVertical) {
    bar = Rect.fromLTRB(
      0,
      math.max(0, size.height - kBottomBarThickness - gap),
      size.width,
      size.height,
    );
  } else {
    final onLeft = _isLeft(placement.edge, direction);
    final skipBottom = _skipBottom(signals, viewPadding, onLeft, size.width);
    final top = math.min(skipBottom, size.height);
    final bottom = math.max(top, size.height - gap);
    bar = onLeft
        ? Rect.fromLTRB(0, top, kSideBarThickness + viewPadding.left, bottom)
        : Rect.fromLTRB(
            size.width - kSideBarThickness - viewPadding.right,
            top,
            size.width,
            bottom,
          );
    if (top > 0) {
      skip = Rect.fromLTRB(bar.left, 0, bar.right, top);
    }
  }

  var cutAway = false;
  for (final fold in signals.activeFolds) {
    final keepOut = fold.inflate(kFoldClearance);
    if (bar.overlaps(keepOut)) {
      bar = _largestPieceOutside(bar, keepOut);
      cutAway = true;
    }
  }

  return NavGeometry(
    barRect: bar,
    skipRegion: skip,
    itemAxis: isVertical ? NavAxis.vertical : NavAxis.horizontal,
    homeIndicatorGap: gap,
    foldClearance: cutAway ? kFoldClearance : 0,
  );
}

bool _isLeft(NavEdge edge, TextDirection direction) => switch (edge) {
  NavEdge.left => true,
  NavEdge.right => false,
  NavEdge.leading => direction == TextDirection.ltr,
  NavEdge.trailing => direction == TextDirection.rtl,
  NavEdge.bottom => false,
};

/// Bottom of the status and camera region that a side column must start below.
double _skipBottom(
  FoldSignals signals,
  NavInsets padding,
  bool onLeft,
  double width,
) {
  var bottom = padding.top;
  final columnWidth =
      kSideBarThickness + (onLeft ? padding.left : padding.right);
  final column = onLeft
      ? Rect.fromLTWH(0, 0, columnWidth, double.infinity)
      : Rect.fromLTWH(width - columnWidth, 0, columnWidth, double.infinity);
  for (final o in signals.occlusions) {
    final overlapsColumn = o.left < column.right && o.right > column.left;
    if (overlapsColumn) bottom = math.max(bottom, o.bottom);
  }
  return bottom;
}

/// Returns the largest-area part of [bar] that does not overlap [keepOut].
Rect _largestPieceOutside(Rect bar, Rect keepOut) {
  final pieces = <Rect>[
    if (keepOut.left > bar.left)
      Rect.fromLTRB(bar.left, bar.top, keepOut.left, bar.bottom),
    if (keepOut.right < bar.right)
      Rect.fromLTRB(keepOut.right, bar.top, bar.right, bar.bottom),
    if (keepOut.top > bar.top)
      Rect.fromLTRB(bar.left, bar.top, bar.right, keepOut.top),
    if (keepOut.bottom < bar.bottom)
      Rect.fromLTRB(bar.left, keepOut.bottom, bar.right, bar.bottom),
  ];
  if (pieces.isEmpty) {
    return Rect.fromLTWH(bar.left, bar.top, 0, 0);
  }
  return pieces.reduce(
    (a, b) => a.width * a.height >= b.width * b.height ? a : b,
  );
}
