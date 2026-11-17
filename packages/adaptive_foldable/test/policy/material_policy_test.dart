import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter_test/flutter_test.dart';

FoldSignalsSnapshot _s(
  double width, {
  Posture posture = Posture.unknown,
  List<Rect> folds = const [],
}) => FoldSignalsSnapshot(
  viewSize: Size(width, 900),
  posture: posture,
  activeFolds: folds,
);

void main() {
  const policy = MaterialPolicy();

  final widthCases = <(double, NavEdge, String)>[
    (360, NavEdge.bottom, MaterialPolicy.ruleCompact),
    (599, NavEdge.bottom, MaterialPolicy.ruleCompact),
    (600, NavEdge.leading, MaterialPolicy.ruleMedium),
    (839, NavEdge.leading, MaterialPolicy.ruleMedium),
    (840, NavEdge.leading, MaterialPolicy.ruleExpanded),
    (1280, NavEdge.leading, MaterialPolicy.ruleExpanded),
  ];

  for (final (w, edge, rule) in widthCases) {
    for (final dir in TextDirection.values) {
      test('width $w dp (${dir.name}) -> $edge', () {
        final p = policy.resolve(_s(w), dir);
        expect(p.edge, edge);
        expect(p.ruleId, rule);
      });
    }
  }

  test('book pose (vertical hinge) -> leading rail even below 600 dp', () {
    final p = policy.resolve(
      _s(
        500,
        posture: Posture.partiallyOpen,
        folds: const [Rect.fromLTWH(245, 0, 10, 900)],
      ),
      TextDirection.ltr,
    );
    expect(p.edge, NavEdge.leading);
    expect(p.ruleId, MaterialPolicy.ruleBook);
  });

  test('tabletop pose (horizontal hinge) -> bottom even when expanded', () {
    final p = policy.resolve(
      _s(
        900,
        posture: Posture.partiallyOpen,
        folds: const [Rect.fromLTWH(0, 445, 900, 10)],
      ),
      TextDirection.ltr,
    );
    expect(p.edge, NavEdge.bottom);
    expect(p.ruleId, MaterialPolicy.ruleTabletop);
  });

  test('partially open without a reported fold falls back to width', () {
    final p = policy.resolve(
      _s(900, posture: Posture.partiallyOpen),
      TextDirection.ltr,
    );
    expect(p.ruleId, MaterialPolicy.ruleExpanded);
  });

  test('rule ids are stable strings', () {
    expect(MaterialPolicy.ruleTabletop, 'material.tabletop');
    expect(MaterialPolicy.ruleBook, 'material.book');
    expect(MaterialPolicy.ruleCompact, 'material.compact');
    expect(MaterialPolicy.ruleMedium, 'material.medium');
    expect(MaterialPolicy.ruleExpanded, 'material.expanded');
  });

  test('never returns a physical edge', () {
    for (final w in [300.0, 700.0, 1000.0]) {
      final e = policy.resolve(_s(w), TextDirection.rtl).edge;
      expect(e == NavEdge.left || e == NavEdge.right, isFalse);
    }
  });
}
