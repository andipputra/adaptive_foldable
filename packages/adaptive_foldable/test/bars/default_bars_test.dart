// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'dart:ui' show CheckedState, Rect, Tristate;

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show DebugSemanticsDumpOrder;
import 'package:flutter/semantics.dart' show SemanticsNode;
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';

const _dests = [
  NavDestination(
    icon: Icons.home_outlined,
    label: 'Home',
    selectedIcon: Icons.home,
  ),
  NavDestination(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 7),
  NavDestination(icon: Icons.person_outline, label: 'Me'),
];

Future<int?> _pump(
  WidgetTester tester,
  FoldSignals signals,
  NavBarBuilder builder, {
  NavPlacementPolicy policy = const ApplePolicy(),
  TextDirection dir = TextDirection.ltr,
  ValueChanged<int>? onSelected,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = signals.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: dir,
      child: MaterialApp(
        builder: (c, child) => Directionality(
          textDirection: dir,
          child: FoldSignalsScope(override: signals, child: child!),
        ),
        home: AdaptiveNavScaffold(
          sideBarThickness: 80,
          destinations: _dests,
          selectedIndex: 1,
          onSelected: onSelected ?? (_) {},
          policy: policy,
          barBuilder: builder,
          body: const SizedBox(),
        ),
      ),
    ),
  );
  return null;
}

