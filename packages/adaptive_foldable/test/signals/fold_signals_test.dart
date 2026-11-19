import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoldSignals enums', () {
    test('SizeClass has expected values', () {
      expect(
        SizeClass.values,
        containsAll([SizeClass.compact, SizeClass.regular, SizeClass.unknown]),
      );
    });

    test('Posture has expected values', () {
      expect(
        Posture.values,
        containsAll([
          Posture.closed,
          Posture.partiallyOpen,
          Posture.fullyOpen,
          Posture.unknown,
        ]),
      );
    });

    test('NavEdge has expected physical and logical values', () {
      expect(
        NavEdge.values,
        containsAll([
          NavEdge.bottom,
          NavEdge.leading,
          NavEdge.trailing,
          NavEdge.left,
          NavEdge.right,
        ]),
      );
    });
  });

  group('FoldSignalsSnapshot', () {
    test('default empty snapshot has expected defaults', () {
      final snapshot = FoldSignalsSnapshot();
      expect(snapshot.verticalBarEdge, isNull);
      expect(snapshot.horizontalSizeClass, SizeClass.unknown);
      expect(snapshot.verticalSizeClass, SizeClass.unknown);
      expect(snapshot.viewSize, Size.zero);
      expect(snapshot.activeFolds, isEmpty);
      expect(snapshot.occlusions, isEmpty);
      expect(snapshot.posture, Posture.unknown);
      expect(snapshot.isAvailable, isFalse);
      expect(snapshot.sdk271, isFalse);
    });

    test('const empty snapshot has expected defaults', () {
      const snapshot = FoldSignalsSnapshot.empty();
      expect(snapshot.verticalBarEdge, isNull);
      expect(snapshot.horizontalSizeClass, SizeClass.unknown);
      expect(snapshot.posture, Posture.unknown);
      expect(snapshot.isAvailable, isFalse);
      expect(snapshot.activeFolds, isEmpty);
      expect(snapshot.occlusions, isEmpty);
    });

    test('snapshot lists are immutable', () {
      final mutableFolds = [const Rect.fromLTWH(400, 0, 40, 800)];
      final mutableOcclusions = [const Rect.fromLTWH(0, 0, 100, 30)];
      final snapshot = FoldSignalsSnapshot(
        activeFolds: mutableFolds,
        occlusions: mutableOcclusions,
      );

      expect(
        () => (snapshot.activeFolds as dynamic).add(
          const Rect.fromLTWH(0, 0, 10, 10),
        ),
        throwsUnsupportedError,
      );
      expect(
        () => (snapshot.occlusions as dynamic).add(
          const Rect.fromLTWH(0, 0, 10, 10),
        ),
        throwsUnsupportedError,
      );
    });

    test('value equality and hashCode match for identical properties', () {
      final a = FoldSignalsSnapshot(
        verticalBarEdge: NavEdge.trailing,
        horizontalSizeClass: SizeClass.regular,
        verticalSizeClass: SizeClass.compact,
        viewSize: const Size(800, 600),
        activeFolds: const [Rect.fromLTWH(390, 0, 20, 600)],
        occlusions: const [Rect.fromLTWH(0, 0, 50, 50)],
        posture: Posture.partiallyOpen,
        isAvailable: true,
        sdk271: true,
      );

      final b = FoldSignalsSnapshot(
        verticalBarEdge: NavEdge.trailing,
        horizontalSizeClass: SizeClass.regular,
        verticalSizeClass: SizeClass.compact,
        viewSize: const Size(800, 600),
        activeFolds: const [Rect.fromLTWH(390, 0, 20, 600)],
        occlusions: const [Rect.fromLTWH(0, 0, 50, 50)],
        posture: Posture.partiallyOpen,
        isAvailable: true,
        sdk271: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('value equality fails when any property differs', () {
      final base = FoldSignalsSnapshot(
        verticalBarEdge: NavEdge.trailing,
        posture: Posture.partiallyOpen,
      );

      expect(
        base,
        isNot(equals(base.copyWith(verticalBarEdge: NavEdge.leading))),
      );
      expect(base, isNot(equals(base.copyWith(posture: Posture.fullyOpen))));
      expect(base, isNot(equals(base.copyWith(isAvailable: true))));
      expect(base, isNot(equals(base.copyWith(sdk271: true))));
    });

    test(
      'copyWith updates specified fields and clearVerticalBarEdge works',
      () {
        final initial = FoldSignalsSnapshot(
          verticalBarEdge: NavEdge.left,
          horizontalSizeClass: SizeClass.compact,
          posture: Posture.closed,
          isAvailable: true,
        );

        final updated = initial.copyWith(
          horizontalSizeClass: SizeClass.regular,
          posture: Posture.fullyOpen,
        );

        expect(updated.verticalBarEdge, NavEdge.left);
        expect(updated.horizontalSizeClass, SizeClass.regular);
        expect(updated.posture, Posture.fullyOpen);
        expect(updated.isAvailable, isTrue);

        final cleared = updated.copyWith(clearVerticalBarEdge: true);
        expect(cleared.verticalBarEdge, isNull);
      },
    );

    test('FoldSignalsSnapshot.from creates matching copy', () {
      final original = FoldSignalsSnapshot(
        verticalBarEdge: NavEdge.right,
        posture: Posture.partiallyOpen,
        isAvailable: true,
      );

      final copy = FoldSignalsSnapshot.from(original);
      expect(copy, equals(original));
    });

    test('listener methods on snapshot are no-ops', () {
      final snapshot = FoldSignalsSnapshot();
      void listener() {}
      snapshot.addListener(listener);
      snapshot.removeListener(listener);
      expect(snapshot, isNotNull);
    });

    test('toString contains meaningful representation', () {
      final snapshot = FoldSignalsSnapshot(
        verticalBarEdge: NavEdge.trailing,
        posture: Posture.partiallyOpen,
      );
      expect(
        snapshot.toString(),
        contains('verticalBarEdge: NavEdge.trailing'),
      );
      expect(snapshot.toString(), contains('posture: Posture.partiallyOpen'));
    });
  });
}
