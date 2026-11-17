import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// The edge a navigation bar is attached to.
class NavPlacement {
  /// Creates a placement on [edge].
  const NavPlacement(this.edge);

  /// The edge holding the bar.
  final NavEdge edge;

  /// Whether the bar is a side column rather than a bottom bar.
  bool get isVertical => edge != NavEdge.bottom;

  @override
  bool operator ==(Object other) => other is NavPlacement && other.edge == edge;

  @override
  int get hashCode => edge.hashCode;

  @override
  String toString() => 'NavPlacement($edge)';
}
