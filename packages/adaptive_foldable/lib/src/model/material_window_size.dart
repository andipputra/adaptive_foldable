import 'dart:ui' show Size;

import 'package:flutter/foundation.dart' show immutable;

/// Material 3 window size class along one axis.
enum MaterialSizeClass {
  /// Width below 600 dp, or height below 480 dp.
  compact,

  /// Width from 600 to below 840 dp, or height from 480 to below 900 dp.
  medium,

  /// Width of 840 dp or more, or height of 900 dp or more.
  expanded,
}

/// Material 3 window size classes for a window of a given size.
///
/// Computed from the window size, not the display size, so split-screen and
/// desktop windowing resolve against the space the app actually has.
@immutable
class MaterialWindowSize {
  /// Creates a window size from explicit classes.
  const MaterialWindowSize(this.width, this.height);

  /// Classifies [size] in logical pixels; non-positive axes are compact.
  factory MaterialWindowSize.fromSize(Size size) => MaterialWindowSize(
    classifyWidth(size.width),
    classifyHeight(size.height),
  );

  /// Width at which the medium class starts.
  static const double mediumMinWidth = 600;

  /// Width at which the expanded class starts.
  static const double expandedMinWidth = 840;

  /// Height at which the medium class starts.
  static const double mediumMinHeight = 480;

  /// Height at which the expanded class starts.
  static const double expandedMinHeight = 900;

  /// Classifies a window width in logical pixels.
  static MaterialSizeClass classifyWidth(double width) => width < mediumMinWidth
      ? MaterialSizeClass.compact
      : width < expandedMinWidth
      ? MaterialSizeClass.medium
      : MaterialSizeClass.expanded;

  /// Classifies a window height in logical pixels.
  static MaterialSizeClass classifyHeight(double height) =>
      height < mediumMinHeight
      ? MaterialSizeClass.compact
      : height < expandedMinHeight
      ? MaterialSizeClass.medium
      : MaterialSizeClass.expanded;

  /// Horizontal size class.
  final MaterialSizeClass width;

  /// Vertical size class.
  final MaterialSizeClass height;

  @override
  bool operator ==(Object other) =>
      other is MaterialWindowSize &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'MaterialWindowSize(width: $width, height: $height)';
}
