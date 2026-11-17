import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:flutter/widgets.dart';

/// Horizontal strip of the actions that stay out of the rail (Android), in `headerActions`.
///
/// Fades with `layout.actionsOpacity`, ignores taps while mostly faded, shows
/// the overflow control when `layout.onOverflow` is set, and keeps semantics
/// and focus in reading order. Draws nothing when there is nothing to show.
class MaterialHeaderStrip extends StatelessWidget {
  /// Creates a header strip for [layout].
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
    if (actions.isEmpty && layout.onOverflow == null) {
      return const SizedBox.shrink();
    }
    final items = <Widget>[
      for (final a in actions)
        NavBarItem(
          icon: a.icon,
          label: a.label,
          selected: a.selected,
          isSelectable: false,
          isToggle: a.selected,
          enabled: a.enabled,
          onTap: a.onPressed,
          badgeCount: a.badgeCount,
          activeColor: a.isDestructive ? kDestructiveColor : colors.active,
          inactiveColor: a.isDestructive ? kDestructiveColor : colors.inactive,
        ),
      if (layout.onOverflow != null)
        NavBarOverflowItem(layout: layout, colors: colors),
    ];
    return navBarTraversalGroup(
      child: ColoredBox(
        color: colors.background,
        child: IgnorePointer(
          ignoring: layout.actionsOpacity < 0.5,
          child: Opacity(
            opacity: layout.actionsOpacity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < items.length; i++)
                  FocusTraversalOrder(
                    order: NumericFocusOrder(i.toDouble()),
                    child: Semantics(
                      sortKey: OrdinalSortKey(i.toDouble()),
                      child: items[i],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
