// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _dests = [
  NavDestination(icon: Icons.home_outlined, label: 'Home'),
  NavDestination(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 7),
];

Future<void> _pump(
  WidgetTester tester,
  FakeFoldSignals signals, {
  NavLayoutChanged? onLayoutChanged,
  NavTransitions transitions = const NavTransitions(),
  bool extend = false,
  bool disableAnimations = false,
  NavPlacementPolicy policy = const ApplePolicy(),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = signals.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          size: signals.viewSize,
        ),
        child: FoldSignalsScope(override: signals, child: child!),
      ),
      home: AdaptiveNavScaffold(
        sideBarThickness: 80,
        destinations: _dests,
        selectedIndex: 0,
        onSelected: (_) {},
        policy: policy,
        barBuilder: materialBarBuilder,
        onLayoutChanged: onLayoutChanged,
        transitions: transitions,
        extendBodyBehindBar: extend,
        body: Builder(
          builder: (context) => ColoredBox(
            key: const Key('body'),
            color: Colors.white,
            child: Text('${MediaQuery.paddingOf(context)}'),
          ),
        ),
      ),
    ),
  );
}

FakeFoldSignals _sig({
  Size size = const Size(669, 951),
  NavEdge? edge,
  Posture posture = Posture.fullyOpen,
}) => FakeFoldSignals(
  viewSize: size,
  verticalBarEdge: edge,
  posture: posture,
  isAvailable: true,
);

