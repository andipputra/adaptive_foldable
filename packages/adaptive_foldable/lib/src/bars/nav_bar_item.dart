import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:flutter/widgets.dart';

/// Smallest tap target in logical pixels.
const double kMinTapTarget = 44;

/// Colour used for destructive actions and badges when the caller gives none.
const Color kDestructiveColor = Color(0xFFB3261E);

/// One tappable icon-and-label entry shared by the default bars.
///
/// Draws the icon, label and optional badge with a tap target of at least
/// [kMinTapTarget] on both axes, one merged semantics node whose label doubles
/// as the tooltip, and keyboard focus with a visible highlight.
class NavBarItem extends StatefulWidget {
  /// Creates an item.
  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
    this.badgeCount,
    this.indicatorColor,
    this.enabled = true,
    this.isSelectable = true,
    this.isToggle = false,
    this.position,
  });

  /// Icon to draw.
  final IconData icon;

  /// Visible label, tooltip and screen reader text.
  final String label;

  /// Whether the item is the selected tab or a checked toggle action.
  final bool selected;

  /// Called on tap or keyboard activation; ignored when [enabled] is false.
  final VoidCallback? onTap;

  /// Colour of the selected icon and label.
  final Color activeColor;

  /// Colour of unselected content.
  final Color inactiveColor;

  /// Number shown in a badge, or null.
  final int? badgeCount;

  /// Pill behind the icon when selected, or null for none.
  final Color? indicatorColor;

  /// Whether the item reacts to taps.
  final bool enabled;

  /// Whether this is a tab, announcing a selected state.
  final bool isSelectable;

  /// Whether a non-tab item exposes a checked state; plain actions and Back do not.
  final bool isToggle;

  /// Screen reader hint such as "2 of 3" for tabs, or null.
  final String? position;

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final color = !w.enabled
        ? w.inactiveColor.withValues(alpha: 0.4)
        : w.selected
        ? w.activeColor
        : w.inactiveColor;
    final count = w.badgeCount;
    Widget glyph = Icon(w.icon, size: 24, color: color);
    if (w.selected && w.indicatorColor != null) {
      glyph = DecoratedBox(
        decoration: BoxDecoration(
          color: w.indicatorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: glyph,
        ),
      );
    }
    if (count != null && count > 0) {
      glyph = Stack(
        clipBehavior: Clip.none,
        children: [
          glyph,
          PositionedDirectional(end: -6, top: -4, child: _Badge(count: count)),
        ],
      );
    }
    final highlighted = _focused || _hovered;
    final value = [
      if (w.position != null) w.position!,
      if (count != null && count > 0) BarStrings.badge(count),
    ].join(', ');
    return Semantics(
      container: true,
      button: true,
      enabled: w.enabled,
      selected: w.isSelectable ? w.selected : null,
      checked: !w.isSelectable && w.isToggle ? w.selected : null,
      label: w.label,
      tooltip: w.label,
      value: value.isEmpty ? null : value,
      onTap: w.enabled ? w.onTap : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: w.enabled,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (v) => setState(() => _focused = v),
        onShowHoverHighlight: (v) => setState(() => _hovered = v),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              w.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: w.enabled ? w.onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: _focused
                  ? Border.all(color: w.activeColor, width: 2)
                  : null,
              color: highlighted && !_focused
                  ? w.activeColor.withValues(alpha: 0.08)
                  : null,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: kMinTapTarget,
                minHeight: kMinTapTarget,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    glyph,
                    const SizedBox(height: 2),
                    Text(
                      w.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.none,
                        color: color,
                        fontWeight: w.selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: kDestructiveColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFFFFFFF),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
