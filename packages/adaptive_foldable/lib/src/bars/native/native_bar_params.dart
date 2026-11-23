import 'dart:ui' show Rect;

import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_destination.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart' show IconData, VoidCallback;

/// View type of the native bar platform view.
const String kNativeBarViewType = 'dev.adaptivefoldable/native_bar';

/// PNG bytes of rendered Flutter icons, keyed by glyph; only needed for items without an SF Symbol.
typedef NativeIconPngs = Map<IconData, List<int>>;

/// Flutter icons of [layout] that the native bar must receive as images because they have no SF Symbol.
Set<IconData> nativeIconsNeeded(NavLayout layout) => {
  for (final d in layout.destinations)
    if (d.sfSymbol == null) ...[d.icon, ?d.selectedIcon],
  for (final a in _actions(layout))
    if (a.sfSymbol == null) a.icon,
};

Iterable<NavAction> _actions(NavLayout layout) => [
  ?layout.prominentAction,
  for (final g in layout.visibleActions) ...g.actions,
];

/// Encodes [destinations] and the selection for the native bottom `UITabBar`.
Map<String, Object?> buildNativeBarParams({
  required List<NavDestination> destinations,
  required int selectedIndex,
  NativeIconPngs icons = const {},
}) => {
  'axis': 'horizontal',
  'selectedIndex': selectedIndex,
  'items': [
    for (final d in destinations)
      {
        'label': d.label,
        'sfSymbol': d.sfSymbol,
        'icon': icons[d.icon],
        'selectedIcon': d.selectedIcon == null ? null : icons[d.selectedIcon],
        'badge': d.badgeCount,
      },
  ],
};

/// Encodes the whole side column of [layout] for the native Liquid Glass column.
///
/// Groups, top to bottom: Back, prominent action, each action group, overflow
/// (all role `actions`), then the tabs (role `tabs`). Each item has an `id`
/// that [resolveNativeTap] maps back to a callback.
Map<String, Object?> buildNativeColumnParams(
  NavLayout layout, {
  NativeIconPngs icons = const {},
}) {
  Map<String, Object?> action(String id, NavAction a) => {
    'id': id,
    'label': a.label,
    'sfSymbol': a.sfSymbol,
    'icon': icons[a.icon],
    'selected': a.selected,
    'enabled': a.enabled,
    'destructive': a.isDestructive,
    'badge': a.badgeCount,
  };
  Map<String, Object?> fixed(String id, String label, String symbol) => {
    'id': id,
    'label': label,
    'sfSymbol': symbol,
    'selected': false,
    'enabled': true,
    'destructive': false,
  };
  final count = layout.destinations.length;
  return {
    'axis': 'vertical',
    'actionsOpacity': layout.actionsOpacity,
    'groups': [
      if (layout.showBack)
        {
          'role': 'actions',
          'items': [fixed('back', 'Back', 'chevron.backward')],
        },
      if (layout.prominentAction != null)
        {
          'role': 'actions',
          'items': [action('prominent', layout.prominentAction!)],
        },
      for (var g = 0; g < layout.visibleActions.length; g++)
        {
          'role': 'actions',
          'items': [
            for (var i = 0; i < layout.visibleActions[g].actions.length; i++)
              action('a:$g:$i', layout.visibleActions[g].actions[i]),
          ],
        },
      if (layout.onOverflow != null)
        {
          'role': 'actions',
          'items': [fixed('overflow', 'More', 'ellipsis')],
        },
      if (count > 0)
        {
          'role': 'tabs',
          'items': [
            for (var i = 0; i < count; i++)
              {
                'id': 'tab:$i',
                'label': layout.destinations[i].label,
                'sfSymbol': layout.destinations[i].sfSymbol,
                'icon': icons[layout.destinations[i].icon],
                'selectedIcon': layout.destinations[i].selectedIcon == null
                    ? null
                    : icons[layout.destinations[i].selectedIcon],
                'selected': i == layout.selectedIndex,
                'enabled': true,
                'destructive': false,
                'badge': layout.destinations[i].badgeCount,
              },
          ],
        },
    ],
  };
}

/// Returns the callback for a native column item [id], or null when the id is unknown.
///
/// [overflowRect] is the global rectangle of the tapped overflow button.
VoidCallback? resolveNativeTap(
  String id,
  NavLayout layout, {
  Rect overflowRect = Rect.zero,
}) {
  if (id == 'back') return layout.onBack;
  if (id == 'prominent') return layout.prominentAction?.onPressed;
  if (id == 'overflow') return () => layout.onOverflow?.call(overflowRect);
  if (id.startsWith('tab:')) {
    final i = int.tryParse(id.substring(4));
    if (i == null || i < 0 || i >= layout.destinations.length) return null;
    return () => layout.onSelected?.call(i);
  }
  final parts = id.split(':');
  if (parts.length == 3 && parts[0] == 'a') {
    final g = int.tryParse(parts[1]);
    final i = int.tryParse(parts[2]);
    if (g == null || i == null) return null;
    if (g < 0 || g >= layout.visibleActions.length) return null;
    final actions = layout.visibleActions[g].actions;
    return i >= 0 && i < actions.length ? actions[i].onPressed : null;
  }
  return null;
}
