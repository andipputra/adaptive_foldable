/// How the layout changes visually when the placement changes.
enum NavTransition {
  /// Switch immediately.
  instant,

  /// Fade the bar in over [NavTransitions.duration].
  crossfade,
}

/// Configures transitions between layouts.
///
/// Defaults: instant on fold or unfold (iOS runs its own transition), a 200 ms
/// crossfade on resize (rotation, Split View). Reduce Motion forces instant
/// unless [respectReduceMotion] is false. The body is never touched.
class NavTransitions {
  /// Creates a transition configuration.
  const NavTransitions({
    this.onFoldChange = NavTransition.instant,
    this.onResize = NavTransition.crossfade,
    this.duration = const Duration(milliseconds: 200),
    this.respectReduceMotion = true,
  });

  /// Transition when the posture changes (fold or unfold).
  final NavTransition onFoldChange;

  /// Transition when the view size changes without a posture change.
  final NavTransition onResize;

  /// Length of a [NavTransition.crossfade].
  final Duration duration;

  /// Whether Reduce Motion forces instant transitions.
  final bool respectReduceMotion;
}
