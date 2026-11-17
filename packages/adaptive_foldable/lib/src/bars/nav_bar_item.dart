import 'package:adaptive_foldable/src/bars/bar_strings.dart';
import 'package:flutter/widgets.dart';

/// Smallest tap target in logical pixels.
const double kMinTapTarget = 44;

/// One tappable icon-and-label entry shared by the default bars.
///
/// Draws the icon, label and optional badge, with a tap target of at least
/// [kMinTapTarget] on both axes and one merged semantics node.
class NavBarItem extends StatelessWidget {
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
  });

  /// Icon to draw.
  final IconData icon;

  /// Visible label, tooltip and screen reader text.
  final String label;

  /// Whether the item is the selected tab or a checked action.
  final bool selected;

  /// Called on tap; ignored when [enabled] is false.
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

  /// Whether selection state is announced to screen readers.
  final bool isSelectable;

  @override
  Widget build(BuildContext context) {
    final color = !enabled
        ? inactiveColor.withValues(alpha: 0.4)
        : selected
        ? activeColor
        : inactiveColor;
    final count = badgeCount;
    Widget glyph = Icon(icon, size: 24, color: color);
    if (selected && indicatorColor != null) {
      glyph = DecoratedBox(
        decoration: BoxDecoration(
          color: indicatorColor,
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
    return Semantics(
      container: true,
      button: true,
      enabled: enabled,
      selected: isSelectable ? selected : null,
      checked: isSelectable ? null : selected,
      label: label,
      value: count != null && count > 0 ? BarStrings.badge(count) : null,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
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
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    decoration: TextDecoration.none,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFB3261E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: const TextStyle(fontSize: 10, color: Color(0xFFFFFFFF)),
        ),
      ),
    );
  }
}
