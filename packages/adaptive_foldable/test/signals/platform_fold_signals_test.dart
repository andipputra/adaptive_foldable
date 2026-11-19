import 'dart:ui';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/android_fold_signals.dart';
import 'package:adaptive_foldable/src/signals/fold_sources_merger.dart';
import 'package:adaptive_foldable/src/signals/ios_fold_signals.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IosFoldSignals.decodePayload', () {
    test('decodes complete payload correctly', () {
      final payload = {
        'viewSize': {'width': 951.0, 'height': 669.0},
        'horizontalSizeClass': 'regular',
        'verticalSizeClass': 'regular',
        'verticalBarEdge': 'right',
        'activeFolds': [
          {'x': 455.5, 'y': 0.0, 'width': 40.0, 'height': 669.0},
        ],
        'occlusions': [
          {'x': 451.0, 'y': 0.0, 'width': 49.0, 'height': 25.0},
        ],
        'posture': 'partiallyOpen',
        'isAvailable': true,
        'sdk271': true,
      };

      final snapshot = IosFoldSignals.decodePayload(payload);
      expect(snapshot.viewSize, const Size(951, 669));
      expect(snapshot.horizontalSizeClass, SizeClass.regular);
      expect(snapshot.verticalSizeClass, SizeClass.regular);
      expect(snapshot.verticalBarEdge, NavEdge.right);
      expect(snapshot.posture, Posture.partiallyOpen);
      expect(snapshot.isAvailable, isTrue);
      expect(snapshot.sdk271, isTrue);
      expect(snapshot.activeFolds.length, 1);
      expect(
        snapshot.activeFolds.first,
        const Rect.fromLTWH(455.5, 0, 40, 669),
      );
      expect(snapshot.occlusions.length, 1);
      expect(snapshot.occlusions.first, const Rect.fromLTWH(451, 0, 49, 25));
    });

    test('handles null and empty payload with defaults', () {
      final snapshot = IosFoldSignals.decodePayload(null);
      expect(snapshot.viewSize, Size.zero);
      expect(snapshot.horizontalSizeClass, SizeClass.unknown);
      expect(snapshot.verticalBarEdge, isNull);
      expect(snapshot.activeFolds, isEmpty);
      expect(snapshot.isAvailable, isFalse);
    });

    test('empty payload decodes as unavailable', () {
      final snapshot = IosFoldSignals.decodePayload(const {});
      expect(snapshot.isAvailable, isFalse);
      expect(snapshot.sdk271, isFalse);
    });

    test('ignores non-numeric geometry instead of throwing', () {
      final snapshot = IosFoldSignals.decodePayload({
        'viewSize': {'width': 'wide', 'height': 669},
        'activeFolds': [
          {'x': 1, 'y': 0, 'width': '40', 'height': 669},
          {'x': 455.5, 'y': 0, 'width': 40, 'height': 669},
        ],
      });
      expect(snapshot.viewSize, const Size(0, 669));
      expect(snapshot.activeFolds, [const Rect.fromLTWH(455.5, 0, 40, 669)]);
    });

    test('maps unknown size class and posture to unknown', () {
      final snapshot = IosFoldSignals.decodePayload({
        'horizontalSizeClass': 'something_new',
        'verticalSizeClass': 'invalid',
        'posture': 'hovering',
      });
      expect(snapshot.horizontalSizeClass, SizeClass.unknown);
      expect(snapshot.verticalSizeClass, SizeClass.unknown);
      expect(snapshot.posture, Posture.unknown);
    });
  });

  group('mergeFoldSources (auto-defer logic)', () {
    test('when displayFeatures is empty, uses bridge folds and bar edge', () {
      final bridge = FoldSignalsPresets.duoBookPose;
      final merged = mergeFoldSources(
        bridge: bridge,
        displayFeatures: const [],
        viewSize: const Size(951, 669),
      );

      expect(merged.activeFolds, bridge.activeFolds);
      expect(merged.verticalBarEdge, NavEdge.right);
      expect(merged.posture, Posture.partiallyOpen);
    });

    test('when Flutter displayFeatures has fold, overrides bridge fold to avoid duplicate', () {
      final bridge = FoldSignalsPresets.duoBookPose;
      const flutterHinge = DisplayFeature(
        bounds: Rect.fromLTWH(450, 0, 42, 669),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      final merged = mergeFoldSources(
        bridge: bridge,
        displayFeatures: const [flutterHinge],
        viewSize: const Size(951, 669),
      );

      // Folds taken from Flutter
      expect(merged.activeFolds.length, 1);
      expect(merged.activeFolds.first, const Rect.fromLTWH(450, 0, 42, 669));
      // Bar edge remains bridged
      expect(merged.verticalBarEdge, NavEdge.right);
      expect(merged.posture, Posture.partiallyOpen);
    });

    test('Flutter fold feature with unknown state keeps bridge folds', () {
      final bridge = FoldSignalsPresets.duoBookPose;
      const unknownFold = DisplayFeature(
        bounds: Rect.fromLTWH(450, 0, 42, 669),
        type: DisplayFeatureType.fold,
        state: DisplayFeatureState.unknown,
      );

      final merged = mergeFoldSources(
        bridge: bridge,
        displayFeatures: const [unknownFold],
        viewSize: const Size(951, 669),
      );

      expect(merged.activeFolds, bridge.activeFolds);
      expect(merged.posture, bridge.posture);
    });

    test(
      'when Flutter displayFeature indicates flat posture, fold is cleared',
      () {
        final bridge = FoldSignalsPresets.duoBookPose;
        const flutterFlatHinge = DisplayFeature(
          bounds: Rect.fromLTWH(450, 0, 42, 669),
          type: DisplayFeatureType.hinge,
          state: DisplayFeatureState.postureFlat,
        );

        final merged = mergeFoldSources(
          bridge: bridge,
          displayFeatures: const [flutterFlatHinge],
          viewSize: const Size(951, 669),
        );

        expect(merged.activeFolds, isEmpty);
        expect(merged.posture, Posture.fullyOpen);
        expect(merged.verticalBarEdge, NavEdge.right);
      },
    );
  });

  group('AndroidFoldSignals', () {
    test('compact width (< 600 dp)', () {
      final s = AndroidFoldSignals.resolve(
        viewSize: const Size(412, 915),
        displayFeatures: const [],
      );
      expect(s.horizontalSizeClass, SizeClass.compact);
      expect(s.verticalSizeClass, SizeClass.regular);
      expect(s.verticalBarEdge, isNull);
      expect(s.posture, Posture.unknown);
      expect(s.activeFolds, isEmpty);
    });

    test('medium width (600 to 840 dp)', () {
      final s = AndroidFoldSignals.resolve(
        viewSize: const Size(700, 900),
        displayFeatures: const [],
      );
      expect(s.horizontalSizeClass, SizeClass.regular);
      expect(s.verticalSizeClass, SizeClass.regular);
      expect(s.verticalBarEdge, isNull);
    });

    test('expanded width (>= 840 dp)', () {
      final s = AndroidFoldSignals.resolve(
        viewSize: const Size(1000, 800),
        displayFeatures: const [],
      );
      expect(s.horizontalSizeClass, SizeClass.regular);
      expect(s.verticalSizeClass, SizeClass.regular);
    });

    test('book pose with vertical hinge', () {
      const hinge = DisplayFeature(
        bounds: Rect.fromLTWH(400, 0, 40, 800),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      final s = AndroidFoldSignals.resolve(
        viewSize: const Size(840, 800),
        displayFeatures: const [hinge],
      );

      expect(s.posture, Posture.partiallyOpen);
      expect(s.activeFolds.length, 1);
      expect(s.activeFolds.first, const Rect.fromLTWH(400, 0, 40, 800));
      expect(s.verticalBarEdge, isNull);
    });

    test('tabletop pose with horizontal hinge', () {
      const hinge = DisplayFeature(
        bounds: Rect.fromLTWH(0, 400, 800, 40),
        type: DisplayFeatureType.hinge,
        state: DisplayFeatureState.postureHalfOpened,
      );

      final s = AndroidFoldSignals.resolve(
        viewSize: const Size(800, 840),
        displayFeatures: const [hinge],
      );

      expect(s.posture, Posture.partiallyOpen);
      expect(s.activeFolds.length, 1);
      expect(s.activeFolds.first, const Rect.fromLTWH(0, 400, 800, 40));
    });
  });

  group('FoldSignalsScope widget tests', () {
    testWidgets('provides override signals via of and maybeOf', (tester) async {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);
      FoldSignals? resolved;

      await tester.pumpWidget(
        FoldSignalsScope(
          override: fake,
          child: Builder(
            builder: (context) {
              resolved = FoldSignals.of(context);
              return Container();
            },
          ),
        ),
      );

      expect(resolved, isNotNull);
      expect(resolved!.verticalBarEdge, NavEdge.right);
      expect(resolved!.posture, Posture.partiallyOpen);
    });

    testWidgets('maybeOf returns null when outside scope', (tester) async {
      FoldSignals? resolved;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolved = FoldSignals.maybeOf(context);
            return Container();
          },
        ),
      );
      expect(resolved, isNull);
    });

    testWidgets('of throws AssertionError when outside scope', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(() => FoldSignals.of(context), throwsAssertionError);
            return Container();
          },
        ),
      );
    });

    testWidgets(
      'dependents do NOT rebuild when snapshot values are unchanged',
      (tester) async {
        final fake = FakeFoldSignals.from(FoldSignalsPresets.duoCoverPortrait);
        int buildCount = 0;

        await tester.pumpWidget(
          FoldSignalsScope(
            override: fake,
            child: Builder(
              builder: (context) {
                FoldSignals.of(context);
                buildCount++;
                return Container();
              },
            ),
          ),
        );

        expect(buildCount, 1);

        // Notifying fake with identical values should NOT trigger rebuild of dependents
        fake.update(posture: Posture.closed);
        await tester.pump();
        expect(buildCount, 1);

        // Notifying fake with changed value DOES trigger rebuild
        fake.update(posture: Posture.fullyOpen);
        await tester.pump();
        expect(buildCount, 2);
      },
    );
  });
}
