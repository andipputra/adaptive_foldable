/// Window size class used to adapt layout across different screen sizes.
enum SizeClass {
  /// Compact size class (e.g. typical phone in portrait).
  compact,

  /// Regular size class (e.g. tablet, desktop, or expanded foldable width).
  regular,

  /// Size class is unknown or not yet determined.
  unknown,
}

/// Physical posture of a foldable device.
enum Posture {
  /// Device is closed (e.g. cover display active).
  closed,

  /// Device is partially open (e.g. book pose or tabletop pose with active hinge).
  partiallyOpen,

  /// Device is fully open and laid flat.
  fullyOpen,

  /// Posture is unknown or not reported by the platform.
  unknown,
}

/// Navigation bar edge placement.
///
/// [left] and [right] are physical edges (used by Apple policy to prevent flipping in RTL).
/// [leading] and [trailing] are logical edges (used by Material policy).
/// [bottom] places the navigation bar along the bottom of the screen.
enum NavEdge {
  /// Bottom edge of the display.
  bottom,

  /// Logical leading edge (left in LTR, right in RTL).
  leading,

  /// Logical trailing edge (right in LTR, left in RTL).
  trailing,

  /// Physical left edge, never flipped in RTL.
  left,

  /// Physical right edge, never flipped in RTL.
  right,
}
