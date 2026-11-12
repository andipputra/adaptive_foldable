import 'dart:ui';

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Aspect ratio threshold for detecting a short, wide cover display in landscape.
///
/// Default is 1.4; refined based on measured iPhone Duo cover landscape (678 x 466, aspect ~1.455) on the iPhone Duo simulator.
const double kCoverAspect = 1.4;

/// Computes the fallback navigation bar edge when [FoldSignals.verticalBarEdge] is unavailable.
///
/// Implements the fallback rules:
/// 1. Regular width and taller than wide -> [NavEdge.bottom].
/// 2. Compact width with a short, wide aspect (`width / height >= kCoverAspect`) ->
///    side edge opposite the outer camera occlusion if reported, else physical [NavEdge.right].
/// 3. Regular x regular size classes and wider than tall -> physical [NavEdge.right].
/// 4. Otherwise -> [NavEdge.bottom].
///
/// Note: On iOS, the column never flips in right-to-left layout. Therefore,
/// side column placements return physical edges ([NavEdge.left] or [NavEdge.right])
/// regardless of [direction].
NavEdge fallbackBarEdge(FoldSignals signals, TextDirection direction) {
  final width = signals.viewSize.width;
  final height = signals.viewSize.height;

  // Zero or invalid size guard.
  if (width <= 0 || height <= 0) {
    return NavEdge.bottom;
  }

  final isTallerThanWide = height > width;
  final isWiderThanTall = width > height;

  // Rule 1: Regular width and taller than wide -> bottom bar.
  if (signals.horizontalSizeClass == SizeClass.regular && isTallerThanWide) {
    return NavEdge.bottom;
  }

  // Rule 2: Compact width with short wide aspect -> side column.
  final isCompactWidth = signals.horizontalSizeClass == SizeClass.compact;
  final isShortWideAspect = (width / height) >= kCoverAspect;
  if (isCompactWidth && isShortWideAspect) {
    if (signals.occlusions.isNotEmpty) {
      // Find horizontal center of outer camera occlusion
      final occlusion = signals.occlusions.first;
      final occlusionCenterX = occlusion.left + (occlusion.width / 2);
      final viewCenterX = width / 2;

      // Place bar on edge opposite the camera
      if (occlusionCenterX < viewCenterX) {
        return NavEdge.right;
      } else {
        return NavEdge.left;
      }
    }
    return NavEdge.right;
  }

  // Rule 3: Regular x regular and wider than tall -> vertical trailing (physical right).
  if (signals.horizontalSizeClass == SizeClass.regular &&
      signals.verticalSizeClass == SizeClass.regular &&
      isWiderThanTall) {
    return NavEdge.right;
  }

  // Rule 4: Otherwise -> bottom bar.
  return NavEdge.bottom;
}
