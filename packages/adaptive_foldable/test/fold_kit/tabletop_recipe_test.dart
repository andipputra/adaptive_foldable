import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The README tabletop recipe: content above a horizontal hinge, controls below.
Widget _tabletop() => FoldBuilder(
  builder: (context, signals) {
    final hinge = signals.activeFolds
        .where((r) => r.width > r.height)
        .firstOrNull;
    if (hinge == null) return const SizedBox.expand(key: ValueKey('full'));
    return Column(
      children: [
        SizedBox(
          height: hinge.top,
          child: const SizedBox.expand(key: ValueKey('content')),
        ),
        SizedBox(height: hinge.height),
        const Expanded(child: SizedBox.expand(key: ValueKey('controls'))),
      ],
    );
  },
);

void main() {
  testWidgets('content stays above the hinge and controls below it', (
    tester,
  ) async {
    final signals = FakeFoldSignals.from(FoldSignalsPresets.androidTabletop);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = signals.viewSize;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FoldSignalsScope(override: signals, child: _tabletop()),
      ),
    );
    final hinge = signals.activeFolds.single;
    final content = tester.getRect(find.byKey(const ValueKey('content')));
    final controls = tester.getRect(find.byKey(const ValueKey('controls')));
    expect(content.bottom, hinge.top);
    expect(controls.top, hinge.bottom);
    expect(content.overlaps(hinge), isFalse);
    expect(controls.overlaps(hinge), isFalse);
  });
  testWidgets('without a hinge the recipe shows the full-screen content', (
    tester,
  ) async {
    final signals = FakeFoldSignals(viewSize: const Size(800, 840));
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = signals.viewSize;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FoldSignalsScope(override: signals, child: _tabletop()),
      ),
    );
    expect(find.byKey(const ValueKey('full')), findsOneWidget);
    expect(find.byKey(const ValueKey('controls')), findsNothing);
  });
}
