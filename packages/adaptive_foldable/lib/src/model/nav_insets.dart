/// Unobstructed-area insets of the view in logical pixels, such as system padding.
class NavInsets {
  /// Creates insets from each side.
  const NavInsets({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// No insets.
  static const NavInsets zero = NavInsets();

  /// Inset on the physical left side.
  final double left;

  /// Inset on the top side.
  final double top;

  /// Inset on the physical right side.
  final double right;

  /// Inset on the bottom side.
  final double bottom;

  @override
  bool operator ==(Object other) =>
      other is NavInsets &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(left, top, right, bottom);
}
