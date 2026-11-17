import 'dart:ui' show Tristate;

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
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
          expect(box.width, greaterThanOrEqualTo(44));
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
    testWidgets('Cupertino column starts below the camera on cover landscape', (
      tester,
    ) async {
      final s = FakeFoldSignals.from(FoldSignalsPresets.duoCoverLandscape);
      await _pump(tester, s, cupertinoBarBuilder);
      final top = tester.getTopLeft(find.text('Home')).dy;
      final occlusionBottom = s.occlusions
          .map((r) => r.bottom)
          .fold<double>(0, (a, b) => a > b ? a : b);
      expect(top, greaterThanOrEqualTo(occlusionBottom));
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
          policy: const MaterialPolicy(),
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
        policy: const MaterialPolicy(),
        dir: TextDirection.rtl,
      );
      expect(
        tester.getTopLeft(find.text('Home')).dx,
        greaterThan(s.viewSize.width - 120),
      );
    });
  });
}
