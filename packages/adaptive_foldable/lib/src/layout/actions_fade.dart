/// Which page's actions to draw while a route transition runs, and how opaque.
class ActionsFade {
  /// Creates a fade state.
  const ActionsFade({required this.showIncoming, required this.opacity});

  /// True to draw the incoming (top) page's actions, false for the outgoing (lower) page's.
  final bool showIncoming;

  /// Opacity from 0 to 1.
  final double opacity;

  @override
  bool operator ==(Object other) =>
      other is ActionsFade &&
      other.showIncoming == showIncoming &&
      other.opacity == opacity;

  @override
  int get hashCode => Object.hash(showIncoming, opacity);
}

/// Maps the top route's animation value [t] (0 hidden, 1 shown) to an [ActionsFade].
///
/// The outgoing actions fade out over the first half and the incoming ones fade
/// in over the second half, so the value follows a back swipe under the finger
/// and reverses when the swipe is cancelled. With [reduceMotion] the swap is
/// instant at the halfway point and opacity stays 1.
ActionsFade actionsFade(double t, {bool reduceMotion = false}) {
  final p = t.isNaN ? 1.0 : t.clamp(0.0, 1.0);
  final showIncoming = p >= 0.5;
  if (reduceMotion || p >= 1) {
    return ActionsFade(showIncoming: showIncoming, opacity: 1);
  }
  final opacity = showIncoming ? (p - 0.5) * 2 : 1 - p * 2;
  return ActionsFade(showIncoming: showIncoming, opacity: opacity);
}
