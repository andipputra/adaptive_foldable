import 'dart:math' as math;
import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter_test/flutter_test.dart';

FoldSignalsSnapshot _s(
  Size size, {
  List<Rect> folds = const [],
  List<Rect> occlusions = const [],
}) => FoldSignalsSnapshot(
  viewSize: size,
  activeFolds: folds,
  occlusions: occlusions,
);

NavGeometry _g(
  NavEdge edge,
  FoldSignalsSnapshot s, {
  NavInsets pad = NavInsets.zero,
  TextDirection dir = TextDirection.ltr,
}) => resolveGeometry(
  placement: NavPlacement(edge),
  signals: s,
  viewPadding: pad,
  direction: dir,
);

void main() {
  group('bottom bar', () {
    test('spans width with thickness plus home indicator', () {
      final g = _g(
        NavEdge.bottom,
        _s(const Size(393, 852)),
        pad: const NavInsets(bottom: 34),
      );
      expect(g.barRect, const Rect.fromLTRB(0, 852 - 56 - 34, 393, 852));
      expect(g.itemAxis, NavAxis.horizontal);
      expect(g.homeIndicatorGap, 34);
      expect(g.skipRegion, isNull);
      expect(g.foldClearance, 0);
    });

    test('vertical fold cuts the bar to the larger side', () {
      final g = _g(
        NavEdge.bottom,
        _s(
          const Size(1000, 600),
          folds: const [Rect.fromLTWH(600, 0, 10, 600)],
        ),
      );
      expect(g.barRect.right, 600 - kFoldClearance);
      expect(g.barRect.left, 0);
      expect(g.foldClearance, kFoldClearance);
    });
  });

  group('side column', () {
    test('Duo cover landscape: starts below camera occlusion', () {
      final g = _g(
        NavEdge.right,
        _s(
          const Size(678, 466),
          occlusions: const [Rect.fromLTWH(560, 0, 100, 40)],
        ),
        pad: const NavInsets(top: 20),
      );
      expect(g.barRect.top, 40);
      expect(g.barRect.right, 678);
      expect(g.barRect.width, kSideBarThickness);
      expect(g.skipRegion, isNotNull);
      expect(g.skipRegion!.bottom, 40);
      expect(g.itemAxis, NavAxis.vertical);
    });

    test('occlusion away from the column is ignored', () {
      final g = _g(
        NavEdge.right,
        _s(
          const Size(678, 466),
          occlusions: const [Rect.fromLTWH(100, 0, 100, 40)],
        ),
      );
      expect(g.barRect.top, 0);
      expect(g.skipRegion, isNull);
    });

    test('status inset alone sets the skip region', () {
      final g = _g(
        NavEdge.left,
        _s(const Size(800, 400)),
        pad: const NavInsets(top: 24, left: 44),
      );
      expect(g.barRect.top, 24);
      expect(g.barRect.width, kSideBarThickness + 44);
    });

    test('logical edges flip with direction, physical edges do not', () {
      final s = _s(const Size(900, 600));
      expect(_g(NavEdge.leading, s).barRect.left, 0);
      expect(_g(NavEdge.leading, s, dir: TextDirection.rtl).barRect.right, 900);
      expect(_g(NavEdge.trailing, s).barRect.right, 900);
      expect(_g(NavEdge.left, s, dir: TextDirection.rtl).barRect.left, 0);
      expect(_g(NavEdge.right, s, dir: TextDirection.rtl).barRect.right, 900);
    });

    test('home indicator gap shortens the column', () {
      final g = _g(
        NavEdge.left,
        _s(const Size(800, 400)),
        pad: const NavInsets(bottom: 20),
      );
      expect(g.barRect.bottom, 380);
      expect(g.homeIndicatorGap, 20);
    });

    test('horizontal fold across the column cuts it to the larger part', () {
      final g = _g(
        NavEdge.left,
        _s(const Size(669, 951), folds: const [Rect.fromLTWH(0, 600, 669, 10)]),
      );
      expect(g.barRect.bottom, 600 - kFoldClearance);
      expect(g.barRect.top, 0);
    });
  });

  test('fold overlap property holds for 1000 generated cases', () {
    final rnd = math.Random(42);
    const size = Size(900, 700);
    final edges = NavEdge.values;
    for (var i = 0; i < 1000; i++) {
      final vertical = rnd.nextBool();
      final thick = 2 + rnd.nextDouble() * 30;
      final pos = rnd.nextDouble() * (vertical ? size.width : size.height);
      final fold = vertical
          ? Rect.fromLTWH(pos, 0, thick, size.height)
          : Rect.fromLTWH(0, pos, size.width, thick);
      final edge = edges[rnd.nextInt(edges.length)];
      final g = _g(
        edge,
        _s(size, folds: [fold]),
        pad: NavInsets(
          top: rnd.nextDouble() * 40,
          bottom: rnd.nextDouble() * 34,
          left: rnd.nextDouble() * 40,
          right: rnd.nextDouble() * 40,
        ),
        dir: rnd.nextBool() ? TextDirection.ltr : TextDirection.rtl,
      );
      expect(
        g.barRect.overlaps(fold),
        isFalse,
        reason: 'edge $edge fold $fold bar ${g.barRect}',
      );
    }
  });
}
