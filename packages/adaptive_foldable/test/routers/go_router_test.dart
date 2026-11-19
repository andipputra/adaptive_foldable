// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

NavAction act(String label) =>
    NavAction(icon: Icons.star, label: label, onPressed: () {});

class _ListPage extends StatelessWidget {
  const _ListPage(this.tab);
  final String tab;

  @override
  Widget build(BuildContext context) => AdaptiveNavActions(
    groups: [
      NavActionGroup([act('List$tab')]),
    ],
    child: Material(
      child: ListView(
        key: PageStorageKey('list$tab'),
        children: [
          for (var i = 0; i < 60; i++)
            ListTile(
              title: Text('item $tab$i'),
              onTap: () => context.go('/$tab/detail/$i'),
            ),
        ],
      ),
    ),
  );
}

class _DetailPage extends StatelessWidget {
  const _DetailPage(this.tab, this.id);
  final String tab;
  final String id;

  @override
  Widget build(BuildContext context) => AdaptiveNavActions(
    groups: [
      NavActionGroup([act('Detail$id')]),
    ],
    child: Scaffold(body: Text('detail $tab$id')),
  );
}

GoRouter buildRouter({String initial = '/a'}) => GoRouter(
  initialLocation: initial,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => AdaptiveNavScaffold(
        destinations: const [
          NavDestination(icon: Icons.home, label: 'Alpha'),
          NavDestination(icon: Icons.inbox, label: 'Beta'),
        ],
        selectedIndex: shell.currentIndex,
        onSelected: shell.goBranch,
        policy: const ApplePolicy(),
        body: shell,
      ),
      branches: [
        for (final t in ['a', 'b'])
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/$t',
                builder: (_, _) => _ListPage(t),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (_, s) => _DetailPage(t, s.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
      ],
    ),
  ],
);

Future<void> pumpRouter(WidgetTester tester, GoRouter router) async {
  final s = FakeFoldSignals(viewSize: const Size(400, 800), isAvailable: true);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = s.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (c, child) => FoldSignalsScope(override: s, child: child!),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('list page publishes its actions', (tester) async {
    await pumpRouter(tester, buildRouter());
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('deep link to detail shows its actions and Back', (tester) async {
    await pumpRouter(tester, buildRouter(initial: '/a/detail/7'));
    expect(find.text('detail a7'), findsOneWidget);
    expect(find.text('Detail7'), findsOneWidget);
  });

  testWidgets('push detail, Back pops, actions follow', (tester) async {
    final router = buildRouter();
    await pumpRouter(tester, router);
    await tester.tap(find.text('item a3'));
    await tester.pumpAndSettle();
    expect(find.text('Detail3'), findsOneWidget);
    expect(find.text('Lista'), findsNothing);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Lista'), findsOneWidget);
    expect(find.text('Detail3'), findsNothing);
  });

  testWidgets('switching branches swaps actions and keeps scroll offset', (
    tester,
  ) async {
    await pumpRouter(tester, buildRouter());
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.textContaining('item a1').first).dy;

    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(find.text('Listb'), findsOneWidget);
    expect(find.text('Lista'), findsNothing);

    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Lista'), findsOneWidget);
    final after = tester.getTopLeft(find.textContaining('item a1').first).dy;
    expect(after, before);
  });

  testWidgets('branch with a pushed detail keeps its Back after switching', (
    tester,
  ) async {
    await pumpRouter(tester, buildRouter());
    await tester.tap(find.text('item a2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beta'));
    await tester.pumpAndSettle();
    expect(find.text('Back'), findsNothing);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.text('Detail2'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('cancelled back swipe leaves the detail actions in place', (
    tester,
  ) async {
    final router = buildRouter();
    await pumpRouter(tester, router);
    await tester.tap(find.text('item a1'));
    await tester.pumpAndSettle();
    final gesture = await tester.startGesture(const Offset(2, 300));
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    await gesture.moveBy(const Offset(-60, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Detail1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
