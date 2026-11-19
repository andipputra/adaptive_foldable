import 'dart:ui' show Rect;

/// Pure computation result for two-pane spatial dimensions.
class TwoPaneDimensions {
  /// Creates dimensions.
  const TwoPaneDimensions({
    required this.startRect,
    required this.endRect,
    required this.isSplit,
  });

  /// Rectangle for the start pane in local coordinates.
  final Rect startRect;

  /// Rectangle for the end pane in local coordinates.
  final Rect endRect;

  /// Whether both panes are visible side by side.
  final bool isSplit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwoPaneDimensions &&
          runtimeType == other.runtimeType &&
          startRect == other.startRect &&
          endRect == other.endRect &&
          isSplit == other.isSplit;

  @override
  int get hashCode => Object.hash(startRect, endRect, isSplit);
}

/// Resolves the layout rectangles for a two-pane container.
///
/// If an active vertical fold is present, splits along the fold crease avoiding it.
/// If no active vertical fold, splits by proportion when width >= minStart + minEnd.
/// Otherwise, falls back to a single pane based on priority.
TwoPaneDimensions resolveTwoPaneDimensions({
  required double totalWidth,
  required double totalHeight,
  required List<Rect> activeFolds,
  required double startPaneProportion,
  required double minStartPaneWidth,
  required double minEndPaneWidth,
  required double spacing,
  required bool showBoth,
  required bool showStart,
}) {
  if (totalWidth <= 0 || totalHeight <= 0) {
    return const TwoPaneDimensions(
      startRect: Rect.zero,
      endRect: Rect.zero,
      isSplit: false,
    );
  }

  // Check for vertical folds (height > width)
  final verticalFolds = activeFolds.where((r) => r.height > r.width).toList();

  if (verticalFolds.isNotEmpty && showBoth) {
    final fold = verticalFolds.first;
    // Fold splits horizontally: start pane is to the left of fold.left, end pane to the right of fold.right
    final startW = fold.left.clamp(0.0, totalWidth);
    final endLeft = fold.right.clamp(0.0, totalWidth);
    final endW = (totalWidth - endLeft).clamp(0.0, totalWidth);

    return TwoPaneDimensions(
      startRect: Rect.fromLTWH(0, 0, startW, totalHeight),
      endRect: Rect.fromLTWH(endLeft, 0, endW, totalHeight),
      isSplit: true,
    );
  }

  final canSplitWithoutFold =
      showBoth && totalWidth >= (minStartPaneWidth + minEndPaneWidth + spacing);

  if (canSplitWithoutFold) {
    final available = (totalWidth - spacing).clamp(0.0, totalWidth);
    double startW = available * startPaneProportion;
    if (startW < minStartPaneWidth) {
      startW = minStartPaneWidth;
    } else if (available - startW < minEndPaneWidth) {
      startW = available - minEndPaneWidth;
    }
    final endW = (available - startW).clamp(0.0, available);
    final endLeft = startW + spacing;

    return TwoPaneDimensions(
      startRect: Rect.fromLTWH(0, 0, startW, totalHeight),
      endRect: Rect.fromLTWH(endLeft, 0, endW, totalHeight),
      isSplit: true,
    );
  }

  // Single pane presentation
  if (showStart) {
    return TwoPaneDimensions(
      startRect: Rect.fromLTWH(0, 0, totalWidth, totalHeight),
      endRect: Rect.zero,
      isSplit: false,
    );
  } else {
    return TwoPaneDimensions(
      startRect: Rect.zero,
      endRect: Rect.fromLTWH(0, 0, totalWidth, totalHeight),
      isSplit: false,
    );
  }
}
