import 'package:adaptive_foldable/src/bars/material/material_bottom_bar.dart';
import 'package:adaptive_foldable/src/bars/material/material_header_strip.dart';
import 'package:adaptive_foldable/src/bars/material/material_rail.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/material.dart' show ColorScheme, Theme;
import 'package:flutter/widgets.dart';

/// Material reference bar: bottom bar on the bottom edge, rail on a side edge.
///
/// Built only on the public `barBuilder` contract. Header actions, when any,
/// are drawn in a strip along the top of the screen.
class MaterialNavBar extends StatelessWidget {
  /// Creates the bar for [layout].
  const MaterialNavBar({super.key, required this.layout});

  /// The resolved layout.
  final NavLayout layout;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = _colorsFor(scheme);
    return layout.placement.isVertical
        ? MaterialRail(layout: layout, colors: colors)
        : MaterialBottomBar(layout: layout, colors: colors);
  }

  /// Header strip for `layout.headerActions`, to be placed by the app at the top of its page.
  static Widget headerStrip(BuildContext context, NavLayout layout) =>
      MaterialHeaderStrip(
        layout: layout,
        colors: _colorsFor(Theme.of(context).colorScheme),
      );

  static NavBarColors _colorsFor(ColorScheme s) => NavBarColors(
    background: s.surfaceContainer,
    active: s.onSecondaryContainer,
    inactive: s.onSurfaceVariant,
    indicator: s.secondaryContainer,
  );
}

/// `barBuilder` that draws [MaterialNavBar].
Widget materialBarBuilder(BuildContext context, NavLayout layout) =>
    MaterialNavBar(layout: layout);
