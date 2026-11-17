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
    expect(find.textContaining("Message 0"), findsOneWidget);
    expect(find.byType(FoldDebugOverlay), findsOneWidget);

    // Verify signals are available and readable through of(context)
    final BuildContext homeContext = tester.element(find.byType(InboxPage));
    final signals = FoldSignals.of(homeContext);

    expect(signals.isAvailable, isTrue);
    expect(signals.viewSize.width, greaterThan(0));
    expect(signals.horizontalSizeClass, isNot(SizeClass.unknown));
    expect(signals.verticalSizeClass, isNot(SizeClass.unknown));

    // Printed so the signal values can be recorded from a simulator or emulator run.
    debugPrint(formatSignalsReport(signals));
    debugPrint(
      'raw displayFeatures: '
      '${MediaQuery.of(homeContext).displayFeatures.map((f) => '${f.type}/${f.state}/${f.bounds}').toList()}',
    );

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Requires an Xcode 27.1+ build; older SDKs report false.
      expect(signals.sdk271, isTrue);
    }
  });
}
