// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app({required bool sheet}) {
    var endTaps = 0;
    return MaterialApp(
      home: FoldSignalsScope(
        override: FakeFoldSignals(viewSize: const Size(1000, 600)),
        child: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: FoldAwareTwoPane(
              priority: TwoPanePriority.both,
              start: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    onPressed: () => sheet
                        ? showFoldAwareModalBottomSheet<void>(
                            context: ctx,
                            builder: (c) => TextButton(
                              onPressed: () => closeFoldAwareModal(c),
                              child: const Text('Close'),
                            ),
                          )
                        : showFoldAwareDialog<void>(
                            context: ctx,
                            builder: (c) => AlertDialog(
                              title: const Text('Pane Dialog'),
                              actions: [
                                TextButton(
                                  onPressed: () => closeFoldAwareModal(c),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          ),
                    child: const Text('Open'),
                  ),
                ),
              ),
              end: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => endTaps++),
                  child: Text('End taps $endTaps'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final sheet in [false, true]) {
    testWidgets('${sheet ? 'sheet' : 'dialog'} stays in its pane', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1000, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(app(sheet: sheet));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      final modal = find.text(sheet ? 'Close' : 'Pane Dialog');
      expect(modal, findsOneWidget);

      final endRect = tester.getRect(find.byType(ElevatedButton).last);
      final modalRect = tester.getRect(modal);
      expect(modalRect.right, lessThan(endRect.left));

      // The other pane is not covered by the barrier.
      await tester.tap(find.textContaining('End taps'));
      await tester.pump();
      expect(find.text('End taps 1'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Close'), findsNothing);
    });
  }
}
