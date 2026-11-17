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
