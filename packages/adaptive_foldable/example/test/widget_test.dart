// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Start page offers native and default bars', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Native'), findsOneWidget);
    await tester.tap(find.text('Native'));
    await tester.pumpAndSettle();
    expect(find.text('Message 0'), findsOneWidget);
  });

  testWidgets('Verify example app renders the inbox with tabs', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    expect(find.text('Message 0'), findsOneWidget);
    expect(find.text('Two-Pane'), findsWidgets);
    expect(find.text('Grid'), findsWidgets);
    expect(find.text('Modals'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });

  testWidgets('Navigate to Two-Pane tab displays documents', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Two-Pane').last);
    await tester.pumpAndSettle();

    expect(find.byType(FoldAwareTwoPane), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Technical Design Overview'), findsWidgets);
  });

  testWidgets('Navigate to Grid tab displays grid items', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grid').last);
    await tester.pumpAndSettle();

    expect(find.text('Fold-Aligned Grid'), findsOneWidget);
    expect(find.text('Item 1'), findsOneWidget);
  });

  testWidgets('Navigate to Modals tab displays presentation buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modals').last);
    await tester.pumpAndSettle();

    // Two panes, each with its own set of presentation rows.
    expect(find.text('Fold-aware dialogs'), findsNWidgets(2));
    expect(find.text('Dialog: Auto anchor'), findsNWidgets(2));
    expect(find.text('Sheet: Auto anchor'), findsNWidgets(2));
  });

  testWidgets('Dialog opened in start pane leaves end pane tappable', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Default'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modals').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dialog: Auto anchor').first);
    await tester.pumpAndSettle();
    expect(find.text('Anchored dialog (auto)'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    final probe = find.text('Tap me while a modal is open').last;
    await tester.tap(probe);
    await tester.pump();
    expect(find.text('Taps in End pane: 1'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.text('Anchored dialog (auto)'), findsNothing);
  });
}
