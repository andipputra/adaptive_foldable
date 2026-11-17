import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// The edge a navigation bar is attached to.
class NavPlacement {
  /// Creates a placement on [edge], optionally tagged with the [ruleId] that chose it.
  const NavPlacement(this.edge, {this.ruleId = ''});

  /// The edge holding the bar.
  final NavEdge edge;

  /// Stable identifier of the policy rule that produced this placement, for the debug overlay.
  ///
  /// Not part of equality: two placements on the same edge are equal.
  final String ruleId;

  /// Whether the bar is a side column rather than a bottom bar.
  bool get isVertical => edge != NavEdge.bottom;

  @override
  bool operator ==(Object other) => other is NavPlacement && other.edge == edge;

  @override
  int get hashCode => edge.hashCode;

  @override
  String toString() => 'NavPlacement($edge, rule: $ruleId)';
}
