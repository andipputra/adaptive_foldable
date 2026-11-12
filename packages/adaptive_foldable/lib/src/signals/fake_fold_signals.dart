import 'dart:ui';

import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/signal_types.dart';
import 'package:flutter/foundation.dart';

/// A test implementation of [FoldSignals] with mutable state and listener notifications.
class FakeFoldSignals extends ChangeNotifier implements FoldSignals {
  /// Creates a [FakeFoldSignals] with the given initial signals.
  FakeFoldSignals({
    NavEdge? verticalBarEdge,
    SizeClass horizontalSizeClass = SizeClass.unknown,
    SizeClass verticalSizeClass = SizeClass.unknown,
    Size viewSize = Size.zero,
    List<Rect> activeFolds = const [],
    List<Rect> occlusions = const [],
    Posture posture = Posture.unknown,
    bool isAvailable = false,
    bool sdk271 = false,
  }) : _snapshot = FoldSignalsSnapshot(
         verticalBarEdge: verticalBarEdge,
         horizontalSizeClass: horizontalSizeClass,
         verticalSizeClass: verticalSizeClass,
         viewSize: viewSize,
         activeFolds: activeFolds,
         occlusions: occlusions,
         posture: posture,
         isAvailable: isAvailable,
         sdk271: sdk271,
       );

  /// Creates a [FakeFoldSignals] initialized from a [FoldSignals] instance or preset.
  factory FakeFoldSignals.from(FoldSignals signals) {
    return FakeFoldSignals(
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

  FoldSignalsSnapshot _snapshot;

  /// Returns the current snapshot of signals.
  FoldSignalsSnapshot get snapshot => _snapshot;

  @override
  NavEdge? get verticalBarEdge => _snapshot.verticalBarEdge;

  @override
  SizeClass get horizontalSizeClass => _snapshot.horizontalSizeClass;

  @override
  SizeClass get verticalSizeClass => _snapshot.verticalSizeClass;

  @override
  Size get viewSize => _snapshot.viewSize;

  @override
  List<Rect> get activeFolds => _snapshot.activeFolds;

  @override
  List<Rect> get occlusions => _snapshot.occlusions;

  @override
  Posture get posture => _snapshot.posture;

  @override
  bool get isAvailable => _snapshot.isAvailable;

  @override
  bool get sdk271 => _snapshot.sdk271;

  /// Updates signals and notifies listeners if any values changed.
  void update({
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
    final next = _snapshot.copyWith(
      verticalBarEdge: verticalBarEdge,
      clearVerticalBarEdge: clearVerticalBarEdge,
      horizontalSizeClass: horizontalSizeClass,
      verticalSizeClass: verticalSizeClass,
      viewSize: viewSize,
      activeFolds: activeFolds,
      occlusions: occlusions,
      posture: posture,
      isAvailable: isAvailable,
      sdk271: sdk271,
    );
    if (next != _snapshot) {
      _snapshot = next;
      notifyListeners();
    }
  }

  /// Sets signals to match [newSignals] and notifies listeners if values changed.
  void setSignals(FoldSignals newSignals) {
    final next = FoldSignalsSnapshot.from(newSignals);
    if (next != _snapshot) {
      _snapshot = next;
      notifyListeners();
    }
  }
}

/// Named device and posture presets matching common phone, tablet, and foldable configurations.
abstract final class FoldSignalsPresets {
  /// iPhone Duo cover display in portrait orientation, measured on the simulator.
  static final FoldSignalsSnapshot duoCoverPortrait = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.right,
    horizontalSizeClass: SizeClass.compact,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(466, 678),
    activeFolds: const [],
    occlusions: const [
      Rect.fromLTRB(399.7, 29.3, 436.7, 66.3),
      Rect.fromLTRB(382, 0, 466, 174),
    ],
    posture: Posture.closed,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo cover display in landscape orientation, measured on the simulator.
  static final FoldSignalsSnapshot duoCoverLandscape = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.right,
    horizontalSizeClass: SizeClass.compact,
    verticalSizeClass: SizeClass.compact,
    viewSize: const Size(678, 466),
    activeFolds: const [],
    occlusions: const [
      Rect.fromLTRB(611.7, 399.7, 648.7, 436.7),
      Rect.fromLTRB(594.0, 384.0, 678.0, 466.0),
    ],
    posture: Posture.closed,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo inner display in portrait orientation, measured on the simulator.
  static final FoldSignalsSnapshot duoInnerPortrait = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(669, 951),
    activeFolds: const [],
    occlusions: const [Rect.fromLTRB(525.0, 0.0, 669.0, 82.0)],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo inner display in landscape orientation, measured on the simulator.
  static final FoldSignalsSnapshot duoInnerLandscape = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.right,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(951, 669),
    activeFolds: const [],
    occlusions: const [Rect.fromLTRB(867.0, 0.0, 951.0, 124.0)],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo partially open in book pose with a 40 pt vertical fold, measured on the simulator.
  static final FoldSignalsSnapshot duoBookPose = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.right,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(951, 669),
    activeFolds: const [Rect.fromLTRB(455.5, 0.0, 495.5, 669.0)],
    occlusions: const [Rect.fromLTRB(867.0, 0.0, 951.0, 124.0)],
    posture: Posture.partiallyOpen,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo Split View with column on left edge.
  static final FoldSignalsSnapshot duoSplitViewLeft = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.left,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(455.5, 669),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: true,
  );

  /// iPhone Duo Split View with column on right edge.
  static final FoldSignalsSnapshot duoSplitViewRight = FoldSignalsSnapshot(
    verticalBarEdge: NavEdge.right,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(455.5, 669),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: true,
  );

  /// Android phone or folded cover screen with compact width (< 600 dp).
  static final FoldSignalsSnapshot androidCompact = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.compact,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(412, 915),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.closed,
    isAvailable: true,
    sdk271: false,
  );

  /// Android foldable inner screen or small tablet (600 to 840 dp).
  static final FoldSignalsSnapshot androidMedium = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(700, 900),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: false,
  );

  /// Android tablet or large foldable screen (>= 840 dp).
  static final FoldSignalsSnapshot androidExpanded = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(1000, 800),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.fullyOpen,
    isAvailable: true,
    sdk271: false,
  );

  /// Android foldable partially open in book pose (vertical hinge).
  static final FoldSignalsSnapshot androidBook = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(840, 800),
    activeFolds: const [Rect.fromLTWH(400, 0, 40, 800)],
    occlusions: const [],
    posture: Posture.partiallyOpen,
    isAvailable: true,
    sdk271: false,
  );

  /// Android foldable partially open in tabletop pose (horizontal hinge).
  static final FoldSignalsSnapshot androidTabletop = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(800, 840),
    activeFolds: const [Rect.fromLTWH(0, 400, 800, 40)],
    occlusions: const [],
    posture: Posture.partiallyOpen,
    isAvailable: true,
    sdk271: false,
  );

  /// Regular non-foldable iPhone (no verticalBarEdge, compact width).
  static final FoldSignalsSnapshot regularIphone = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.compact,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(393, 852),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.unknown,
    isAvailable: true,
    sdk271: false,
  );

  /// Non-foldable iPad (regular size classes, no verticalBarEdge).
  static final FoldSignalsSnapshot ipad = FoldSignalsSnapshot(
    verticalBarEdge: null,
    horizontalSizeClass: SizeClass.regular,
    verticalSizeClass: SizeClass.regular,
    viewSize: const Size(1024, 768),
    activeFolds: const [],
    occlusions: const [],
    posture: Posture.unknown,
    isAvailable: true,
    sdk271: false,
  );
}
