// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify example app renders the inbox with tabs', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Message 0'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);
  });
}
