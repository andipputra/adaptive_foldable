import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Horizontal strip of the actions that stay out of the rail (Android), in `headerActions`.
class MaterialHeaderStrip extends StatelessWidget {
  /// Creates a header strip for [layout]; draws nothing when there are no header actions.
  const MaterialHeaderStrip({
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
    final actions = [for (final g in layout.headerActions) ...g.actions];
    if (actions.isEmpty) return const SizedBox.shrink();
    return ColoredBox(
      color: colors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (final a in actions)
            NavBarItem(
              icon: a.icon,
              label: a.label,
              selected: a.selected,
              isSelectable: false,
              enabled: a.enabled,
              onTap: a.onPressed,
              badgeCount: a.badgeCount,
              activeColor: colors.active,
              inactiveColor: colors.inactive,
            ),
        ],
      ),
    );
  }
}
