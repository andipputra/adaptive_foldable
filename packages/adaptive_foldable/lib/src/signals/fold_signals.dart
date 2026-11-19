import 'dart:ui';

import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart';

/// The interface through which all higher layers access platform and foldable device signals.
abstract interface class FoldSignals implements Listenable {
  /// Internal hook connecting [maybeOf] to the UI scope without importing widgets in pure layers.
  ///
  /// Set by `FoldSignalsScope`; not part of the public API.
  static Object? Function(Object context)? signalsMaybeOfHook;

  /// Returns the nearest [FoldSignals] found in the `BuildContext` [context].
  ///
  /// Fails an assertion in debug builds, and throws a [StateError] in release
  /// builds, if no `FoldSignalsScope` is found in the widget tree.
  static FoldSignals of(Object context) {
    final signals = maybeOf(context);
    assert(
      signals != null,
      'No FoldSignalsScope found in the widget tree. '
      'Wrap your app or test widget with FoldSignalsScope.',
    );
    if (signals == null) {
      throw StateError('No FoldSignalsScope found in the widget tree.');
    }
    return signals;
  }

  /// Returns the nearest [FoldSignals] found in the `BuildContext` [context],
  /// or null if none exists.
  static FoldSignals? maybeOf(Object context) {
    final hook = signalsMaybeOfHook;
    return hook == null ? null : hook(context) as FoldSignals?;
  }

  /// The physical edge of the vertical navigation column reported by the system,
  /// or null if no system column is active.
  NavEdge? get verticalBarEdge;

  /// The horizontal size class of the window.
  SizeClass get horizontalSizeClass;

  /// The vertical size class of the window.
  SizeClass get verticalSizeClass;

  /// The size of the Flutter view in logical points.
  Size get viewSize;

  /// Rectangles representing active hardware folds or hinges.
  ///
  /// Empty unless the device is partially open or in a folded state.
  /// Zero-width or inactive rects are never included.
  List<Rect> get activeFolds;

  /// Occlusion regions such as camera cutouts or sensor housings.
  List<Rect> get occlusions;

  /// The physical posture of the foldable device.
  Posture get posture;

  /// Whether the platform signal bridge is available and has responded.
  bool get isAvailable;

  /// Whether the native iOS 27.1+ Duo SDK APIs were compiled into the app.
  bool get sdk271;
}

/// An immutable value-equality snapshot of [FoldSignals].
@immutable
class FoldSignalsSnapshot implements FoldSignals {
  /// Creates a [FoldSignalsSnapshot].
  FoldSignalsSnapshot({
    this.verticalBarEdge,
    this.horizontalSizeClass = SizeClass.unknown,
    this.verticalSizeClass = SizeClass.unknown,
    this.viewSize = Size.zero,
    List<Rect> activeFolds = const [],
    List<Rect> occlusions = const [],
    this.posture = Posture.unknown,
    this.isAvailable = false,
    this.sdk271 = false,
  }) : activeFolds = List.unmodifiable(activeFolds),
       occlusions = List.unmodifiable(occlusions);

  /// Creates a snapshot with default empty values.
  const FoldSignalsSnapshot.empty()
    : verticalBarEdge = null,
      horizontalSizeClass = SizeClass.unknown,
      verticalSizeClass = SizeClass.unknown,
      viewSize = Size.zero,
      activeFolds = const [],
      occlusions = const [],
      posture = Posture.unknown,
      isAvailable = false,
      sdk271 = false;

  /// Creates a snapshot from an existing [FoldSignals] instance.
  factory FoldSignalsSnapshot.from(FoldSignals signals) {
    if (signals is FoldSignalsSnapshot) {
      return signals;
    }
    return FoldSignalsSnapshot(
      verticalBarEdge: signals.verticalBarEdge,
      horizontalSizeClass: signals.horizontalSizeClass,
      verticalSizeClass: signals.verticalSizeClass,
      viewSize: signals.viewSize,
      activeFolds: signals.activeFolds,
      occlusions: signals.occlusions,
      posture: signals.posture,
      isAvailable: signals.isAvailable,
      sdk271: signals.sdk271,
    );
  }

  @override
  final NavEdge? verticalBarEdge;

  @override
  final SizeClass horizontalSizeClass;

  @override
  final SizeClass verticalSizeClass;

  @override
  final Size viewSize;

  @override
  final List<Rect> activeFolds;

  @override
  final List<Rect> occlusions;

  @override
  final Posture posture;

  @override
  final bool isAvailable;

  @override
  final bool sdk271;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  /// Creates a copy of this snapshot with the given fields replaced.
  FoldSignalsSnapshot copyWith({
    NavEdge? verticalBarEdge,
    bool clearVerticalBarEdge = false,
    SizeClass? horizontalSizeClass,
    SizeClass? verticalSizeClass,
    Size? viewSize,
    List<Rect>? activeFolds,
    List<Rect>? occlusions,
    Posture? posture,
    bool? isAvailable,
    bool? sdk271,
  }) {
    return FoldSignalsSnapshot(
      verticalBarEdge: clearVerticalBarEdge
          ? null
          : (verticalBarEdge ?? this.verticalBarEdge),
      horizontalSizeClass: horizontalSizeClass ?? this.horizontalSizeClass,
      verticalSizeClass: verticalSizeClass ?? this.verticalSizeClass,
      viewSize: viewSize ?? this.viewSize,
      activeFolds: activeFolds ?? this.activeFolds,
      occlusions: occlusions ?? this.occlusions,
      posture: posture ?? this.posture,
      isAvailable: isAvailable ?? this.isAvailable,
      sdk271: sdk271 ?? this.sdk271,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FoldSignalsSnapshot) return false;
    return other.verticalBarEdge == verticalBarEdge &&
        other.horizontalSizeClass == horizontalSizeClass &&
        other.verticalSizeClass == verticalSizeClass &&
        other.viewSize == viewSize &&
        listEquals(other.activeFolds, activeFolds) &&
        listEquals(other.occlusions, occlusions) &&
        other.posture == posture &&
        other.isAvailable == isAvailable &&
        other.sdk271 == sdk271;
  }

  @override
  int get hashCode => Object.hash(
    verticalBarEdge,
    horizontalSizeClass,
    verticalSizeClass,
    viewSize,
    Object.hashAll(activeFolds),
    Object.hashAll(occlusions),
    posture,
    isAvailable,
    sdk271,
  );

  @override
  String toString() {
    return 'FoldSignalsSnapshot('
        'verticalBarEdge: $verticalBarEdge, '
        'horizontalSizeClass: $horizontalSizeClass, '
        'verticalSizeClass: $verticalSizeClass, '
        'viewSize: $viewSize, '
        'activeFolds: $activeFolds, '
        'occlusions: $occlusions, '
        'posture: $posture, '
        'isAvailable: $isAvailable, '
        'sdk271: $sdk271)';
  }
}
