import 'dart:ui';

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';

/// Pure function merging platform bridge signals with Flutter's [DisplayFeature]s.
///
/// Implements auto-defer logic: If Flutter's [displayFeatures] contains active
/// fold or hinge features on iOS, folds are taken from Flutter instead of the native
/// bridge so they are never double-counted. Bar edge and other platform traits
/// remain bridged.
FoldSignalsSnapshot mergeFoldSources({
  required FoldSignals bridge,
  required List<DisplayFeature> displayFeatures,
  required Size viewSize,
}) {
  final flutterFolds = <Rect>[];
  final flutterOcclusions = <Rect>[];
  bool hasFlutterFold = false;
  Posture? flutterPosture;

  for (final feature in displayFeatures) {
    if (feature.type == DisplayFeatureType.fold ||
        feature.type == DisplayFeatureType.hinge) {
      hasFlutterFold = true;
      if (feature.state == DisplayFeatureState.postureHalfOpened) {
        flutterPosture = Posture.partiallyOpen;
        if (feature.bounds.width > 0 && feature.bounds.height > 0) {
          flutterFolds.add(feature.bounds);
        }
      } else if (feature.state == DisplayFeatureState.postureFlat) {
        flutterPosture = Posture.fullyOpen;
      }
    } else if (feature.type == DisplayFeatureType.cutout) {
      if (feature.bounds.width > 0 && feature.bounds.height > 0) {
        flutterOcclusions.add(feature.bounds);
      }
    }
  }

  final resolvedFolds = hasFlutterFold ? flutterFolds : bridge.activeFolds;
  final resolvedOcclusions = flutterOcclusions.isNotEmpty
      ? flutterOcclusions
      : bridge.occlusions;
  final resolvedPosture = flutterPosture ?? bridge.posture;

  final resolvedSize = viewSize != Size.zero ? viewSize : bridge.viewSize;

  return FoldSignalsSnapshot(
    verticalBarEdge: bridge.verticalBarEdge,
    horizontalSizeClass: bridge.horizontalSizeClass,
    verticalSizeClass: bridge.verticalSizeClass,
    viewSize: resolvedSize,
    activeFolds: resolvedFolds,
    occlusions: resolvedOcclusions,
    posture: resolvedPosture,
    isAvailable: bridge.isAvailable,
    sdk271: bridge.sdk271,
  );
}