void main() {
  group('onLayoutChanged', () {
    testWidgets('rebuild without change fires nothing', (tester) async {
      final calls = <NavLayout>[];
      final s = _sig();
      await _pump(tester, s, onLayoutChanged: (p, n) => calls.add(n));
      await tester.pump(const Duration(seconds: 1));
      s.update(occlusions: const [Rect.fromLTWH(0, 0, 10, 10)]);
      await tester.pump(const Duration(seconds: 1));
      expect(calls, isEmpty);
    });

    testWidgets('fold with region jitter fires exactly once', (tester) async {
      final calls = <(NavLayout, NavLayout)>[];
      final s = _sig();
      await _pump(tester, s, onLayoutChanged: (p, n) => calls.add((p, n)));
      s.update(posture: Posture.partiallyOpen, verticalBarEdge: NavEdge.right);
      await tester.pump(const Duration(milliseconds: 50));
      s.update(verticalBarEdge: NavEdge.left);
      await tester.pump(const Duration(milliseconds: 50));
      s.update(verticalBarEdge: NavEdge.right);
      await tester.pump(const Duration(milliseconds: 100));
      expect(calls, isEmpty);
      await tester.pump(kLayoutSettleDelay);
      expect(calls, hasLength(1));
      expect(calls.single.$1.placement.edge, NavEdge.bottom);
      expect(calls.single.$2.placement.edge, NavEdge.right);
      expect(calls.single.$2.posture, Posture.partiallyOpen);
      await tester.pump(const Duration(seconds: 1));
      expect(calls, hasLength(1));
    });

    testWidgets('change that reverts before settling fires nothing', (
      tester,
    ) async {
      final calls = <NavLayout>[];
      final s = _sig();
      await _pump(tester, s, onLayoutChanged: (p, n) => calls.add(n));
      s.update(verticalBarEdge: NavEdge.right);
      await tester.pump(const Duration(milliseconds: 50));
      s.update(clearVerticalBarEdge: true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(calls, isEmpty);
    });

    testWidgets('rotation fires one event', (tester) async {
      final calls = <NavLayout>[];
      final s = _sig(edge: null, size: const Size(400, 800));
      await _pump(
        tester,
        s,
        onLayoutChanged: (p, n) => calls.add(n),
        policy: const MaterialPolicy(),
      );
      s.update(viewSize: const Size(900, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(calls, hasLength(1));
      expect(calls.single.placement.edge, NavEdge.leading);
    });
  });

  group('transitions', () {
    double barOpacity(WidgetTester tester) => tester
        .widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(MaterialNavBar),
                matching: find.byType(FadeTransition),
              )
              .first,
        )
        .opacity
        .value;

    testWidgets('fold change is instant by default', (tester) async {
      final s = _sig();
      await _pump(tester, s);
      s.update(posture: Posture.partiallyOpen, verticalBarEdge: NavEdge.right);
      await tester.pump();
      expect(barOpacity(tester), 1);
    });

    testWidgets('resize crossfades over the configured duration', (
      tester,
    ) async {
      final s = _sig(size: const Size(400, 800));
      await _pump(tester, s, policy: const MaterialPolicy());
      s.update(viewSize: const Size(900, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      expect(barOpacity(tester), lessThan(1));
      await tester.pump(const Duration(milliseconds: 100));
      expect(barOpacity(tester), inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 150));
      expect(barOpacity(tester), 1);
    });

    testWidgets('Reduce Motion forces instant', (tester) async {
      final s = _sig(size: const Size(400, 800));
      await _pump(
        tester,
        s,
        disableAnimations: true,
        policy: const MaterialPolicy(),
      );
      s.update(viewSize: const Size(900, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      expect(barOpacity(tester), 1);
    });

    testWidgets('respectReduceMotion false keeps the crossfade', (
      tester,
    ) async {
      final s = _sig(size: const Size(400, 800));
      await _pump(
        tester,
        s,
        disableAnimations: true,
        transitions: const NavTransitions(respectReduceMotion: false),
        policy: const MaterialPolicy(),
      );
      s.update(viewSize: const Size(900, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      expect(barOpacity(tester), lessThan(1));
      await tester.pumpAndSettle();
    });

    testWidgets('overriding onFoldChange to crossfade fades on fold', (
      tester,
    ) async {
      final s = _sig();
      await _pump(
        tester,
        s,
        transitions: const NavTransitions(
          onFoldChange: NavTransition.crossfade,
        ),
      );
      s.update(posture: Posture.partiallyOpen, verticalBarEdge: NavEdge.right);
      await tester.pump();
      expect(barOpacity(tester), lessThan(1));
      await tester.pumpAndSettle();
    });

    test('defaults match the design', () {
      const t = NavTransitions();
      expect(t.onFoldChange, NavTransition.instant);
      expect(t.onResize, NavTransition.crossfade);
      expect(t.duration, const Duration(milliseconds: 200));
      expect(t.respectReduceMotion, isTrue);
    });
  });

  group('extendBodyBehindBar', () {
    testWidgets('body covers the column, padding still clears it', (
      tester,
    ) async {
      final s = _sig(edge: NavEdge.left, size: const Size(951, 669));
      await _pump(tester, s);
      final clipped = tester.getRect(find.byKey(const Key('body')));
      expect(clipped.left, greaterThan(0));
      final paddingText = tester.widget<Text>(
        find.textContaining('EdgeInsets'),
      );
      expect(paddingText.data, 'EdgeInsets.zero');

      await _pump(tester, s, extend: true);
      await tester.pump();
      final extended = tester.getRect(find.byKey(const Key('body')));
      expect(extended.left, 0);
      expect(find.textContaining('80.0'), findsOneWidget);
    });

    testWidgets('bottom bar is unaffected', (tester) async {
      final s = _sig();
      await _pump(tester, s, extend: true);
      expect(
        tester.getRect(find.byKey(const Key('body'))).bottom,
        lessThan(951),
      );
    });

    testWidgets('does not extend under a fold-cut bar', (tester) async {
      final s = FakeFoldSignals(
        viewSize: const Size(951, 669),
        verticalBarEdge: NavEdge.left,
        posture: Posture.partiallyOpen,
        activeFolds: const [Rect.fromLTWH(30, 0, 10, 669)],
        isAvailable: true,
      );
      await _pump(tester, s, extend: true);
      expect(
        tester.getRect(find.byKey(const Key('body'))).left,
        greaterThan(0),
      );
    });
  });

  group('migration helper', () {
    test('converts Icon widgets', () {
      final d = navDestinationFromIcons(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: 'Home',
        badgeCount: 2,
      );
      expect(d.icon, Icons.home_outlined);
      expect(d.selectedIcon, Icons.home);
      expect(d.label, 'Home');
      expect(d.badgeCount, 2);
      expect(
        navDestinationFromIcons(
          icon: const Icon(Icons.inbox),
          label: 'I',
        ).selectedIcon,
        isNull,
      );
    });

    test('converts the fields of real Material destinations', () {
      const nd = NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      );
      final d = navDestinationFromIcons(
        icon: nd.icon,
        selectedIcon: nd.selectedIcon,
        label: nd.label,
      );
      expect(d.selectedIcon, Icons.home);
      const bi = BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      );
      expect(
        navDestinationFromIcons(
          icon: bi.icon,
          selectedIcon: bi.activeIcon,
          label: bi.label!,
        ).icon,
        Icons.home_outlined,
      );
    });

    test('non-Icon widgets are rejected', () {
      expect(
        () => navDestinationFromIcons(icon: const SizedBox(), label: 'X'),
        throwsArgumentError,
      );
    });

    test('empty labels are rejected', () {
      expect(
        () => navDestinationFromIcons(icon: const Icon(Icons.home), label: ''),
        throwsArgumentError,
      );
    });
  });

  group('review regressions', () {
    testWidgets('null barBuilder draws the platform default bar', (
      tester,
    ) async {
      final s = _sig(size: const Size(400, 800));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = s.viewSize;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => FoldSignalsScope(override: s, child: child!),
          home: AdaptiveNavScaffold(
            sideBarThickness: 80,
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            policy: const MaterialPolicy(),
            body: const SizedBox(),
          ),
        ),
      );
      expect(find.byType(MaterialNavBar), findsOneWidget);
    });

    testWidgets('late callback does not fire with a stale previous', (
      tester,
    ) async {
      final calls = <NavLayout>[];
      final s = _sig(size: const Size(400, 800));
      await _pump(tester, s, policy: const MaterialPolicy());
      s.update(viewSize: const Size(900, 800));
      tester.view.physicalSize = const Size(900, 800);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await _pump(
        tester,
        s,
        policy: const MaterialPolicy(),
        onLayoutChanged: (p, n) => calls.add(n),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(calls, isEmpty);
    });

    testWidgets('keyboard inset is reduced by the bar height', (tester) async {
      final s = _sig(size: const Size(400, 800));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = s.viewSize;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);
      double? inset;
      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => FoldSignalsScope(override: s, child: child!),
          home: AdaptiveNavScaffold(
            sideBarThickness: 80,
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            policy: const MaterialPolicy(),
            body: Builder(
              builder: (context) {
                inset = MediaQuery.viewInsetsOf(context).bottom;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(inset, lessThan(300));
      expect(inset, greaterThanOrEqualTo(0));
    });

    testWidgets('custom onBack callback intercepts back navigation', (
      tester,
    ) async {
      bool customBackInvoked = false;
      final s = _sig(size: const Size(400, 800));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = s.viewSize;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => FoldSignalsScope(override: s, child: child!),
          home: AdaptiveNavScaffold(
            sideBarThickness: 80,
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            onBack: () => customBackInvoked = true,
            policy: const MaterialPolicy(),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pump();

      expect(customBackInvoked, isTrue);
    });
  });
}
