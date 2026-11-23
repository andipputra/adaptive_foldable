import 'dart:math' as math;
import 'dart:ui' show Rect, Size, TextDirection;

import 'package:adaptive_foldable/src/model/nav_axis.dart';
import 'package:adaptive_foldable/src/model/nav_geometry.dart';
import 'package:adaptive_foldable/src/model/nav_insets.dart';
import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';

/// Thickness in dp of a bottom bar, excluding the home-indicator inset.
///
/// Initial value; revisited against the simulator in ANS-M1-013.
const double kBottomBarThickness = 56;

/// Extra bottom-bar height in dp per 1.0 of text scale above 1.0, so labels stay inside the bar.
const double kBottomBarThicknessPerTextScale = 17;

/// Thickness in dp of a side rail or column, excluding any side inset.
///
/// Initial value; revisited against the simulator in ANS-M1-013.
const double kSideBarThickness = 0;

/// Extra side-column width in dp per 1.0 of text scale above 1.0, so scaled labels fit.
const double kSideBarThicknessPerTextScale = 24;

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
///   below a status or camera region at the top ([NavGeometry.skipRegion]) and
///   ending above a camera region at the bottom or the home-indicator gap.
/// - Logical edges resolve through [direction]; physical edges do not flip.
/// - [sideThickness] overrides [kSideBarThickness] for the side column.
/// - [textScale] grows the bottom bar and the side column so scaled labels fit.
/// - The result never intersects an active fold: the bar is cut to its largest
///   remaining piece, [kFoldClearance] away from the fold, and
///   [NavGeometry.foldClearance] reports that distance (0 when no cut was needed).
NavGeometry resolveGeometry({
  required NavPlacement placement,
  required FoldSignals signals,
  NavInsets viewPadding = NavInsets.zero,
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double sideThickness = kSideBarThickness,
}) {
  final size = signals.viewSize;
  final gap = viewPadding.bottom;
  final isVertical = placement.isVertical;

  late Rect bar;
  var skipBottom = 0.0;
  final scaledSide =
      sideThickness +
      kSideBarThicknessPerTextScale * (math.max(1, textScale) - 1);
  if (!isVertical) {
    final thickness =
        kBottomBarThickness +
        kBottomBarThicknessPerTextScale * (math.max(1, textScale) - 1);
    bar = Rect.fromLTRB(
      math.min(viewPadding.left, size.width),
      math.max(0, size.height - thickness - gap),
      math.max(0, size.width - viewPadding.right),
      size.height,
    );
  } else {
    final onLeft = placement.isOnLeft(direction);
    final side = scaledSide;
    final span = _freeSpan(signals, viewPadding, onLeft, size, side);
    final top = span.$1;
    skipBottom = top;
    final bottom = math.max(top, math.min(span.$2, size.height - gap));
    bar = onLeft
        ? Rect.fromLTRB(0, top, side + viewPadding.left, bottom)
        : Rect.fromLTRB(
            size.width - side - viewPadding.right,
            top,
            size.width,
            bottom,
          );
  }

  var pieces = <Rect>[bar];
  var cutAway = false;
  for (final fold in signals.activeFolds) {
    final keepOut = fold.inflate(kFoldClearance);
    final next = <Rect>[];
    for (final piece in pieces) {
      if (piece.overlaps(keepOut)) {
        cutAway = true;
        next.addAll(_piecesOutside(piece, keepOut));
      } else {
        next.add(piece);
      }
    }
    pieces = next;
  }
  if (cutAway) {
    bar = pieces.isEmpty
        ? Rect.fromLTWH(bar.left, bar.top, 0, 0)
        : pieces.reduce(
            (a, b) => a.width * a.height >= b.width * b.height ? a : b,
          );
  }

  final skip = isVertical && skipBottom > 0 && !bar.isEmpty
      ? Rect.fromLTRB(bar.left, 0, bar.right, skipBottom)
      : null;

  return NavGeometry(
    barRect: bar,
    skipRegion: skip,
    itemAxis: isVertical ? NavAxis.vertical : NavAxis.horizontal,
    homeIndicatorGap: gap,
    foldClearance: cutAway ? kFoldClearance : 0,
  );
}

/// Vertical span `(top, bottom)` of the side column left free by the status
/// bar and by camera occlusions that overlap the column.
///
/// An occlusion in the upper half pushes the top down; one in the lower half
/// (camera at the bottom in landscape) pulls the bottom up.
(double, double) _freeSpan(
  FoldSignals signals,
  NavInsets padding,
  bool onLeft,
  Size size,
  double side,
) {
  var top = padding.top;
  var bottom = size.height;
  final columnWidth = side + (onLeft ? padding.left : padding.right);
  final left = onLeft ? 0.0 : size.width - columnWidth;
  final right = left + columnWidth;
  for (final o in signals.occlusions) {
    if (o.left >= right || o.right <= left) continue;
    if (o.center.dy < size.height / 2) {
      top = math.max(top, o.bottom);
    } else {
      bottom = math.min(bottom, o.top);
    }
  }
  return (math.min(top, size.height), bottom);
}

/// Returns the parts of [bar] that do not overlap [keepOut].
List<Rect> _piecesOutside(Rect bar, Rect keepOut) => [
  if (keepOut.left > bar.left)
    Rect.fromLTRB(bar.left, bar.top, keepOut.left, bar.bottom),
  if (keepOut.right < bar.right)
    Rect.fromLTRB(keepOut.right, bar.top, bar.right, bar.bottom),
  if (keepOut.top > bar.top)
    Rect.fromLTRB(bar.left, bar.top, bar.right, keepOut.top),
  if (keepOut.bottom < bar.bottom)
    Rect.fromLTRB(bar.left, keepOut.bottom, bar.right, bar.bottom),
];
