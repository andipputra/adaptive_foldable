import 'package:adaptive_foldable/src/layout/two_pane_layout.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/widgets.dart';

/// Which pane is given priority when available width cannot display both panes.
enum TwoPanePriority {
  /// Displays the start pane when in single-pane mode.
  start,

  /// Displays the end pane when in single-pane mode.
  end,

  /// Attempts to display both panes whenever possible.
  both,
}

/// A responsive two-pane layout that splits along an active vertical fold
/// or by proportion on regular widths.
///
/// Falls back to displaying a single pane at compact widths according to [priority].
/// Preserves the state (scroll offsets, text fields, navigators) of both panes
/// using a non-reparenting [Stack] and [Offstage] so no state is lost across
/// layout switching or folding/unfolding.
class FoldAwareTwoPane extends StatefulWidget {
  /// Creates a two-pane container.
  const FoldAwareTwoPane({
    super.key,
    required this.start,
    required this.end,
    this.priority = TwoPanePriority.both,
    this.startPaneProportion = 0.4,
    this.minStartPaneWidth = 280.0,
    this.minEndPaneWidth = 320.0,
    this.spacing = 0.0,
  });

  /// The leading / primary / list pane widget.
  final Widget start;

  /// The trailing / secondary / detail pane widget.
  final Widget end;

  /// Priority determining which pane to show when collapsed to a single pane.
  final TwoPanePriority priority;

  /// The fraction of available width allocated to [start] when split without a fold.
  final double startPaneProportion;

  /// The minimum width required for the [start] pane.
  final double minStartPaneWidth;

  /// The minimum width required for the [end] pane.
  final double minEndPaneWidth;

  /// Spacing between the two panes when split without an active fold.
  final double spacing;

  @override
  State<FoldAwareTwoPane> createState() => _FoldAwareTwoPaneState();
}

class _FoldAwareTwoPaneState extends State<FoldAwareTwoPane> {
  final GlobalKey _startKey = GlobalKey(debugLabel: 'FoldAwareTwoPane.start');
  final GlobalKey _endKey = GlobalKey(debugLabel: 'FoldAwareTwoPane.end');

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);
    final direction = Directionality.of(context);
    final isRtl = direction == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final totalH = constraints.maxHeight;

        final showBoth = widget.priority == TwoPanePriority.both;
        final showStart = widget.priority != TwoPanePriority.end;

        final dims = resolveTwoPaneDimensions(
          totalWidth: totalW,
          totalHeight: totalH,
          activeFolds: signals.activeFolds,
          startPaneProportion: widget.startPaneProportion,
          minStartPaneWidth: widget.minStartPaneWidth,
          minEndPaneWidth: widget.minEndPaneWidth,
          spacing: widget.spacing,
          showBoth: showBoth,
          showStart: showStart,
        );

        final isSplit = dims.isSplit;
        final startVisible = isSplit || showStart;
        final endVisible = isSplit || !showStart;

        // Position coordinates considering text direction
        final double startLeft = isRtl
            ? (totalW - dims.startRect.right)
            : dims.startRect.left;
        final double endLeft = isRtl
            ? (totalW - dims.endRect.right)
            : dims.endRect.left;

        return Stack(
          fit: StackFit.expand,
          children: [
            // Start Pane
            Positioned(
              key: _startKey,
              left: startVisible ? startLeft : 0,
              top: 0,
              width: startVisible ? dims.startRect.width : totalW,
              height: totalH,
              child: Offstage(
                offstage: !startVisible,
                child: TickerMode(
                  enabled: startVisible,
                  child: NavPaneScope(
                    paneId: NavPaneScope.startPane,
                    isPrimary: true,
                    child: widget.start,
                  ),
                ),
              ),
            ),

            // End Pane
            Positioned(
              key: _endKey,
              left: endVisible ? endLeft : 0,
              top: 0,
              width: endVisible ? dims.endRect.width : totalW,
              height: totalH,
              child: Offstage(
                offstage: !endVisible,
                child: TickerMode(
                  enabled: endVisible,
                  child: NavPaneScope(
                    paneId: NavPaneScope.endPane,
                    isPrimary: false,
                    child: widget.end,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
