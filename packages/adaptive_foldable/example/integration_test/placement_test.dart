import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tabs, detail, actions, overflow and Back on the live signals', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(InboxPage));
    final signals = FoldSignals.of(context);
    final policy = defaultTargetPlatform == TargetPlatform.iOS
        ? const ApplePolicy()
        : const MaterialPolicy();
    final expected = policy.resolve(signals, TextDirection.ltr);
    debugPrint(
      'placement expected=${expected.edge.name} rule=${expected.ruleId}',
    );
    debugPrint(formatSignalsReport(signals));

    final tab = tester.getTopLeft(find.text('Profile').last);
    final size = signals.viewSize;
    debugPrint('Profile tab at $tab in view $size');
    if (expected.isVertical) {
      expect(tab.dx, anyOf(lessThan(140), greaterThan(size.width - 160)));
    } else {
      expect(tab.dy, greaterThan(size.height - 160));
    }

    // Scroll, switch tabs and come back: the offset survives.
    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.textContaining('Message 5').first).dy;
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(
      find.text('Bar edge: ${signals.verticalBarEdge?.name ?? "none"}'),
      findsOneWidget,
    );
    await tester.tap(find.text('Inbox').last);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.textContaining('Message 5').first).dy,
      before,
    );

    // Open a detail page: its actions appear and Back is offered.
    await tester.tap(find.text('Message 5').first);
    await tester.pumpAndSettle();
    expect(find.text('Message body 5'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Reply'), findsOneWidget);
    debugPrint('detail actions visible: Reply, Back');

    // Overflow: the ellipsis appears when actions do not fit and opens a menu.
    if (find.text('More').evaluate().isNotEmpty) {
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Report'), findsOneWidget);
      debugPrint('overflow menu opened with Report');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
    } else {
      debugPrint('all actions fit; no overflow control');
    }

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Message 5'), findsOneWidget);
  });
}
