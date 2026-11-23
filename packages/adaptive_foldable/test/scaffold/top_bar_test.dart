// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _dests = [
  NavDestination(icon: Icons.home_outlined, label: 'Home'),
  NavDestination(icon: Icons.inbox_outlined, label: 'Inbox'),
];

Future<void> _pump(
  WidgetTester tester,
  FakeFoldSignals signals, {
  bool atTop = true,
  NavBarStyle barStyle = const NavBarStyle(),
  NavBarStyle topStyle = const NavBarStyle(),
  NavBarBuilder? topBarBuilder,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = signals.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(size: signals.viewSize),
        child: FoldSignalsScope(override: signals, child: child!),
      ),
      home: AdaptiveNavScaffold(
        destinations: _dests,
        selectedIndex: 0,
        onSelected: (_) {},
        policy: const ApplePolicy(),
        barBuilder: materialBarBuilder,
        actionsAtTop: atTop,
        barStyle: barStyle,
        topBarStyle: topStyle,
        topBarBuilder: topBarBuilder,
        body: AdaptiveNavActions(
          prominentAction: NavAction(
            icon: Icons.add,
            label: 'Compose',
            onPressed: () {},
          ),
          groups: [
            NavActionGroup([
              NavAction(icon: Icons.search, label: 'Search', onPressed: () {}),
            ]),
          ],
          child: Builder(
            builder: (context) => Text(
              '${MediaQuery.paddingOf(context)}',
              key: const Key('body'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

FakeFoldSignals _sig([Size size = const Size(400, 800)]) =>
    FakeFoldSignals(viewSize: size, isAvailable: true);

void main() {
  testWidgets('actions draw at the top, tabs at the bottom', (tester) async {
    await _pump(tester, _sig());
    final search = tester.getRect(find.text('Search').first);
    final tab = tester.getRect(find.text('Home').first);
    expect(search.top, lessThan(100));
    expect(tab.top, greaterThan(700));
  });

  testWidgets('body is inset below the top bar', (tester) async {
    await _pump(tester, _sig());
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 52);
  });

  testWidgets('actionsAtTop false keeps actions out of the top', (
    tester,
  ) async {
    await _pump(tester, _sig(), atTop: false);
    expect(find.text('Search'), findsOneWidget);
    expect(tester.getRect(find.text('Search').first).top, greaterThan(700));
  });

  testWidgets('topBarStyle height sets the inset', (tester) async {
    await _pump(tester, _sig(), topStyle: const NavBarStyle(height: 80));
    expect(tester.getTopLeft(find.byKey(const Key('body'))).dy, 80);
  });

  testWidgets('itemSpacing widens the gap between top actions', (tester) async {
    await _pump(tester, _sig());
    double gap() {
      final a = tester.getRect(find.text('Compose').first);
      final b = tester.getRect(find.text('Search').first);
      return (b.left - a.right).abs();
    }

    final base = gap();
    await _pump(tester, _sig(), topStyle: const NavBarStyle(itemSpacing: 24));
    expect(gap(), base + 24);
  });

  testWidgets('custom topBarBuilder replaces the default', (tester) async {
    await _pump(
      tester,
      _sig(),
      topBarBuilder: (context, layout) =>
          Text('custom ${layout.headerActions.length}'),
    );
    expect(find.text('custom 1'), findsOneWidget);
  });

  testWidgets('bottom bar style height and alignment apply', (tester) async {
    await _pump(
      tester,
      _sig(),
      barStyle: const NavBarStyle(
        height: 80,
        alignment: NavBarAlignment.center,
      ),
    );
    final bar = tester.getRect(
      find.byType(NavTopBar).evaluate().isEmpty
          ? find.byType(MaterialNavBar)
          : find.byType(MaterialNavBar),
    );
    expect(bar.height, 80);
  });

  test('top bar is cut around an active fold', () {
    final g = resolveGeometry(
      placement: const NavPlacement(NavEdge.bottom),
      signals: FoldSignalsSnapshot(
        viewSize: const Size(800, 600),
        activeFolds: const [Rect.fromLTWH(396, 0, 8, 600)],
      ),
      topBarHeight: 52,
    );
    expect(
      g.topBarRect!.overlaps(const Rect.fromLTWH(396, 0, 8, 600)),
      isFalse,
    );
  });
}
