import 'dart:ui' show Rect;

import 'package:adaptive_foldable/src/model/nav_axis.dart';

/// Resolved position and clearances of the navigation bar.
class NavGeometry {
  /// Creates a geometry.
  const NavGeometry({
    required this.barRect,
    required this.itemAxis,
    this.skipRegion,
    this.homeIndicatorGap = 0,
    this.foldClearance = 0,
  });

  /// Rectangle of the bar or column in view coordinates.
  final Rect barRect;

  /// Status bar, camera or fold region the items must skip, if any.
  final Rect? skipRegion;

  /// Direction in which items are laid out.
  final NavAxis itemAxis;

  /// Space kept free for the home indicator or gesture bar.
  final double homeIndicatorGap;

  /// Space kept free on each side of an active fold.
  final double foldClearance;

  /// Returns a copy with the given fields replaced.
  NavGeometry copyWith({
    Rect? barRect,
    Rect? skipRegion,
    NavAxis? itemAxis,
    double? homeIndicatorGap,
    double? foldClearance,
  }) => NavGeometry(
    barRect: barRect ?? this.barRect,
    skipRegion: skipRegion ?? this.skipRegion,
    itemAxis: itemAxis ?? this.itemAxis,
    homeIndicatorGap: homeIndicatorGap ?? this.homeIndicatorGap,
    foldClearance: foldClearance ?? this.foldClearance,
  );

  @override
  bool operator ==(Object other) =>
      other is NavGeometry &&
      other.barRect == barRect &&
      other.skipRegion == skipRegion &&
      other.itemAxis == itemAxis &&
      other.homeIndicatorGap == homeIndicatorGap &&
      other.foldClearance == foldClearance;

  @override
  int get hashCode => Object.hash(
    barRect,
    skipRegion,
    itemAxis,
    homeIndicatorGap,
    foldClearance,
  );
}
