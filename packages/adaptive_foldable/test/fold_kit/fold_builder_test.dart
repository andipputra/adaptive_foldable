import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoldBuilder', () {
    testWidgets('receives ambient fold signals and rebuilds on signal change', (
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
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: FoldBuilder(
              builder: (context, foldSignals) {
                return Text(
                  'Folds: ${foldSignals.activeFolds.length}, Posture: ${foldSignals.posture}',
                );
              },
            ),
          ),
        ),
      );

      expect(
        find.text('Folds: 1, Posture: Posture.partiallyOpen'),
        findsOneWidget,
      );

      signals.update(activeFolds: const [], posture: Posture.fullyOpen);
      await tester.pump();

      expect(find.text('Folds: 0, Posture: Posture.fullyOpen'), findsOneWidget);
    });

    testWidgets('throws assertion error when no FoldSignalsScope in context', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: FoldBuilder(
            builder: (context, foldSignals) => const SizedBox(),
          ),
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });
  });
}
