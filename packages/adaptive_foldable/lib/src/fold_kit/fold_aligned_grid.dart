import 'dart:math' as math;

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/widgets.dart';

/// A responsive grid that mirrors columns around an active vertical fold
/// so that no tile sits in the hinge/crease.
///
/// When an active vertical fold is detected (e.g. book pose), divides the
/// columns evenly across the two panes separated by the fold rectangle.
/// When flat or without an active fold, renders as a standard responsive grid.
class FoldAlignedGrid extends StatelessWidget {
  /// Creates a fold-aligned grid.
  const FoldAlignedGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCountPerPane = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.physics,
  });

  /// The total number of items in the grid.
  final int itemCount;

  /// Called to build each item by index.
  final NullableIndexedWidgetBuilder itemBuilder;

  /// The number of columns per pane when split across a fold.
  final int crossAxisCountPerPane;

  /// The spacing between rows along the main axis.
  final double mainAxisSpacing;

  /// The spacing between tiles along the cross axis within each pane.
  final double crossAxisSpacing;

  /// The aspect ratio (width / height) of each grid tile.
  final double childAspectRatio;

  /// Padding around the overall grid content.
  final EdgeInsetsGeometry padding;

  /// Optional controller for the grid scroll view.
  final ScrollController? controller;

  /// Scroll physics for the grid scroll view.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);
    final activeFolds = signals.activeFolds;
    final verticalFolds = activeFolds
        .where((Rect r) => r.height > r.width)
        .toList();

    if (verticalFolds.isEmpty) {
      return GridView.builder(
        controller: controller,
        physics: physics,
        padding: padding,
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCountPerPane * 2,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: itemBuilder,
      );
    }

    final fold = verticalFolds.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final resolvedPadding = padding.resolve(Directionality.of(context));

        final leftWidth = fold.left.clamp(0.0, totalWidth);
        final creaseWidth = (fold.right - fold.left).clamp(0.0, totalWidth);
        final rightWidth = (totalWidth - fold.right).clamp(0.0, totalWidth);

        final itemsPerRow = crossAxisCountPerPane * 2;
        final rowCount = (itemCount + itemsPerRow - 1) ~/ itemsPerRow;

        return ListView.builder(
          controller: controller,
          physics: physics,
          padding: resolvedPadding,
          itemCount: rowCount,
          itemBuilder: (context, rowIndex) {
            final rowStartIndex = rowIndex * itemsPerRow;
            final isLastRow = rowIndex == rowCount - 1;

            return Padding(
              padding: EdgeInsets.only(
                bottom: isLastRow ? 0.0 : mainAxisSpacing,
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane
                  SizedBox(
                    width: leftWidth,
                    child: _buildPaneRow(
                      context,
                      startIndex: rowStartIndex,
                      count: crossAxisCountPerPane,
                      paneWidth: leftWidth,
                    ),
                  ),

                  // Crease / Fold Gap (Zero content)
                  SizedBox(width: creaseWidth),

                  // Right Pane
                  SizedBox(
                    width: rightWidth,
                    child: _buildPaneRow(
                      context,
                      startIndex: rowStartIndex + crossAxisCountPerPane,
                      count: crossAxisCountPerPane,
                      paneWidth: rightWidth,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaneRow(
    BuildContext context, {
    required int startIndex,
    required int count,
    required double paneWidth,
  }) {
    if (paneWidth <= 0) return const SizedBox();

    final totalSpacing = (count - 1) * crossAxisSpacing;
    final tileWidth = math.max(0.0, (paneWidth - totalSpacing) / count);
    final tileHeight = childAspectRatio > 0
        ? tileWidth / childAspectRatio
        : tileWidth;

    final tiles = <Widget>[];
    for (int i = 0; i < count; i++) {
      final index = startIndex + i;
      if (index < itemCount) {
        final child = itemBuilder(context, index) ?? const SizedBox();
        tiles.add(SizedBox(width: tileWidth, height: tileHeight, child: child));
      } else {
        tiles.add(SizedBox(width: tileWidth, height: tileHeight));
      }
      if (i < count - 1) {
        tiles.add(SizedBox(width: crossAxisSpacing));
      }
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: tiles);
  }
}
