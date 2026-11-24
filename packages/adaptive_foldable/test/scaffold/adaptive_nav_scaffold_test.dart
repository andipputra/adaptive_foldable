// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _dests = [
  NavDestination(icon: IconData(1), label: 'Home'),
  NavDestination(icon: IconData(2), label: 'Inbox'),
];

class _Host extends StatefulWidget {
  const _Host({required this.signals, this.barBuilder, this.policy});

  final FakeFoldSignals signals;
  final NavBarBuilder? barBuilder;
  final NavPlacementPolicy? policy;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int index = 0;
  final controller = ScrollController();
  final text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          FoldSignalsScope(override: widget.signals, child: child!),
      home: AdaptiveNavScaffold(
        sideBarThickness: 80,
        destinations: _dests,
        selectedIndex: index,
        onSelected: (i) => setState(() => index = i),
        policy: widget.policy,
        barBuilder: widget.barBuilder,
        body: Material(
          child: Column(
            children: [
              TextField(controller: text),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    for (var i = 0; i < 100; i++)
                      SizedBox(height: 50, child: Text('row $i')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  FakeFoldSignals signals, {
  NavBarBuilder? barBuilder,
  NavPlacementPolicy? policy,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = signals.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _Host(signals: signals, barBuilder: barBuilder, policy: policy),
  );
}

Future<void> _resize(
  WidgetTester tester,
  FakeFoldSignals signals,
  Size size, {
  NavEdge? edge,
}) async {
  tester.view.physicalSize = size;
  signals.update(
    viewSize: size,
    verticalBarEdge: edge,
    clearVerticalBarEdge: edge == null,
  );
  await tester.pump();
}

void main() {
  testWidgets('custom barBuilder receives the resolved layout', (tester) async {
    NavLayout? seen;
    final signals = FakeFoldSignals.from(FoldSignalsPresets.duoCoverPortrait);
    await _pump(
      tester,
      signals,
      policy: const ApplePolicy(),
      barBuilder: (context, layout) {
        seen = layout;
        return const SizedBox.expand();
      },
    );
    expect(seen, isNotNull);
    expect(seen!.placement.edge, NavEdge.right);
    expect(seen!.placement.isVertical, isTrue);
    expect(seen!.destinations, _dests);
    expect(seen!.selectedIndex, 0);
    expect(seen!.geometry.itemAxis, NavAxis.vertical);
  });

  testWidgets('placeholder bar sits at the bottom when barBuilder is null', (
    tester,
  ) async {
    final signals = FakeFoldSignals(
      viewSize: const Size(400, 800),
      isAvailable: true,
    );
    await _pump(tester, signals, policy: const ApplePolicy());
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Home')).dy, greaterThan(700));
  });

  testWidgets('tapping a destination calls onSelected', (tester) async {
    final signals = FakeFoldSignals(
      viewSize: const Size(400, 800),
      isAvailable: true,
    );
    await _pump(tester, signals, policy: const ApplePolicy());
    await tester.tap(find.text('Inbox'));
    await tester.pump();
    expect(tester.state<_HostState>(find.byType(_Host)).index, 1);
  });

  testWidgets('state survives bottom -> side -> bottom switches', (
    tester,
  ) async {
    final signals = FakeFoldSignals(
      viewSize: const Size(400, 800),
      isAvailable: true,
    );
    await _pump(tester, signals, policy: const ApplePolicy());
    final host = tester.state<_HostState>(find.byType(_Host));

    await tester.enterText(find.byType(TextField), 'draft');
    host.controller.jumpTo(300);
    await tester.tap(find.text('Inbox'));
    await tester.pump();

    final bottomHeight = tester.getSize(find.byType(ListView)).height;

    await _resize(tester, signals, const Size(400, 800), edge: NavEdge.right);
    expect(tester.getSize(find.byType(ListView)).width, lessThan(400));
    expect(
      tester.getSize(find.byType(ListView)).height,
      greaterThan(bottomHeight),
    );
    expect(host.text.text, 'draft');
    expect(host.controller.offset, 300);

    await _resize(tester, signals, const Size(800, 400), edge: NavEdge.left);
    expect(host.text.text, 'draft');
    expect(host.controller.offset, 300);
    expect(host.index, 1);

    await _resize(tester, signals, const Size(400, 800));
    expect(host.text.text, 'draft');
    expect(host.controller.offset, 300);
    expect(host.index, 1);
  });

  testWidgets('MaterialPolicy moves to a rail by width and keeps state', (
    tester,
  ) async {
    final signals = FakeFoldSignals(viewSize: const Size(500, 800));
    await _pump(
      tester,
      signals,
      policy: const MaterialPolicy(railOnWide: true),
    );
    final host = tester.state<_HostState>(find.byType(_Host));
    await tester.enterText(find.byType(TextField), 'keep');
    expect(tester.getTopLeft(find.text('Home')).dy, greaterThan(700));

    await _resize(tester, signals, const Size(900, 800));
    expect(tester.getTopLeft(find.text('Home')).dx, lessThan(100));
    expect(host.text.text, 'keep');
  });

  testWidgets(
    'default MaterialPolicy keeps tab, scroll and text through resize, '
    'fold into book, rotate and unfold',
    (tester) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(840, 800),
        isAvailable: true,
      );
      await _pump(tester, signals, policy: const MaterialPolicy());
      final host = tester.state<_HostState>(find.byType(_Host));
      await tester.tap(find.text('Inbox'));
      await tester.enterText(find.byType(TextField), 'draft');
      host.controller.jumpTo(300);
      await tester.pump();

      Future<void> step(Size size, {List<Rect> folds = const []}) async {
        tester.view.physicalSize = size;
        signals.update(
          viewSize: size,
          activeFolds: folds,
          posture: folds.isEmpty ? Posture.fullyOpen : Posture.partiallyOpen,
        );
        await tester.pump();
        expect(host.index, 1);
        expect(host.text.text, 'draft');
        expect(host.controller.offset, 300);
        expect(
          tester.getTopLeft(find.text('Home')).dy,
          greaterThan(size.height - 120),
        );
      }

      await step(const Size(420, 800));
      await step(
        const Size(840, 800),
        folds: const [Rect.fromLTWH(400, 0, 40, 800)],
      );
      await step(const Size(800, 840));
      await step(
        const Size(800, 840),
        folds: const [Rect.fromLTWH(0, 400, 800, 40)],
      );
      await step(const Size(840, 800));
    },
  );

  testWidgets('asserts on out-of-range selectedIndex', (tester) async {
    expect(
      () => AdaptiveNavScaffold(
        sideBarThickness: 80,
        destinations: _dests,
        selectedIndex: 2,
        onSelected: (_) {},
        body: const SizedBox(),
      ),
      throwsAssertionError,
    );
  });

  testWidgets('onBack interceptor intercepts back button taps', (tester) async {
    bool intercepted = false;
    final signals = FakeFoldSignals(viewSize: const Size(400, 800));
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = signals.viewSize;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: FoldSignalsScope(
          override: signals,
          child: AdaptiveNavScaffold(
            sideBarThickness: 80,
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            onBack: () => intercepted = true,
            policy: const MaterialPolicy(railOnWide: true),
            body: const SizedBox(),
          ),
        ),
      ),
    );

    expect(find.text('Back'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pump();

    expect(intercepted, isTrue);
  });
}
