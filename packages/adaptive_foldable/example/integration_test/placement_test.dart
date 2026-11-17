import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bar placement matches the policy for the live signals', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(ExampleHomePage));
    final signals = FoldSignals.of(context);
    final policy = defaultTargetPlatform == TargetPlatform.iOS
        ? const ApplePolicy()
        : const MaterialPolicy();
    final expected = policy.resolve(signals, TextDirection.ltr);

    final home = tester.getTopLeft(find.text('Home').last);
    final size = signals.viewSize;
    debugPrint(
      'placement expected=${expected.edge.name} rule=${expected.ruleId}',
    );
    debugPrint('Home label at $home in view $size');
    debugPrint(formatSignalsReport(signals));

    if (expected.isVertical) {
      expect(home.dx, anyOf(lessThan(120), greaterThan(size.width - 140)));
    } else {
      expect(home.dy, greaterThan(size.height - 140));
    }
  });
}