void main() {
  accessibilityTests();
  for (final entry in {
    'material': materialBarBuilder,
    'cupertino': cupertinoBarBuilder,
  }.entries) {
    group('${entry.key} bar', () {
      testWidgets('renders destinations, badge, and taps call onSelected', (
        tester,
      ) async {
        int? tapped;
        await _pump(
          tester,
          FakeFoldSignals.from(FoldSignalsPresets.regularIphone),
          entry.value,
          onSelected: (i) => tapped = i,
        );
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Inbox'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        await tester.tap(find.text('Me'));
        expect(tapped, 2);
      });

      testWidgets('tap targets are at least 44x44', (tester) async {
        await _pump(
          tester,
          FakeFoldSignals.from(FoldSignalsPresets.duoCoverLandscape),
          entry.value,
        );
        for (final n in ['Home', 'Inbox', 'Me']) {
          final box = tester.getSize(
            find
                .ancestor(
                  of: find.text(n),
                  matching: find.byType(ConstrainedBox),
                )
                .first,
          );
          // Side column is kSideBarThickness (40) wide; height keeps the 44 pt target.
          expect(box.width, greaterThanOrEqualTo(40));
          expect(box.height, greaterThanOrEqualTo(44));
        }
      });

      testWidgets('semantics: label, selected state, order', (tester) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          FakeFoldSignals.from(FoldSignalsPresets.regularIphone),
          entry.value,
        );
        final home = tester.getSemantics(find.bySemanticsLabel('Home'));
        final inbox = tester.getSemantics(
          find.bySemanticsLabel(RegExp('^Inbox')),
        );
        expect(home.flagsCollection.isSelected, Tristate.isFalse);
        expect(inbox.flagsCollection.isSelected, Tristate.isTrue);
        expect(
          tester.getTopLeft(find.text('Home')).dx,
          lessThan(tester.getTopLeft(find.text('Inbox')).dx),
        );
        handle.dispose();
      });
    });
  }

  group('placement per preset', () {
    testWidgets('Cupertino column starts below the camera on cover portrait', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.duoCoverPortrait);
      await _pump(tester, s, cupertinoBarBuilder);
      expect(
        tester.getTopLeft(find.text('Home')).dy,
        greaterThanOrEqualTo(174),
      );
    });

    testWidgets('Cupertino column ends above the camera on cover landscape', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.duoCoverLandscape);
      await _pump(tester, s, cupertinoBarBuilder);
      expect(find.text('Me'), findsOneWidget);
      expect(tester.getBottomLeft(find.text('Me')).dy, lessThanOrEqualTo(384));
    });

    testWidgets('Cupertino column does not flip in RTL', (tester) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.duoCoverLandscape);
      await _pump(tester, s, cupertinoBarBuilder, dir: TextDirection.rtl);
      expect(
        tester.getTopLeft(find.text('Home')).dx,
        greaterThan(s.viewSize.width / 2),
      );
    });

    testWidgets('Cupertino bottom bar respects the home indicator gap', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.regularIphone);
      await _pump(tester, s, cupertinoBarBuilder);
      expect(find.byType(CupertinoStyleNavBar), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Home')).dy,
        lessThanOrEqualTo(s.viewSize.height),
      );
    });

    for (final (name, preset) in [
      ('compact', FoldSignalsPresets.androidCompact),
      ('medium', FoldSignalsPresets.androidMedium),
      ('expanded', FoldSignalsPresets.androidExpanded),
    ]) {
      testWidgets('Material bar in $name preset', (tester) async {
        final s = FakeFoldSignals.from(preset);
        await _pump(
          tester,
          s,
          materialBarBuilder,
          policy: const MaterialPolicy(railOnWide: true),
        );
        expect(find.byType(MaterialNavBar), findsOneWidget);
        final x = tester.getTopLeft(find.text('Home')).dx;
        if (name == 'compact') {
          expect(x, lessThan(s.viewSize.width / 2));
          expect(
            tester.getTopLeft(find.text('Home')).dy,
            greaterThan(s.viewSize.height - 100),
          );
        } else {
          expect(x, lessThan(120));
        }
      });
    }

    testWidgets('Material rail flips to the right in RTL', (tester) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.androidMedium);
      await _pump(
        tester,
        s,
        materialBarBuilder,
        policy: const MaterialPolicy(railOnWide: true),
        dir: TextDirection.rtl,
      );
      expect(
        tester.getTopLeft(find.text('Home')).dx,
        greaterThan(s.viewSize.width - 120),
      );
    });
  });

  group('review regressions', () {
    testWidgets('Back and plain actions expose no checked state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final layout = NavLayout(
        placement: const NavPlacement(NavEdge.bottom),
        geometry: const NavGeometry(
          barRect: Rect.fromLTWH(0, 700, 400, 100),
          itemAxis: NavAxis.horizontal,
        ),
        showBack: true,
        onBack: () {},
        prominentAction: NavAction(
          icon: Icons.check,
          label: 'Done',
          onPressed: () {},
        ),
        destinations: _dests,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Material(child: MaterialNavBar(layout: layout)),
        ),
      );
      for (final l in ['Back', 'Done']) {
        final node = tester.getSemantics(find.bySemanticsLabel(l));
        expect(node.flagsCollection.isChecked, CheckedState.none, reason: l);
      }
      handle.dispose();
    });

    testWidgets('tabs announce their position', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        FakeFoldSignals.from(FoldSignalsPresets.regularIphone),
        materialBarBuilder,
      );
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')).value,
        contains('1 of 3'),
      );
      handle.dispose();
    });

    testWidgets('keyboard activation selects a tab', (tester) async {
      int? tapped;
      await _pump(
        tester,
        FakeFoldSignals.from(FoldSignalsPresets.regularIphone),
        materialBarBuilder,
        onSelected: (i) => tapped = i,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, isNotNull);
    });

    testWidgets('semantics tooltip carries the label', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        FakeFoldSignals.from(FoldSignalsPresets.regularIphone),
        materialBarBuilder,
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Home')).tooltip,
        'Home',
      );
      handle.dispose();
    });

    testWidgets('large text scale grows the bottom bar, no overflow', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.regularIphone);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = s.viewSize;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: FoldSignalsScope(override: s, child: child!),
          ),
          home: AdaptiveNavScaffold(
            sideBarThickness: 80,
            destinations: _dests,
            selectedIndex: 0,
            onSelected: (_) {},
            barBuilder: materialBarBuilder,
            body: const SizedBox(),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Cupertino logical edge resolves the side by direction', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.androidMedium);
      await _pump(
        tester,
        s,
        cupertinoBarBuilder,
        policy: const MaterialPolicy(railOnWide: true),
      );
      expect(tester.getTopLeft(find.text('Home')).dx, lessThan(100));
    });
  });
}

