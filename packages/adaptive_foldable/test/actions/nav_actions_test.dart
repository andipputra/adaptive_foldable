// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _dests = [
  NavDestination(icon: Icons.home_outlined, label: 'Home'),
  NavDestination(icon: Icons.inbox_outlined, label: 'Inbox'),
];

NavAction act(String label, VoidCallback? onTap) =>
    NavAction(icon: Icons.star, label: label, onPressed: onTap ?? () {});

FakeFoldSignals sig([Size size = const Size(400, 800)]) =>
    FakeFoldSignals(viewSize: size, isAvailable: true);

Future<void> pump(
  WidgetTester tester,
  Widget home, {
  FakeFoldSignals? signals,
  NavPlacementPolicy policy = const ApplePolicy(),
  NavOverflowBuilder? overflowBuilder,
  GlobalKey<NavigatorState>? navKey,
  bool reduceMotion = false,
}) async {
  final s = signals ?? sig();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(disableAnimations: reduceMotion),
        child: FoldSignalsScope(override: s, child: child!),
      ),
      home: AdaptiveNavScaffold(
        destinations: _dests,
        selectedIndex: 0,
        onSelected: (_) {},
        policy: policy,
        overflowBuilder: overflowBuilder,
        body: home,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

/// A navigator inside the scaffold body: pages pushed on it stay under the bar.
Widget shell(Widget first, {GlobalKey<NavigatorState>? key}) => Navigator(
  key: key,
  onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => first),
);

