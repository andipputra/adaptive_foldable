import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter_test/flutter_test.dart';

class _Case {
  const _Case(this.name, this.signals, this.edge, this.rule);
  final String name;
  final FoldSignalsSnapshot signals;
  final NavEdge edge;
  final String rule;
}

FoldSignalsSnapshot _s({
  NavEdge? edge,
  SizeClass h = SizeClass.unknown,
  SizeClass v = SizeClass.unknown,
  Size size = Size.zero,
  Posture posture = Posture.unknown,
  List<Rect> folds = const [],
  List<Rect> occlusions = const [],
  bool available = true,
  bool sdk271 = true,
}) => FoldSignalsSnapshot(
  verticalBarEdge: edge,
  horizontalSizeClass: h,
  verticalSizeClass: v,
  viewSize: size,
  posture: posture,
  activeFolds: folds,
  occlusions: occlusions,
  isAvailable: available,
  sdk271: sdk271,
);

void main() {
  const policy = ApplePolicy();

  final cases = <_Case>[
    _Case(
      'Duo cover landscape, system right',
      _s(
        edge: NavEdge.right,
        h: SizeClass.compact,
        v: SizeClass.compact,
        size: const Size(678, 466),
        posture: Posture.closed,
      ),
      NavEdge.right,
      ApplePolicy.ruleSystemEdge,
    ),
    _Case(
      'Duo inner landscape, system left',
      _s(
        edge: NavEdge.left,
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(951, 669),
        posture: Posture.fullyOpen,
      ),
      NavEdge.left,
      ApplePolicy.ruleSystemEdge,
    ),
    _Case(
      'Duo book pose, system edge',
      _s(
        edge: NavEdge.right,
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(951, 669),
        posture: Posture.partiallyOpen,
        folds: const [Rect.fromLTWH(470, 0, 10, 669)],
      ),
      NavEdge.right,
      ApplePolicy.ruleSystemEdge,
    ),
    _Case(
      'Duo inner portrait, no edge',
      _s(
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(669, 951),
        posture: Posture.fullyOpen,
      ),
      NavEdge.bottom,
      ApplePolicy.ruleBridgeNoEdge,
    ),
    _Case(
      'Duo tabletop, no edge',
      _s(
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(669, 951),
        posture: Posture.partiallyOpen,
        folds: const [Rect.fromLTWH(0, 470, 669, 10)],
      ),
      NavEdge.bottom,
      ApplePolicy.ruleTabletop,
    ),
    _Case(
      'regular iPhone portrait',
      _s(
        h: SizeClass.compact,
        v: SizeClass.regular,
        size: const Size(393, 852),
      ),
      NavEdge.bottom,
      ApplePolicy.ruleBridgeNoEdge,
    ),
    _Case(
      'iPad landscape, no edge',
      _s(
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(1194, 834),
      ),
      NavEdge.bottom,
      ApplePolicy.ruleBridgeNoEdge,
    ),
    _Case(
      'bridge unavailable, regular portrait -> fallback bottom',
      _s(
        h: SizeClass.regular,
        v: SizeClass.regular,
        size: const Size(669, 951),
        available: false,
        sdk271: false,
      ),
      NavEdge.bottom,
      ApplePolicy.ruleFallback,
    ),
    _Case(
      'bridge unavailable, cover landscape -> fallback right',
      _s(
        h: SizeClass.compact,
        v: SizeClass.compact,
        size: const Size(678, 466),
        available: false,
        sdk271: false,
      ),
      NavEdge.right,
      ApplePolicy.ruleFallback,
    ),
    _Case(
      'bridge answered, no Duo SDK -> bottom even when cover-shaped',
      _s(
        h: SizeClass.compact,
        v: SizeClass.compact,
        size: const Size(678, 466),
        sdk271: false,
      ),
      NavEdge.bottom,
      ApplePolicy.ruleBridgeNoEdge,
    ),
  ];

  for (final c in cases) {
    for (final dir in TextDirection.values) {
      test('${c.name} (${dir.name})', () {
        final p = policy.resolve(c.signals, dir);
        expect(p.edge, c.edge);
        expect(p.ruleId, c.rule);
      });
    }
  }

  test('rule ids are stable strings', () {
    expect(ApplePolicy.ruleSystemEdge, 'apple.system-edge');
    expect(ApplePolicy.ruleTabletop, 'apple.tabletop');
    expect(ApplePolicy.ruleBridgeNoEdge, 'apple.bridge-no-edge');
    expect(ApplePolicy.ruleFallback, 'apple.fallback');
  });

  test('system edge is never flipped in RTL', () {
    final s = _s(edge: NavEdge.left);
    expect(policy.resolve(s, TextDirection.rtl).edge, NavEdge.left);
    expect(policy.resolve(s, TextDirection.ltr).edge, NavEdge.left);
  });

  test('ruleId does not affect placement equality', () {
    expect(
      const NavPlacement(NavEdge.left, ruleId: 'a'),
      const NavPlacement(NavEdge.left, ruleId: 'b'),
    );
  });
}
