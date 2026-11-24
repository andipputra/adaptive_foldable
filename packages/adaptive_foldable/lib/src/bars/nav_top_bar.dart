import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;
import 'package:flutter/widgets.dart';

/// Top action bar in the order of a native app: Back on the leading side, the prominent action, action groups and overflow after it.
///
/// Draws `layout.showBack`, `layout.prominentAction`, `layout.headerActions` and
/// the overflow control; the tabs stay in the navigation bar. Spacing, alignment
/// and padding come from `layout.topBarStyle`; the bar keeps clear of the status
/// bar by `layout.geometry.topBarInset`. Fades with `layout.actionsOpacity`.
/// Apps can use it inside their own `topBarBuilder` or place it themselves.
class NavTopBar extends StatelessWidget {
  /// Creates the bar for [layout]; [colors] default to the Cupertino-style or Material palette by platform.
  const NavTopBar({super.key, required this.layout, required this.colors});

  /// The resolved layout.
  final NavLayout layout;

  /// Colours to apply.
  final NavBarColors colors;

  @override
  Widget build(BuildContext context) {
    final style = layout.topBarStyle;
    final actions = <Widget>[
      if (layout.prominentAction != null) _action(layout.prominentAction!),
      for (final g in layout.headerActions)
        for (final a in g.actions) _action(a),
      if (layout.onOverflow != null)
        NavBarOverflowItem(layout: layout, colors: colors),
    ];
    final back = layout.showBack
        ? NavBarItem(
            icon: kBackIcon,
            label: BarStrings.back,
            selected: false,
            isSelectable: false,
            onTap: layout.onBack,
            activeColor: colors.active,
            inactiveColor: colors.inactive,
          )
        : null;
    var index = 0;
    Widget ordered(Widget child) {
      final i = index++;
      return FocusTraversalOrder(
        order: NumericFocusOrder(i.toDouble()),
        child: Semantics(sortKey: OrdinalSortKey(i.toDouble()), child: child),
      );
    }

    final orderedBack = back == null ? null : ordered(back);
    final orderedActions = [for (final w in actions) ordered(w)];
    final faded = layout.actionsOpacity < 1;
    Widget fade(Widget w) => faded
        ? IgnorePointer(
            ignoring: layout.actionsOpacity < 0.5,
            child: Opacity(opacity: layout.actionsOpacity, child: w),
          )
        : w;
    return navBarTraversalGroup(
      child: ColoredBox(
        color: colors.background,
        child: Padding(
          padding: EdgeInsets.only(top: layout.geometry.topBarInset),
          child: Padding(
            padding: paddingFor(
              style,
              const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Row(
              children: [
                if (orderedBack != null) fade(orderedBack),
                Expanded(
                  child: fade(
                    Row(
                      mainAxisAlignment: mainAxisFor(
                        style.alignment,
                        fallback: MainAxisAlignment.end,
                      ),
                      children: spaceItems(
                        orderedActions,
                        style.itemSpacing,
                        Axis.horizontal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  NavBarItem _action(NavAction a) => NavBarItem(
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
  );
}
