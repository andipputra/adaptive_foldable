/// Relative importance of a [NavAction] when space runs out; lower overflows first.
enum NavPriority {
  /// Overflows first.
  low,

  /// Default importance.
  normal,

  /// Stays visible longest.
  high,
}
