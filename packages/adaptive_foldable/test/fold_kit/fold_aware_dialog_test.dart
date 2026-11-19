import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const foldRect = Rect.fromLTWH(380, 0, 40, 600);

  group('showFoldAwareDialog', () {
    testWidgets('anchors to start pane when target is start', (tester) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [foldRect],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showFoldAwareDialog(
                        context: context,
                        target: FoldPaneTarget.start,
                        builder: (dialogCtx) => const AlertDialog(
                          key: ValueKey('dialog_start'),
                          title: Text('Start Dialog'),
                        ),
                      );
                    },
                    child: const Text('Open Start Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Start Dialog'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dialog_start')), findsOneWidget);
      final dialogRect = tester.getRect(
        find.byKey(const ValueKey('dialog_start')),
      );

      // Must be completely to the left of the fold (left < 380)
      expect(dialogRect.right, lessThanOrEqualTo(foldRect.left));
      expect(dialogRect.overlaps(foldRect), isFalse);
    });

    testWidgets('anchors to end pane when target is end', (tester) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [foldRect],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showFoldAwareDialog(
                        context: context,
                        target: FoldPaneTarget.end,
                        builder: (dialogCtx) => const AlertDialog(
                          key: ValueKey('dialog_end'),
                          title: Text('End Dialog'),
                        ),
                      );
                    },
                    child: const Text('Open End Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open End Dialog'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('dialog_end')), findsOneWidget);
      final dialogRect = tester.getRect(
        find.byKey(const ValueKey('dialog_end')),
      );

      // Must be completely to the right of the fold (right > 420)
      expect(dialogRect.left, greaterThanOrEqualTo(foldRect.right));
      expect(dialogRect.overlaps(foldRect), isFalse);
    });
  });

  group('showFoldAwareModalBottomSheet', () {
    testWidgets('anchors bottom sheet to start pane when target is start', (
      tester,
    ) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [foldRect],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showFoldAwareModalBottomSheet(
                        context: context,
                        target: FoldPaneTarget.start,
                        builder: (sheetCtx) => const SizedBox(
                          key: ValueKey('sheet_start'),
                          height: 200,
                          child: Text('Start Sheet'),
                        ),
                      );
                    },
                    child: const Text('Open Start Sheet'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Start Sheet'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sheet_start')), findsOneWidget);
      final sheetRect = tester.getRect(
        find.byKey(const ValueKey('sheet_start')),
      );

      // Must be strictly on the left of the fold
      expect(sheetRect.right, lessThanOrEqualTo(foldRect.left));
      expect(sheetRect.overlaps(foldRect), isFalse);
    });

    testWidgets('anchors bottom sheet to end pane when target is end', (
      tester,
    ) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [foldRect],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      showFoldAwareModalBottomSheet(
                        context: context,
                        target: FoldPaneTarget.end,
                        builder: (sheetCtx) => const SizedBox(
                          key: ValueKey('sheet_end'),
                          height: 200,
                          child: Text('End Sheet'),
                        ),
                      );
                    },
                    child: const Text('Open End Sheet'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open End Sheet'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('sheet_end')), findsOneWidget);
      final sheetRect = tester.getRect(find.byKey(const ValueKey('sheet_end')));

      // Must be strictly on the right of the fold
      expect(sheetRect.left, greaterThanOrEqualTo(foldRect.right));
      expect(sheetRect.overlaps(foldRect), isFalse);
    });

    testWidgets(
      'scaffold bar dims and ignores taps while dialog is open, restores on dismiss',
      (tester) async {
        final signals = FakeFoldSignals(
          viewSize: const Size(800, 600),
          activeFolds: const [foldRect],
          posture: Posture.partiallyOpen,
        );

        bool actionTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: FoldSignalsScope(
              override: signals,
              child: AdaptiveNavScaffold(
                destinations: const [
                  NavDestination(icon: Icons.home, label: 'Home'),
                ],
                selectedIndex: 0,
                onSelected: (_) {},
                body: AdaptiveNavActions(
                  prominentAction: NavAction(
                    icon: Icons.add,
                    label: 'Add',
                    onPressed: () => actionTapped = true,
                  ),
                  child: Builder(
                    builder: (context) => Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showFoldAwareDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Cover Dialog'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogCtx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Show Dialog'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Before dialog: bar is fully visible (opacity 1.0) and interactive
        expect(find.byIcon(Icons.add), findsOneWidget);
        await tester.tap(find.byIcon(Icons.add));
        expect(actionTapped, isTrue);

        // Open dialog
        actionTapped = false;
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Dialog is visible
        expect(find.text('Cover Dialog'), findsOneWidget);

        // The bar is wrapped in Opacity(0.4) and IgnorePointer(ignoring: true)
        final opacityWidget = tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byIcon(Icons.add),
                matching: find.byType(Opacity),
              )
              .first,
        );
        expect(opacityWidget.opacity, equals(0.4));

        // Attempting to tap the bar action should not fire callback
        await tester.tap(find.byIcon(Icons.add), warnIfMissed: false);
        expect(actionTapped, isFalse);

        // Close dialog
        await tester.tap(find.text('Close'), warnIfMissed: false);
        await tester.pumpAndSettle();

        // Restored: opacity back to 1.0 and interactive
        final restoredOpacity = tester.widget<Opacity>(
          find
              .ancestor(
                of: find.byIcon(Icons.add),
                matching: find.byType(Opacity),
              )
              .first,
        );
        expect(restoredOpacity.opacity, equals(1.0));

        await tester.tap(find.byIcon(Icons.add));
        expect(actionTapped, isTrue);
      },
    );
  });
}
