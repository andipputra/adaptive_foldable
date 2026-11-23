import 'package:adaptive_foldable/src/model/nav_insets.dart';

/// Where a bar places its items along its main axis.
enum NavBarAlignment {
  /// Items start at the leading edge.
  start,

  /// Items are centred.
  center,

  /// Items end at the trailing edge.
  end,
}

/// Where page actions (Back, prominent action, groups, overflow) are drawn.
enum NavActionsPosition {
  /// Inside the navigation bar, as the placement policy decides (Apple) or in `NavLayout.headerActions` (Material).
  inBar,

  /// In a separate bar at the top while the tabs stay in the navigation bar, like a native app.
  top,
}

/// Spacing, size and safe-area options for a default bar.
///
/// Every field is optional; null keeps the bar's own default. Custom
/// `barBuilder`s receive the style as `NavLayout.barStyle` and may honour it.
class NavBarStyle {
  /// Creates a style.
  const NavBarStyle({
    this.padding,
    this.itemSpacing,
    this.alignment,
    this.height,
    this.respectSafeArea = true,
  });

  /// Space around the items, inside the bar.
  final NavInsets? padding;

  /// Gap in dp between neighbouring items.
  final double? itemSpacing;

  /// Placement of the items along the bar's main axis.
  final NavBarAlignment? alignment;

  /// Content height in dp of a horizontal bar, excluding system insets.
  final double? height;

  /// Whether the bar keeps clear of the status bar (top bar) or home indicator (bottom bar).
  ///
  /// When false the bar runs under the inset and reports no gap.
  final bool respectSafeArea;

  @override
  bool operator ==(Object other) =>
      other is NavBarStyle &&
      other.padding == padding &&
      other.itemSpacing == itemSpacing &&
      other.alignment == alignment &&
      other.height == height &&
      other.respectSafeArea == respectSafeArea;

  @override
  int get hashCode =>
      Object.hash(padding, itemSpacing, alignment, height, respectSafeArea);
}
