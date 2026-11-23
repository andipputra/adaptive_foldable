import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Material 3 style navigation rail drawn through `barBuilder`.
///
/// The prominent action sits at the rail's top, like a FAB slot. Other actions
/// are left out of the rail on purpose: the app draws them with
/// `MaterialNavBar.headerStrip` from `NavLayout.headerActions` (filled from M2).
class MaterialRail extends StatelessWidget {
  /// Creates a rail for [layout].
  const MaterialRail({super.key, required this.layout, required this.colors});

  /// The resolved layout.
  final NavLayout layout;

  /// Colours to apply.
  final NavBarColors colors;

  @override
  Widget build(BuildContext context) {
    final railLayout = layout.copyWith(visibleActions: const []);
    final style = layout.barStyle;
    final items = buildNavBarItems(railLayout, colors, tabsExpand: false);
    return ColoredBox(
      color: colors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: paddingFor(style, const EdgeInsets.only(top: 8)),
          child: Column(
            mainAxisAlignment: mainAxisFor(style.alignment),
            children: spaceItems(
              [
                for (final item in items)
                  Padding(
                    padding: style.itemSpacing == null
                        ? const EdgeInsets.symmetric(vertical: 4)
                        : EdgeInsets.zero,
                    child: item,
                  ),
              ],
              style.itemSpacing,
              Axis.vertical,
            ),
          ),
        ),
      ),
    );
  }
}
