import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/layout/two_pane_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveTwoPaneDimensions', () {
    test('splits along active vertical fold', () {
      final dims = resolveTwoPaneDimensions(
        totalWidth: 800,
        totalHeight: 600,
        activeFolds: const [Rect.fromLTWH(380, 0, 40, 600)],
        startPaneProportion: 0.5,
        minStartPaneWidth: 280,
        minEndPaneWidth: 320,
        spacing: 0,
        showBoth: true,
        showStart: true,
      );

      expect(dims.isSplit, isTrue);
      expect(dims.startRect, equals(const Rect.fromLTWH(0, 0, 380, 600)));
      expect(dims.endRect, equals(const Rect.fromLTWH(420, 0, 380, 600)));
    });

    test('splits by proportion when width permits and no fold exists', () {
      final dims = resolveTwoPaneDimensions(
        totalWidth: 1000,
        totalHeight: 600,
        activeFolds: const [],
        startPaneProportion: 0.4,
        minStartPaneWidth: 280,
        minEndPaneWidth: 320,
        spacing: 16,
        showBoth: true,
        showStart: true,
      );

      expect(dims.isSplit, isTrue);
      // available = 1000 - 16 = 984. 984 * 0.4 = 393.6
      expect(dims.startRect.width, closeTo(393.6, 0.01));
      expect(dims.endRect.left, closeTo(393.6 + 16, 0.01));
      expect(dims.endRect.width, closeTo(984 - 393.6, 0.01));
    });

    test('respects minStartPaneWidth and minEndPaneWidth clamps', () {
      final dims = resolveTwoPaneDimensions(
        totalWidth: 700,
        totalHeight: 600,
        activeFolds: const [],
        startPaneProportion: 0.1, // wants 70, but min is 280
        minStartPaneWidth: 280,
        minEndPaneWidth: 320,
        spacing: 0,
        showBoth: true,
        showStart: true,
      );

      expect(dims.isSplit, isTrue);
      expect(dims.startRect.width, equals(280.0));
      expect(dims.endRect.left, equals(280.0));
      expect(dims.endRect.width, equals(420.0));
    });

    test('falls back to single pane when width too narrow', () {
      final dims = resolveTwoPaneDimensions(
        totalWidth: 500,
        totalHeight: 600,
        activeFolds: const [],
        startPaneProportion: 0.4,
        minStartPaneWidth: 280,
        minEndPaneWidth: 320,
        spacing: 0,
        showBoth: true,
        showStart: true,
      );

      expect(dims.isSplit, isFalse);
      expect(dims.startRect, equals(const Rect.fromLTWH(0, 0, 500, 600)));
      expect(dims.endRect, equals(Rect.zero));
    });
  });

  group('FoldAwareTwoPane widget', () {
    testWidgets('splits cleanly across vertical fold in book pose', (
      tester,
    ) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [Rect.fromLTWH(380, 0, 40, 600)],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        FoldSignalsScope(
          override: signals,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: FoldAwareTwoPane(
              start: Text('Start Content'),
              end: Text('End Content'),
            ),
          ),
        ),
      );

      expect(find.text('Start Content'), findsOneWidget);
      expect(find.text('End Content'), findsOneWidget);

      final startRect = tester.getRect(find.text('Start Content'));
      final endRect = tester.getRect(find.text('End Content'));

      // Verify no overlap with fold (380 to 420)
      expect(startRect.right, lessThanOrEqualTo(380));
      expect(endRect.left, greaterThanOrEqualTo(420));
    });

    testWidgets(
      'collapses to priority pane and preserves state across toggle',
      (tester) async {
        final signals = FakeFoldSignals(
          viewSize: const Size(400, 600),
          activeFolds: const [],
        );

        TwoPanePriority priority = TwoPanePriority.start;
        final textController = TextEditingController(text: 'Hello State');

        late StateSetter stateSetter;

        await tester.pumpWidget(
          MaterialApp(
            home: FoldSignalsScope(
              override: signals,
              child: StatefulBuilder(
                builder: (context, setter) {
                  stateSetter = setter;
                  return FoldAwareTwoPane(
                    priority: priority,
                    start: Scaffold(
                      body: TextField(
                        key: const ValueKey('start_field'),
                        controller: textController,
                      ),
                    ),
                    end: const Scaffold(body: Text('Detail View')),
                  );
                },
              ),
            ),
          ),
        );

        // Start pane is visible, end pane is offstage
        expect(find.byKey(const ValueKey('start_field')), findsOneWidget);
        expect(
          find.text('Detail View'),
          findsNothing,
        ); // Offstage hides from hit/render

        // Modify text field
        await tester.enterText(
          find.byKey(const ValueKey('start_field')),
          'Preserved Text',
        );
        expect(textController.text, equals('Preserved Text'));

        // Switch priority to end
        stateSetter(() {
          priority = TwoPanePriority.end;
        });
        await tester.pumpAndSettle();

        // Now end is visible, start is offstage
        expect(find.text('Detail View'), findsOneWidget);
        expect(find.byKey(const ValueKey('start_field')), findsNothing);

        // Switch priority back to start
        stateSetter(() {
          priority = TwoPanePriority.start;
        });
        await tester.pumpAndSettle();

        // Start is visible again and preserved its text!
        expect(find.byKey(const ValueKey('start_field')), findsOneWidget);
        expect(textController.text, equals('Preserved Text'));
      },
    );

    testWidgets('mirrors layout under RTL text direction', (tester) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [Rect.fromLTWH(380, 0, 40, 600)],
      );

      await tester.pumpWidget(
        FoldSignalsScope(
          override: signals,
          child: const Directionality(
            textDirection: TextDirection.rtl,
            child: FoldAwareTwoPane(
              start: Text('Start RTL'),
              end: Text('End RTL'),
            ),
          ),
        ),
      );

      final startPos = tester.getTopLeft(find.text('Start RTL'));
      final endPos = tester.getTopLeft(find.text('End RTL'));

      // In RTL, start is placed on the trailing side (right), end on leading side (left)
      expect(startPos.dx, greaterThan(endPos.dx));
    });
  });
}
