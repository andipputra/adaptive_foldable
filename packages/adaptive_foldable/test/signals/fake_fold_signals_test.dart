import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FakeFoldSignals', () {
    test('initializes with default values', () {
      final fake = FakeFoldSignals();
      expect(fake.verticalBarEdge, isNull);
      expect(fake.horizontalSizeClass, SizeClass.unknown);
      expect(fake.verticalSizeClass, SizeClass.unknown);
      expect(fake.viewSize, Size.zero);
      expect(fake.activeFolds, isEmpty);
      expect(fake.occlusions, isEmpty);
      expect(fake.posture, Posture.unknown);
      expect(fake.isAvailable, isFalse);
      expect(fake.sdk271, isFalse);
    });

    test('initializes from preset', () {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);
      expect(fake.verticalBarEdge, NavEdge.right);
      expect(fake.posture, Posture.partiallyOpen);
      expect(fake.activeFolds.length, 1);
      expect(fake.activeFolds.first.width, 40.0);
      expect(fake.isAvailable, isTrue);
      expect(fake.sdk271, isTrue);
    });

    test('update notifies listeners once on value change', () {
      final fake = FakeFoldSignals(posture: Posture.closed);
      int notificationCount = 0;
      fake.addListener(() {
        notificationCount++;
      });

      fake.update(posture: Posture.partiallyOpen);
      expect(notificationCount, 1);
      expect(fake.posture, Posture.partiallyOpen);

      // Updating with same value should not notify
      fake.update(posture: Posture.partiallyOpen);
      expect(notificationCount, 1);

      // Updating different property notifies
      fake.update(verticalBarEdge: NavEdge.trailing);
      expect(notificationCount, 2);
      expect(fake.verticalBarEdge, NavEdge.trailing);

      // clearVerticalBarEdge clears edge and notifies
      fake.update(clearVerticalBarEdge: true);
      expect(notificationCount, 3);
      expect(fake.verticalBarEdge, isNull);
    });

    test('setSignals updates all values and notifies once', () {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.regularIphone);
      int notificationCount = 0;
      fake.addListener(() {
        notificationCount++;
      });

      fake.setSignals(FoldSignalsPresets.ipad);
      expect(notificationCount, 1);
      expect(fake.horizontalSizeClass, SizeClass.regular);
      expect(fake.viewSize, const Size(1024, 768));

      // Setting same signals does not notify
      fake.setSignals(FoldSignalsPresets.ipad);
      expect(notificationCount, 1);
    });
  });

  group('FoldSignalsPresets table-driven matrix', () {
    final matrix =
        <
          ({
            String name,
            FoldSignals preset,
            NavEdge? expectedEdge,
            SizeClass expectedHSize,
            SizeClass expectedVSize,
            Posture expectedPosture,
            bool hasActiveFold,
            bool expectedSdk271,
          })
        >[
          (
            name: 'duoCoverPortrait',
            preset: FoldSignalsPresets.duoCoverPortrait,
            expectedEdge: NavEdge.right,
            expectedHSize: SizeClass.compact,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.closed,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'duoCoverLandscape',
            preset: FoldSignalsPresets.duoCoverLandscape,
            expectedEdge: NavEdge.right,
            expectedHSize: SizeClass.compact,
            expectedVSize: SizeClass.compact,
            expectedPosture: Posture.closed,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'duoInnerPortrait',
            preset: FoldSignalsPresets.duoInnerPortrait,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'duoInnerLandscape',
            preset: FoldSignalsPresets.duoInnerLandscape,
            expectedEdge: NavEdge.right,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'duoBookPose',
            preset: FoldSignalsPresets.duoBookPose,
            expectedEdge: NavEdge.right,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.partiallyOpen,
            hasActiveFold: true,
            expectedSdk271: true,
          ),
          (
            name: 'duoSplitViewLeft',
            preset: FoldSignalsPresets.duoSplitViewLeft,
            expectedEdge: NavEdge.left,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'duoSplitViewRight',
            preset: FoldSignalsPresets.duoSplitViewRight,
            expectedEdge: NavEdge.right,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: true,
          ),
          (
            name: 'androidCompact',
            preset: FoldSignalsPresets.androidCompact,
            expectedEdge: null,
            expectedHSize: SizeClass.compact,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.unknown,
            hasActiveFold: false,
            expectedSdk271: false,
          ),
          (
            name: 'androidMedium',
            preset: FoldSignalsPresets.androidMedium,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: false,
          ),
          (
            name: 'androidExpanded',
            preset: FoldSignalsPresets.androidExpanded,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.fullyOpen,
            hasActiveFold: false,
            expectedSdk271: false,
          ),
          (
            name: 'androidBook',
            preset: FoldSignalsPresets.androidBook,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.partiallyOpen,
            hasActiveFold: true,
            expectedSdk271: false,
          ),
          (
            name: 'androidTabletop',
            preset: FoldSignalsPresets.androidTabletop,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.partiallyOpen,
            hasActiveFold: true,
            expectedSdk271: false,
          ),
          (
            name: 'regularIphone',
            preset: FoldSignalsPresets.regularIphone,
            expectedEdge: null,
            expectedHSize: SizeClass.compact,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.unknown,
            hasActiveFold: false,
            expectedSdk271: false,
          ),
          (
            name: 'ipad',
            preset: FoldSignalsPresets.ipad,
            expectedEdge: null,
            expectedHSize: SizeClass.regular,
            expectedVSize: SizeClass.regular,
            expectedPosture: Posture.unknown,
            hasActiveFold: false,
            expectedSdk271: false,
          ),
        ];

    test('verifies all 14 presets exist', () {
      expect(matrix.length, 14);
    });

    for (final entry in matrix) {
      test('preset: ${entry.name}', () {
        final p = entry.preset;
        expect(p.verticalBarEdge, entry.expectedEdge);
        expect(p.horizontalSizeClass, entry.expectedHSize);
        expect(p.verticalSizeClass, entry.expectedVSize);
        expect(p.posture, entry.expectedPosture);
        expect(p.activeFolds.isNotEmpty, entry.hasActiveFold);
        expect(p.sdk271, entry.expectedSdk271);
        expect(p.isAvailable, isTrue);
      });
    }
  });
}
