import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/widgets.dart';

/// Signature for a widget builder that receives the current [FoldSignals].
typedef FoldWidgetBuilder = Widget Function(
  BuildContext context,
  FoldSignals foldSignals,
);

/// A convenience widget that retrieves [FoldSignals] from [context] and builds
/// its child widget accordingly.
///
/// Rebuilds whenever fold geometry, posture, or screen size changes in the
/// ambient [FoldSignalsScope].
class FoldBuilder extends StatelessWidget {
  /// Creates a fold builder widget.
  const FoldBuilder({super.key, required this.builder});

  /// Called to build the widget tree using current [FoldSignals].
  final FoldWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final signals = FoldSignals.of(context);
    return builder(context, signals);
  }
}
