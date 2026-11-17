import 'package:adaptive_foldable/src/bars/material/material_bottom_bar.dart';
import 'package:adaptive_foldable/src/bars/material/material_header_strip.dart';
import 'package:adaptive_foldable/src/bars/material/material_rail.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Material reference bar: bottom bar on the bottom edge, rail on a side edge.
///
/// Built only on the public `barBuilder` contract and on `package:flutter/widgets.dart`.
/// Colours follow the platform brightness unless [colors] is given.
class MaterialNavBar extends StatelessWidget {
  /// Creates the bar for [layout].
  const MaterialNavBar({super.key, required this.layout, this.colors});

  /// The resolved layout.
  final NavLayout layout;

  /// Colours to use instead of the brightness-based defaults.
  final NavBarColors? colors;

  @override
  Widget build(BuildContext context) {
    final resolved = colors ?? defaultColors(context);
    return layout.placement.isVertical
        ? MaterialRail(layout: layout, colors: resolved)
        : MaterialBottomBar(layout: layout, colors: resolved);
  }

  /// Header strip for `layout.headerActions`, placed by the app at the top of its page.
  static Widget headerStrip(
    BuildContext context,
    NavLayout layout, {
    NavBarColors? colors,
  }) => MaterialHeaderStrip(
    layout: layout,
    colors: colors ?? defaultColors(context),
  );

  /// Material 3 baseline neutrals for the platform brightness of [context].
  static NavBarColors defaultColors(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? const NavBarColors(
          background: Color(0xFF211F26),
          active: Color(0xFFE8DEF8),
          inactive: Color(0xFFCAC4D0),
          indicator: Color(0xFF4A4458),
        )
      : const NavBarColors(
          background: Color(0xFFF3EDF7),
          active: Color(0xFF1D192B),
          inactive: Color(0xFF49454F),
          indicator: Color(0xFFE8DEF8),
        );
}

/// `barBuilder` that draws [MaterialNavBar].
Widget materialBarBuilder(BuildContext context, NavLayout layout) =>
    MaterialNavBar(layout: layout);
