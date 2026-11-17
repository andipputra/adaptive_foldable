import 'dart:math' as math;

import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:flutter/widgets.dart';

/// Row height of the default overflow menu, comfortably above the 44 pt target.
const double kOverflowRowHeight = 48;

/// Width of the default overflow menu.
const double kOverflowMenuWidth = 224;

const double _gap = 8;

/// Default overflow menu drawn by Flutter next to the overflow button.
///
/// Fills its parent: a transparent barrier dismisses the menu on an outside
/// tap, and the panel sits beside [anchor] (left of a right-edge column, right
/// of a left-edge column, above a bottom bar), clamped inside the view.
class NavOverflowMenu extends StatelessWidget {
  /// Creates a menu for [items] anchored at the global rectangle [anchor].
  const NavOverflowMenu({
    super.key,
    required this.items,
    required this.anchor,
    required this.dismiss,
  });

  /// Actions that did not fit in the bar.
  final List<NavAction> items;

  /// Global rectangle of the overflow button.
  final Rect anchor;

  /// Closes the menu.
  final VoidCallback dismiss;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final background = dark ? const Color(0xFF2B2930) : const Color(0xFFFFFFFF);
    final foreground = dark ? const Color(0xFFE6E0E9) : const Color(0xFF1D1B20);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final height = math.min(
          items.length * kOverflowRowHeight + 16,
          math.max(kOverflowRowHeight, size.height - 2 * _gap),
        );
        double left;
        double top;
        if (anchor.center.dx > size.width * 0.66 &&
            anchor.width < size.width / 2 &&
            anchor.height > anchor.width * 0.0 &&
            anchor.top < size.height - kOverflowRowHeight * 2) {
          left = anchor.left - kOverflowMenuWidth - _gap;
          top = anchor.top;
        } else if (anchor.center.dx < size.width * 0.33) {
          left = anchor.right + _gap;
          top = anchor.top;
        } else {
          left = anchor.center.dx - kOverflowMenuWidth / 2;
          top = anchor.top - height - _gap;
        }
        left = left.clamp(
          _gap,
          math.max(_gap, size.width - kOverflowMenuWidth - _gap),
        );
        top = top.clamp(_gap, math.max(_gap, size.height - height - _gap));
        return Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                label: BarStrings.dismissMenu,
                button: true,
                onTap: dismiss,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: dismiss,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: kOverflowMenuWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      for (final item in items)
                        _MenuRow(
                          item: item,
                          color: item.isDestructive
                              ? kDestructiveColor
                              : foreground,
                          dismiss: dismiss,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({
    required this.item,
    required this.color,
    required this.dismiss,
  });

  final NavAction item;
  final Color color;
  final VoidCallback dismiss;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _focused = false;

  void _activate() {
    widget.dismiss();
    widget.item.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = item.enabled
        ? widget.color
        : widget.color.withValues(alpha: 0.4);
    return Semantics(
      container: true,
      button: true,
      enabled: item.enabled,
      checked: item.selected ? true : null,
      label: item.label,
      onTap: item.enabled ? _activate : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: item.enabled,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: item.enabled ? _activate : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: _focused ? Border.all(color: color, width: 2) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              height: kOverflowRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(item.icon, size: 24, color: color),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: color,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    if (item.selected)
                      Icon(
                        const IconData(0xe156, fontFamily: 'MaterialIcons'),
                        size: 20,
                        color: color,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
