import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/cupertino.dart';

/// Cupertino-style reference bar: bottom tab bar, or a side column on a side edge.
///
/// Column order top to bottom: Back, prominent action, action groups, tabs; the
/// geometry already starts below the camera and status region. Side edges are
/// physical, so the column never flips in right-to-left layout.
class CupertinoStyleNavBar extends StatelessWidget {
  /// Creates the bar for [layout].
  const CupertinoStyleNavBar({super.key, required this.layout});

  /// The resolved layout.
  final NavLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = NavBarColors(
      background: CupertinoDynamicColor.resolve(
        CupertinoColors.systemBackground,
        context,
      ).withValues(alpha: 0.94),
      active: CupertinoTheme.of(context).primaryColor,
      inactive: CupertinoDynamicColor.resolve(
        CupertinoColors.inactiveGray,
        context,
      ),
    );
    final items = buildNavBarItems(
      layout,
      colors,
      tabsExpand: !layout.placement.isVertical,
    );
    final border = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    if (layout.placement.isVertical) {
      final onLeft = layout.placement.edge == NavEdge.left;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            left: onLeft
                ? BorderSide.none
                : BorderSide(color: border, width: 0.5),
            right: onLeft
                ? BorderSide(color: border, width: 0.5)
                : BorderSide.none,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: item,
                ),
            ],
          ),
        ),
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: border, width: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: layout.geometry.homeIndicatorGap),
        child: Row(children: items),
      ),
    );
  }
}

/// `barBuilder` that draws [CupertinoStyleNavBar].
Widget cupertinoBarBuilder(BuildContext context, NavLayout layout) =>
    CupertinoStyleNavBar(layout: layout);
