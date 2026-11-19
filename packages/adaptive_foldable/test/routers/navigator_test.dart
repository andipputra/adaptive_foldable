// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

NavAction act(String label) =>
    NavAction(icon: Icons.star, label: label, onPressed: () {});

Widget page(String name, List<String> actions, {Widget? next}) =>
    AdaptiveNavActions(
      groups: [
        NavActionGroup([for (final a in actions) act(a)]),
      ],
      child: Builder(
        builder: (context) => Column(
          children: [
            Text('page $name'),
            if (next != null)
              TextButton(
                onPressed: () =>
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(builder: (_) => next)),
                child: Text('open $name'),
              ),
          ],
        ),
      ),
    );

Future<void> pumpApp(WidgetTester tester, Widget body) async {
  final s = FakeFoldSignals(viewSize: const Size(400, 800), isAvailable: true);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (c, child) => FoldSignalsScope(override: s, child: child!),
      home: AdaptiveNavScaffold(
        destinations: const [NavDestination(icon: Icons.home, label: 'Alpha')],
        selectedIndex: 0,
        onSelected: (_) {},
        policy: const ApplePolicy(),
        body: body,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Widget nav(Widget first, {GlobalKey<NavigatorState>? key}) => Navigator(
  key: key,
  onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => first),
);

void main() {
  testWidgets('push and pop with plain Navigator', (tester) async {
    await pumpApp(tester, nav(page('1', ['One'], next: page('2', ['Two']))));
    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.text('open 1'));
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    expect(find.text('One'), findsNothing);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('two nested navigators: Back pops only the one it belongs to', (
    tester,
  ) async {
    final inner = GlobalKey<NavigatorState>();
    await pumpApp(
      tester,
      nav(
        Column(
          children: [
            const Text('outer root'),
            Expanded(
              child: nav(
                page('in1', ['Inner'], next: page('in2', ['Deep'])),
                key: inner,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.text('open in1'));
    await tester.pumpAndSettle();
    expect(find.text('Deep'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Inner'), findsOneWidget);
    expect(find.text('outer root'), findsOneWidget);
  });

  testWidgets('back swipe started and cancelled keeps actions stable', (
    tester,
  ) async {
    await pumpApp(tester, nav(page('1', ['One'], next: page('2', ['Two']))));
    await tester.tap(find.text('open 1'));
    await tester.pumpAndSettle();
    final g = await tester.startGesture(const Offset(2, 300));
    await g.moveBy(const Offset(40, 0));
    await tester.pump();
    await g.moveBy(const Offset(-40, 0));
    await g.up();
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hot reload style rebuild keeps one registration per page', (
    tester,
  ) async {
    await pumpApp(tester, nav(page('1', ['One'])));
    await tester.pumpWidget(tester.widget(find.byType(MaterialApp)));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
  });
}
