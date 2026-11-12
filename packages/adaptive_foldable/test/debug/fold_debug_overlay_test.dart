import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatSignalsReport', () {
    test('formats signals report with all fields and custom rule', () {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);
      final report = formatSignalsReport(fake, ruleLabel: 'DuoBookPoseRule');

      expect(report, contains('adaptive_foldable signals:'));
      expect(report, contains('viewSize: 951.0 x 669.0'));
      expect(report, contains('horizontalSizeClass: regular'));
      expect(report, contains('verticalSizeClass: regular'));
      expect(report, contains('verticalBarEdge: right'));
      expect(report, contains('posture: partiallyOpen'));
      expect(
        report,
        contains('activeFolds: [Rect.fromLTRB(455.5, 0.0, 495.5, 669.0)]'),
      );
      expect(
        report,
        contains('occlusions: [Rect.fromLTRB(867.0, 0.0, 951.0, 124.0)]'),
      );
      expect(report, contains('sdk271: true'));
      expect(report, contains('isAvailable: true'));
      expect(report, contains('rule: DuoBookPoseRule'));
    });
  });

  group('FoldDebugOverlay widget', () {
    testWidgets('renders child content and passes taps through IgnorePointer', (
      tester,
    ) async {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);
      int tapCount = 0;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FoldSignalsScope(
            override: fake,
            child: FoldDebugOverlay(
              isDebugMode: true,
              enabled: true,
              ruleLabel: 'TestRule',
              child: GestureDetector(
                onTap: () {
                  tapCount++;
                },
                child: const SizedBox(
                  width: 200,
                  height: 200,
                  child: Text('Tap Target'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Tap Target'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify tap passes through overlay without pointer interception
      await tester.tap(find.text('Tap Target'));
      await tester.pump();
      expect(tapCount, 1);
    });

    testWidgets(
      'when isDebugMode is false, returns child directly without overlay',
      (tester) async {
        final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: FoldSignalsScope(
              override: fake,
              child: const FoldDebugOverlay(
                isDebugMode: false,
                enabled: true,
                child: Text('Production Content'),
              ),
            ),
          ),
        );

        expect(find.text('Production Content'), findsOneWidget);
        expect(find.byType(CustomPaint), findsNothing);
      },
    );

    testWidgets('when enabled is false, returns child directly', (
      tester,
    ) async {
      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FoldSignalsScope(
            override: fake,
            child: const FoldDebugOverlay(
              isDebugMode: true,
              enabled: false,
              child: Text('Disabled Overlay'),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Overlay'), findsOneWidget);
      expect(find.byType(CustomPaint), findsNothing);
    });
  });
}