class Page extends StatelessWidget {
  const Page(
    this.name, {
    super.key,
    this.actions = const [],
    this.prominent,
    this.overflow = const [],
  });
  final String name;
  final List<NavAction> actions;
  final NavAction? prominent;
  final List<NavAction> overflow;

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavActions(
      prominentAction: prominent,
      groups: [if (actions.isNotEmpty) NavActionGroup(actions)],
      overflowItems: overflow,
      child: Scaffold(
        body: Column(
          children: [
            Text('page $name'),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Page('$name+', actions: [act('Child', null)]),
                ),
              ),
              child: Text('push from $name'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  reviewRegressionTests();
  dynamicTypeTests();
  group('registry', () {
    testWidgets('publishes actions to the bar', (tester) async {
      await pump(tester, Page('A', actions: [act('Share', null)]));
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('a page without actions shows tabs only', (tester) async {
      await pump(tester, const Text('plain'));
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('More'), findsNothing);
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('changed actions replace the old ones', (tester) async {
      var label = 'One';
      late StateSetter set;
      await pump(
        tester,
        StatefulBuilder(
          builder: (c, s) {
            set = s;
            return Page('A', actions: [act(label, null)]);
          },
        ),
      );
      expect(find.text('One'), findsOneWidget);
      set(() => label = 'Two');
      await tester.pump();
      await tester.pump();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('removed on dispose', (tester) async {
      var show = true;
      late StateSetter set;
      await pump(
        tester,
        StatefulBuilder(
          builder: (c, s) {
            set = s;
            return show
                ? Page('A', actions: [act('Share', null)])
                : const Text('gone');
          },
        ),
      );
      expect(find.text('Share'), findsOneWidget);
      set(() => show = false);
      await tester.pump();
      await tester.pump();
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('top page wins; Back returns to the lower page', (
      tester,
    ) async {
      await pump(tester, shell(Page('A', actions: [act('Share', null)])));
      await tester.tap(find.text('push from A'));
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
      expect(find.text('Share'), findsNothing);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Child'), findsNothing);
    });

    testWidgets('no build-phase errors while publishing', (tester) async {
      await pump(tester, Page('A', actions: [act('Share', null)]));
      expect(tester.takeException(), isNull);
    });

    testWidgets('pressing an action calls onPressed', (tester) async {
      var hits = 0;
      await pump(tester, Page('A', actions: [act('Share', () => hits++)]));
      await tester.tap(find.text('Share'));
      expect(hits, 1);
    });
  });

  group('Back', () {
    testWidgets('root route has no Back', (tester) async {
      await pump(tester, Page('A'));
      expect(find.text('Back'), findsNothing);
    });

    testWidgets('PopScope that blocks keeps the page', (tester) async {
      final inner = GlobalKey<NavigatorState>();
      await pump(
        tester,
        shell(Page('A', actions: [act('Share', null)]), key: inner),
      );
      inner.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => const PopScope(
            canPop: false,
            child: AdaptiveNavActions(child: Text('blocked')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('blocked'), findsOneWidget);
    });

    testWidgets('nested navigator pops only itself', (tester) async {
      final inner = GlobalKey<NavigatorState>();
      await pump(
        tester,
        Navigator(
          key: inner,
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => Page('inner', actions: [act('Share', null)]),
          ),
        ),
      );
      expect(find.text('Back'), findsNothing);
      await tester.tap(find.text('push from inner'));
      await tester.pumpAndSettle();
      expect(find.text('Back'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('page inner'), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      // The outer navigator is untouched.
      expect(find.byType(AdaptiveNavScaffold), findsOneWidget);
    });
  });

  group('overflow', () {
    NavAction many(int i) => act('Act$i', null);

    testWidgets('overflow control appears when extent is short', (
      tester,
    ) async {
      await pump(
        tester,
        Page('A', actions: [for (var i = 0; i < 8; i++) many(i)]),
      );
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets(
      'menu lists overflowed actions and page overflowItems; selecting runs onPressed and closes',
      (tester) async {
        var hit = false;
        await pump(
          tester,
          Page(
            'A',
            actions: [for (var i = 0; i < 8; i++) many(i)],
            overflow: [act('Report', () => hit = true)],
          ),
        );
        await tester.tap(find.text('More'));
        await tester.pump();
        expect(find.text('Report'), findsOneWidget);
        await tester.tap(find.text('Report'));
        await tester.pump();
        expect(hit, isTrue);
        expect(find.text('Report'), findsNothing);
      },
    );

    testWidgets('outside tap closes the menu', (tester) async {
      await pump(
        tester,
        Page(
          'A',
          actions: [for (var i = 0; i < 8; i++) many(i)],
          overflow: [act('Report', null)],
        ),
      );
      await tester.tap(find.text('More'));
      await tester.pump();
      expect(find.text('Report'), findsOneWidget);
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(find.text('Report'), findsNothing);
    });

    testWidgets('custom overflowBuilder receives items, anchor and dismiss', (
      tester,
    ) async {
      List<NavAction>? seen;
      Rect? rect;
      await pump(
        tester,
        Page('A', actions: [for (var i = 0; i < 8; i++) many(i)]),
        overflowBuilder: (context, items, anchor, dismiss) {
          seen = items;
          rect = anchor;
          return GestureDetector(
            onTap: dismiss,
            child: const Text('custom menu'),
          );
        },
      );
      await tester.tap(find.text('More'));
      await tester.pump();
      expect(find.text('custom menu'), findsOneWidget);
      expect(seen, isNotEmpty);
      expect(rect, isNotNull);
      await tester.tap(find.text('custom menu'));
      await tester.pump();
      expect(find.text('custom menu'), findsNothing);
    });

    testWidgets('Material policy puts non-prominent actions in headerActions', (
      tester,
    ) async {
      NavLayout? seen;
      final s = sig(const Size(900, 700));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = s.viewSize;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => FoldSignalsScope(override: s, child: child!),
          home: AdaptiveNavScaffold(
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            policy: const MaterialPolicy(),
            barBuilder: (context, layout) {
              seen = layout;
              return const SizedBox.expand();
            },
            body: Page(
              'A',
              prominent: act('Done', null),
              actions: [act('Share', null)],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(seen!.prominentAction?.label, 'Done');
      expect(seen!.headerActions.single.actions.single.label, 'Share');
      expect(seen!.visibleActions, isEmpty);
    });
  });

  group('modal routes', () {
    testWidgets('a dialog dims the bar and blocks taps on it', (tester) async {
      var hits = 0;
      final inner = GlobalKey<NavigatorState>();
      await pump(
        tester,
        shell(Page('A', actions: [act('Share', () => hits++)]), key: inner),
      );
      showDialog<void>(
        context: inner.currentContext!,
        builder: (_) => const AlertDialog(content: Text('dialog')),
      );
      await tester.pumpAndSettle();
      expect(find.text('dialog'), findsOneWidget);
      final opacity = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Share'), matching: find.byType(Opacity))
            .first,
      );
      expect(opacity.opacity, lessThan(1));
      await tester.tap(find.text('Share'), warnIfMissed: false);
      expect(hits, 0);
    });
  });

  group('route transitions', () {
    testWidgets(
      'incoming actions never flash back to 0 after the push settles',
      (tester) async {
        await pump(tester, shell(Page('A', actions: [act('Share', null)])));
        await tester.tap(find.text('push from A'));
        var sawChild = false;
        double? last;
        for (var i = 0; i < 60; i++) {
          await tester.pump(const Duration(milliseconds: 16));
          final f = find.text('Child');
          if (f.evaluate().isEmpty) continue;
          sawChild = true;
          final o = tester
              .widgetList<Opacity>(
                find.ancestor(of: f, matching: find.byType(Opacity)),
              )
              .fold<double>(1, (a, w) => a * w.opacity);
          if (last != null) {
            expect(o, greaterThanOrEqualTo(last - 1e-9), reason: 'frame $i');
          }
          last = o;
        }
        expect(sawChild, isTrue);
        expect(last, 1);
      },
    );

    testWidgets('popping does not flash the lower actions either', (
      tester,
    ) async {
      final inner = GlobalKey<NavigatorState>();
      await pump(
        tester,
        shell(Page('A', actions: [act('Share', null)]), key: inner),
      );
      await tester.tap(find.text('push from A'));
      await tester.pumpAndSettle();
      inner.currentState!.pop();
      double? last;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final f = find.text('Share');
        if (f.evaluate().isEmpty) continue;
        final o = tester
            .widgetList<Opacity>(
              find.ancestor(of: f, matching: find.byType(Opacity)),
            )
            .fold<double>(1, (a, w) => a * w.opacity);
        if (last != null && o < last - 1e-9 && last > 0.99) {
          fail('flashed from $last to $o at frame $i');
        }
        last = o;
      }
      expect(last, 1);
    });

    testWidgets('actions fade with the route animation and settle', (
      tester,
    ) async {
      await pump(tester, shell(Page('A', actions: [act('Share', null)])));
      await tester.tap(find.text('push from A'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final mid = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((o) => o.opacity)
          .where((o) => o < 1);
      expect(mid, isNotEmpty);
      await tester.pumpAndSettle();
      expect(find.text('Child'), findsOneWidget);
    });

    testWidgets('reduce motion swaps without dimming', (tester) async {
      await pump(
        tester,
        Page('A', actions: [act('Share', null)]),
        reduceMotion: true,
      );
      await tester.tap(find.text('push from A'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      final dimmed = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((o) => o.opacity < 1 && o.opacity > 0.41);
      expect(dimmed, isEmpty);
      await tester.pumpAndSettle();
    });
  });
}

void dynamicTypeTests() {
  group('Dynamic Type', () {
    for (final scale in [1.0, 1.5, 2.0, 3.0]) {
      testWidgets('scale $scale: no overflow errors, labels not clipped', (
        tester,
      ) async {
        final s = sig(const Size(400, 800));
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = s.viewSize;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            builder: (c, child) => MediaQuery(
              data: MediaQuery.of(c)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: FoldSignalsScope(override: s, child: child!),
            ),
            home: AdaptiveNavScaffold(
              destinations: _dests,
              selectedIndex: 0,
              onSelected: (_) {},
              policy: const ApplePolicy(),
              body: Page(
                'A',
                actions: [for (var i = 0; i < 6; i++) act('Act$i', null)],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(tester.takeException(), isNull);
        final visible = [for (var i = 0; i < 6; i++) find.text('Act$i')]
            .where((f) => f.evaluate().isNotEmpty)
            .length;
        if (scale >= 2) {
          expect(visible, lessThan(6));
          expect(find.text('More'), findsOneWidget);
        }
        for (final label in ['Home', 'Inbox']) {
          final box = tester.getRect(find.text(label));
          expect(
            box.bottom,
            lessThanOrEqualTo(800),
            reason: '$label at $scale',
          );
          expect(box.right, lessThanOrEqualTo(400), reason: '$label at $scale');
        }
      });
    }
  });
}

void reviewRegressionTests() {
  group('review regressions', () {
    testWidgets(
      'system Back closes an open menu, and a stale menu cannot block it',
      (tester) async {
        final inner = GlobalKey<NavigatorState>();
        await pump(
          tester,
          shell(
            Page(
              'A',
              actions: [for (var i = 0; i < 8; i++) act('Act$i', null)],
              overflow: [act('Report', null)],
            ),
            key: inner,
          ),
        );
        await tester.tap(find.text('More'));
        await tester.pump();
        expect(find.text('Report'), findsOneWidget);
        await tester.binding.handlePopRoute();
        await tester.pump();
        expect(find.text('Report'), findsNothing);

        // Open again, then change the page underneath: the stale anchor must go.
        await tester.tap(find.text('More'));
        await tester.pump();
        inner.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => Page('B', actions: [act('Solo', null)]),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Report'), findsNothing);
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Report'), findsNothing);
      },
    );

    testWidgets(
      'overflow menu is positioned in the scaffold space when it is not at the screen origin',
      (tester) async {
        final s = sig();
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = s.viewSize;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            builder: (c, child) => FoldSignalsScope(override: s, child: child!),
            home: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: AdaptiveNavScaffold(
                destinations: _dests,
                selectedIndex: 0,
                onSelected: (_) {},
                policy: const ApplePolicy(),
                body: Page(
                  'A',
                  actions: [for (var i = 0; i < 8; i++) act('Act$i', null)],
                  overflow: [act('Report', null)],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        await tester.tap(find.text('More'));
        await tester.pump();
        final menu = tester.getRect(find.text('Report'));
        final more = tester.getRect(find.text('More'));
        expect(menu.bottom, lessThanOrEqualTo(more.top + 1));
        expect(menu.left, greaterThanOrEqualTo(0));
        expect(menu.right, lessThanOrEqualTo(400));
      },
    );

    testWidgets(
      'Material placement overflows header actions instead of overflowing the row',
      (tester) async {
        final s = sig(const Size(700, 700));
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = s.viewSize;
        addTearDown(tester.view.reset);
        NavLayout? seen;
        await tester.pumpWidget(
          MaterialApp(
            builder: (c, child) => FoldSignalsScope(override: s, child: child!),
            home: AdaptiveNavScaffold(
              destinations: _dests,
              selectedIndex: 0,
              onSelected: (_) {},
              policy: const MaterialPolicy(),
              barBuilder: (c, l) {
                seen = l;
                return const SizedBox.expand();
              },
              body: Page(
                'A',
                actions: [for (var i = 0; i < 20; i++) act('Act$i', null)],
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(seen!.overflowedActions, isNotEmpty);
        expect(
          seen!.headerActions.fold<int>(0, (n, g) => n + g.actions.length) +
              seen!.overflowedActions.length,
          20,
        );
        expect(seen!.onOverflow, isNotNull);
      },
    );

    testWidgets(
      'header strip applies the action opacity and shows the overflow control',
      (tester) async {
        final layout = NavLayout(
          placement: const NavPlacement(NavEdge.leading, actionsInHeader: true),
          geometry: const NavGeometry(
            barRect: Rect.fromLTWH(0, 0, 80, 600),
            itemAxis: NavAxis.vertical,
          ),
          headerActions: [
            NavActionGroup([act('Share', null)]),
          ],
          actionsOpacity: 0.3,
          onOverflow: (_) {},
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Material(
              child: Builder(
                builder: (c) => MaterialNavBar.headerStrip(c, layout),
              ),
            ),
          ),
        );
        final o = tester.widget<Opacity>(
          find
              .ancestor(of: find.text('Share'), matching: find.byType(Opacity))
              .first,
        );
        expect(o.opacity, 0.3);
        expect(find.text('More'), findsOneWidget);
      },
    );

    testWidgets('an action always runs the callback from the latest build', (
      tester,
    ) async {
      var count = 0;
      late StateSetter set;
      await pump(
        tester,
        StatefulBuilder(
          builder: (c, s) {
            set = s;
            final captured = count;
            return Page(
              'A',
              actions: [act('Count', () => count = captured + 1)],
            );
          },
        ),
      );
      await tester.tap(find.text('Count'));
      expect(count, 1);
      set(() {});
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('Count'));
      expect(count, 2, reason: 'stale closure would reset to 1');
    });

    testWidgets(
      'overflow menu does not reopen after overflow disappears and returns',
      (tester) async {
        final s = sig(const Size(400, 800));
        await pump(
          tester,
          Page('A', actions: [for (var i = 0; i < 8; i++) act('Act$i', null)]),
          signals: s,
        );
        await tester.tap(find.text('More'));
        await tester.pump();
        expect(find.text('Act7'), findsOneWidget, reason: 'open menu lists it');

        tester.view.physicalSize = const Size(1500, 800);
        s.update(viewSize: const Size(1500, 800));
        await tester.pump();
        await tester.pump();
        expect(find.text('More'), findsNothing, reason: 'everything fits');

        tester.view.physicalSize = const Size(400, 800);
        s.update(viewSize: const Size(400, 800));
        await tester.pump();
        await tester.pump();
        expect(find.text('More'), findsOneWidget);
        expect(
          find.text('Act7'),
          findsNothing,
          reason: 'menu must stay closed',
        );
      },
    );

    test('PageActions ignores onPressed identity but sees visible changes', () {
      PageActions of(String label, {int? badge}) => PageActions(
        groups: [
          NavActionGroup([
            NavAction(
              icon: Icons.star,
              label: label,
              onPressed: () {},
              badgeCount: badge,
            ),
          ]),
        ],
      );
      expect(of('A').sameContentAs(of('A')), isTrue);
      expect(of('A').sameContentAs(of('B')), isFalse);
      expect(of('A').sameContentAs(of('A', badge: 2)), isFalse);
      expect(of('A') == of('A'), isFalse);
    });
  });
}
