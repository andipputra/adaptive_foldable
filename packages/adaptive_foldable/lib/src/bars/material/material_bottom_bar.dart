import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Material 3 style bottom bar drawn through `barBuilder`.
class MaterialBottomBar extends StatelessWidget {
  /// Creates a bottom bar for [layout].
  const MaterialBottomBar({
    super.key,
    required this.layout,
    required this.colors,
  });

  /// The resolved layout.
  final NavLayout layout;

  /// Colours to apply.
  final NavBarColors colors;

  @override
  Widget build(BuildContext context) {
    final style = layout.barStyle;
    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: EdgeInsets.only(bottom: layout.geometry.homeIndicatorGap),
        child: Padding(
          padding: paddingFor(style, EdgeInsets.zero),
          child: Row(
            mainAxisAlignment: mainAxisFor(style.alignment),
            children: spaceItems(
              buildNavBarItems(
                layout,
                colors,
                tabsExpand: style.alignment == null,
              ),
              style.itemSpacing,
              Axis.horizontal,
            ),
          ),
        ),
      ),
    );
  }
}
