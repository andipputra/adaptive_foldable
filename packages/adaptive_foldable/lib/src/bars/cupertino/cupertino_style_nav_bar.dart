import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Cupertino-style reference bar, built on `package:flutter/widgets.dart` only: bottom tab bar, or a side column on a side edge.
///
/// Column order top to bottom: Back, prominent action, action groups, tabs; the
/// geometry already starts below the camera and status region. Side edges are
/// physical, so the column never flips in right-to-left layout.
class CupertinoStyleNavBar extends StatelessWidget {
  /// Creates the bar for [layout].
  const CupertinoStyleNavBar({super.key, required this.layout, this.colors});

  /// The resolved layout.
  final NavLayout layout;

  /// Colours to use instead of the brightness-based defaults.
  final NavBarColors? colors;

  @override
  Widget build(BuildContext context) =>
      navBarTraversalGroup(child: _build(context));

  Widget _build(BuildContext context) {
    final colors = this.colors ?? defaultColors(context);
    final items = buildNavBarItems(
      layout,
      colors,
      tabsExpand: !layout.placement.isVertical,
    );
    final border = colors.border ?? const Color(0x00000000);
    if (layout.placement.isVertical) {
      final onLeft = layout.placement.isOnLeft(Directionality.of(context));
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

  /// iOS system colours for the platform brightness of [context].
  static NavBarColors defaultColors(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? const NavBarColors(
          background: Color(0xF01C1C1E),
          active: Color(0xFF0A84FF),
          inactive: Color(0xFF98989D),
          border: Color(0x99545458),
        )
      : const NavBarColors(
          background: Color(0xF0F9F9F9),
          active: Color(0xFF007AFF),
          inactive: Color(0xFF636366),
          border: Color(0x4D3C3C43),
        );
}

/// `barBuilder` that draws [CupertinoStyleNavBar].
Widget cupertinoBarBuilder(BuildContext context, NavLayout layout) =>
    CupertinoStyleNavBar(layout: layout);
