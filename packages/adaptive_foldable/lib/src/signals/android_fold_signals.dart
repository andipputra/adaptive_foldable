import 'dart:ui';

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Pure resolver for Android platform foldable signals and size classes.
abstract final class AndroidFoldSignals {
  /// Computes [FoldSignalsSnapshot] for an Android device.
  static FoldSignalsSnapshot resolve({
    required Size viewSize,
    required List<DisplayFeature> displayFeatures,
  }) {
    final hSize = viewSize.width <= 0
        ? SizeClass.unknown
        : (viewSize.width < 600.0 ? SizeClass.compact : SizeClass.regular);

    final vSize = viewSize.height <= 0
        ? SizeClass.unknown
        : (viewSize.height < 480.0 ? SizeClass.compact : SizeClass.regular);

    final activeFolds = <Rect>[];
    final occlusions = <Rect>[];
    Posture posture = Posture.unknown;

    for (final feature in displayFeatures) {
      if (feature.type == DisplayFeatureType.fold ||
          feature.type == DisplayFeatureType.hinge) {
        if (feature.state == DisplayFeatureState.postureHalfOpened) {
          posture = Posture.partiallyOpen;
          if (feature.bounds.width > 0 && feature.bounds.height > 0) {
            activeFolds.add(feature.bounds);
          }
        } else if (feature.state == DisplayFeatureState.postureFlat) {
          posture = Posture.fullyOpen;
        }
      } else if (feature.type == DisplayFeatureType.cutout) {
        if (feature.bounds.width > 0 && feature.bounds.height > 0) {
          occlusions.add(feature.bounds);
        }
      }
    }

    return FoldSignalsSnapshot(
      verticalBarEdge: null,
      horizontalSizeClass: hSize,
      verticalSizeClass: vSize,
      viewSize: viewSize,
      activeFolds: activeFolds,
      occlusions: occlusions,
      posture: posture,
      isAvailable: true,
      sdk271: false,
    );
  }
}

/// Fallback resolver for desktop, web, and other non-foldable platforms.
abstract final class DefaultFoldSignals {
  /// Resolves default signals from [viewSize] and [displayFeatures].
  static FoldSignalsSnapshot resolve({
    required Size viewSize,
    required List<DisplayFeature> displayFeatures,
  }) {
    final hSize = viewSize.width <= 0
        ? SizeClass.unknown
        : (viewSize.width < 600.0 ? SizeClass.compact : SizeClass.regular);

    final vSize = viewSize.height <= 0
        ? SizeClass.unknown
        : (viewSize.height < 480.0 ? SizeClass.compact : SizeClass.regular);

    return FoldSignalsSnapshot(
      verticalBarEdge: null,
      horizontalSizeClass: hSize,
      verticalSizeClass: vSize,
      viewSize: viewSize,
      activeFolds: const [],
      occlusions: const [],
      posture: Posture.unknown,
      isAvailable: false,
      sdk271: false,
    );
  }
}
