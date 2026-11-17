import 'dart:ui' show TextDirection;

import 'package:adaptive_foldable/src/model/nav_placement.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';

/// Decides where the navigation bar goes from device signals.
///
/// Implementations must be pure: the result depends only on the arguments.
abstract interface class NavPlacementPolicy {
  /// Returns the placement for [signals] under text [direction].
  NavPlacement resolve(FoldSignals signals, TextDirection direction);
}
