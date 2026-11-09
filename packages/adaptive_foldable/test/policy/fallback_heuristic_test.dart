import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/policy/fallback_heuristic.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fallbackBarEdge heuristic', () {
    test('returns bottom on zero size', () {
      final signals = FoldSignalsSnapshot(viewSize: Size.zero);
      expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.bottom);
      expect(fallbackBarEdge(signals, TextDirection.rtl), NavEdge.bottom);
    });

    test('Rule 1: regular width and taller than wide -> bottom bar', () {
      final signals = FoldSignalsSnapshot(
        horizontalSizeClass: SizeClass.regular,
        verticalSizeClass: SizeClass.regular,
        viewSize: const Size(669, 951),
      );
      expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.bottom);
      expect(fallbackBarEdge(signals, TextDirection.rtl), NavEdge.bottom);
    });

    test(
      'Rule 2: compact width with short wide aspect -> right edge default',
      () {
        final signals = FoldSignalsSnapshot(
          horizontalSizeClass: SizeClass.compact,
          verticalSizeClass: SizeClass.compact,
          viewSize: const Size(896, 414), // aspect > 1.6
        );
        expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.right);
        expect(fallbackBarEdge(signals, TextDirection.rtl), NavEdge.right);
      },
    );

    test('Rule 2 with camera on left -> places bar on right', () {
      final signals = FoldSignalsSnapshot(
        horizontalSizeClass: SizeClass.compact,
        verticalSizeClass: SizeClass.compact,
        viewSize: const Size(896, 414),
        occlusions: const [Rect.fromLTWH(50, 200, 30, 30)], // left side
      );
      expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.right);
    });

    test('Rule 2 with camera on right -> places bar on left', () {
      final signals = FoldSignalsSnapshot(
        horizontalSizeClass: SizeClass.compact,
        verticalSizeClass: SizeClass.compact,
        viewSize: const Size(896, 414),
        occlusions: const [Rect.fromLTWH(800, 200, 30, 30)], // right side
      );
      expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.left);
    });

    test('Rule 3: regular x regular and wider than tall -> right edge', () {
      final signals = FoldSignalsSnapshot(
        horizontalSizeClass: SizeClass.regular,
        verticalSizeClass: SizeClass.regular,
        viewSize: const Size(951, 669),
      );
      expect(fallbackBarEdge(signals, TextDirection.ltr), NavEdge.right);
      expect(fallbackBarEdge(signals, TextDirection.rtl), NavEdge.right);
    });

    test('Rule 4: otherwise -> bottom bar', () {
      final compactPortrait = FoldSignalsSnapshot(
        horizontalSizeClass: SizeClass.compact,
        verticalSizeClass: SizeClass.regular,
        viewSize: const Size(393, 852),
      );
      expect(
        fallbackBarEdge(compactPortrait, TextDirection.ltr),
        NavEdge.bottom,
      );
      expect(
        fallbackBarEdge(compactPortrait, TextDirection.rtl),
        NavEdge.bottom,
      );
    });

    group(
      'table-driven Duo configurations',
      () {
        test('Duo inner portrait -> bottom bar', () {
          // inner portrait: 669 x 951, regular x regular
          final s = FoldSignalsPresets.duoInnerPortrait.copyWith(
            clearVerticalBarEdge: true,
          );
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.bottom);
          expect(fallbackBarEdge(s, TextDirection.rtl), NavEdge.bottom);
        });

        test('Duo inner landscape -> side column (right)', () {
          // inner landscape: 951 x 669, regular x regular
          final s = FoldSignalsPresets.duoInnerLandscape.copyWith(
            clearVerticalBarEdge: true,
          );
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.right);
          expect(fallbackBarEdge(s, TextDirection.rtl), NavEdge.right);
        });

        test('Duo cover landscape -> side column (right)', () {
          // cover landscape: 896 x 414, compact x compact
          final s = FoldSignalsPresets.duoCoverLandscape.copyWith(
            clearVerticalBarEdge: true,
          );
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.right);
          expect(fallbackBarEdge(s, TextDirection.rtl), NavEdge.right);
        });

        test('Regular iPhone -> bottom bar', () {
          final s = FoldSignalsPresets.regularIphone;
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.bottom);
          expect(fallbackBarEdge(s, TextDirection.rtl), NavEdge.bottom);
        });

        test('iPad portrait -> bottom bar', () {
          final s = FoldSignalsPresets.ipad.copyWith(
            viewSize: const Size(768, 1024),
          );
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.bottom);
        });

        test('iPad landscape -> right column', () {
          final s = FoldSignalsPresets.ipad; // 1024 x 768, regular x regular
          expect(fallbackBarEdge(s, TextDirection.ltr), NavEdge.right);
        });
      },
    );
  });
}
