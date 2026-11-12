import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration harness: verifies signal stream and overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify main screen rendered with debug overlay
    expect(find.textContaining('Adaptive Foldable:'), findsOneWidget);
    expect(find.byType(FoldDebugOverlay), findsOneWidget);

    // Verify signals are available and readable through of(context)
    final BuildContext homeContext = tester.element(
      find.byType(ExampleHomePage),
    );
    final signals = FoldSignals.of(homeContext);

    expect(signals, isNotNull);
    expect(signals.horizontalSizeClass, isNotNull);
    expect(signals.verticalSizeClass, isNotNull);
    expect(signals.posture, isNotNull);
    expect(signals.isAvailable, isNotNull);

    // Printed so the signal values can be recorded from a simulator or emulator run.
    debugPrint('M0-011 REPORT\n${formatSignalsReport(signals)}');

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      expect(signals.isAvailable, isTrue);
      expect(signals.sdk271, isTrue);
      expect(signals.viewSize.width, greaterThan(0));
      expect(signals.horizontalSizeClass, isNot(SizeClass.unknown));
      expect(signals.verticalSizeClass, isNot(SizeClass.unknown));
    }
  });
}