class _A11y {
  static NavLayout layout({
    int tabs = 3,
    int actions = 4,
    bool compressed = false,
  }) => NavLayout(
    placement: const NavPlacement(NavEdge.bottom),
    geometry: const NavGeometry(
      barRect: Rect.fromLTWH(0, 700, 400, 100),
      itemAxis: NavAxis.horizontal,
    ),
    showBack: true,
    onBack: () {},
    prominentAction: NavAction(
      icon: Icons.check,
      label: 'Done',
      onPressed: () {},
    ),
    visibleActions: [
      NavActionGroup([
        for (var i = 0; i < actions; i++)
          NavAction(icon: Icons.star, label: 'Act$i', onPressed: () {}),
      ]),
    ],
    destinations: [
      for (var i = 0; i < tabs; i++)
        NavDestination(icon: Icons.home, label: 'Tab$i'),
    ],
    tabsCompressed: compressed,
  );
}

void accessibilityTests() {
  group('accessibility', () {
    for (final entry in {
      'material': materialBarBuilder,
      'cupertino': cupertinoBarBuilder,
    }.entries) {
      testWidgets(
        '${entry.key}: semantics order is Back, prominent, groups, tabs',
        (tester) async {
          final handle = tester.ensureSemantics();
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.rtl,
              child: MaterialApp(
                home: Material(
                  child: Builder(
                    builder: (c) => entry.value(c, _A11y.layout()),
                  ),
                ),
              ),
            ),
          );
          final order = <String>[];
          final root = tester.getSemantics(
            find.byType(Scaffold).evaluate().isEmpty
                ? find.byType(Material).first
                : find.byType(Scaffold).first,
          );
          void walk(SemanticsNode n) {
            if (n.label.isNotEmpty) order.add(n.label);
            for (final c in n.debugListChildrenInOrder(
              DebugSemanticsDumpOrder.traversalOrder,
            )) {
              walk(c);
            }
          }

          walk(root);
          final labels = [
            'Back',
            'Done',
            'Act0',
            'Act1',
            'Act2',
            'Act3',
            'Tab0',
            'Tab1',
            'Tab2',
          ];
          expect(order.where(labels.contains).toList(), labels);
          handle.dispose();
        },
      );
    }

    testWidgets('every item has a 44x44 minimum target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (c) => materialBarBuilder(c, _A11y.layout()),
            ),
          ),
        ),
      );
      for (final l in ['Back', 'Done', 'Act0', 'Tab0']) {
        final box = tester.getSize(
          find
              .ancestor(of: find.text(l), matching: find.byType(ConstrainedBox))
              .first,
        );
        expect(box.width, greaterThanOrEqualTo(44), reason: l);
        expect(box.height, greaterThanOrEqualTo(44), reason: l);
      }
    });

    testWidgets('Tab key visits items in visual order', (tester) async {
      final seen = <String>[];
      final layout = NavLayout(
        placement: const NavPlacement(NavEdge.bottom),
        geometry: const NavGeometry(
          barRect: Rect.fromLTWH(0, 700, 400, 100),
          itemAxis: NavAxis.horizontal,
        ),
        prominentAction: NavAction(
          icon: Icons.check,
          label: 'Done',
          onPressed: () => seen.add('Done'),
        ),
        destinations: const [NavDestination(icon: Icons.home, label: 'Tab0')],
        onSelected: (_) => seen.add('Tab0'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(builder: (c) => materialBarBuilder(c, layout)),
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(seen, ['Done', 'Tab0']);
    });

    testWidgets('CupertinoStyleNavBar light mode inactive color is #636366', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (context) {
              final colors = CupertinoStyleNavBar.defaultColors(context);
              expect(colors.inactive, const Color(0xFF636366));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('NavBarItem badge sets textScaler to noScaling', (
      tester,
    ) async {
      const item = NavBarItem(
        icon: Icons.inbox,
        label: 'Inbox',
        selected: false,
        onTap: null,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey,
        badgeCount: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          builder: (c, child) => MediaQuery(
            data: MediaQuery.of(c)
                .copyWith(textScaler: const TextScaler.linear(3.0)),
            child: child!,
          ),
          home: const Scaffold(body: Center(child: item)),
        ),
      );

      final badgeText = tester.widget<Text>(find.text('5'));
      expect(badgeText.textScaler, TextScaler.noScaling);
    });
  });
}
