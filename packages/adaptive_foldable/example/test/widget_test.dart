import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify example app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('Adaptive Foldable Example'), findsOneWidget);
  });
}
