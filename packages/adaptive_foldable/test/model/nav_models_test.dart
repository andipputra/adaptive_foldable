import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void noop() {}

NavGeometry geometry() => const NavGeometry(
  barRect: Rect.fromLTWH(0, 0, 80, 600),
  itemAxis: NavAxis.vertical,
);

void main() {
  group('NavPlacement', () {
    test('isVertical is false only for bottom', () {
      expect(const NavPlacement(NavEdge.bottom).isVertical, isFalse);
      for (final e in [
        NavEdge.leading,
        NavEdge.trailing,
        NavEdge.left,
        NavEdge.right,
      ]) {
        expect(NavPlacement(e).isVertical, isTrue);
      }
    });

    test('equality by edge', () {
      expect(
        const NavPlacement(NavEdge.left),
        const NavPlacement(NavEdge.left),
      );
      expect(
        const NavPlacement(NavEdge.left),
        isNot(const NavPlacement(NavEdge.right)),
      );
    });
  });

  group('NavAction', () {
    test('defaults priority normal and flags off', () {
      const a = NavAction(icon: IconData(1), label: 'Share', onPressed: noop);
      expect(a.priority, NavPriority.normal);
      expect(a.isDestructive, isFalse);
      expect(a.enabled, isTrue);
      expect(a.selected, isFalse);
    });

    test('priority ordering is low < normal < high', () {
      expect(NavPriority.low.index < NavPriority.normal.index, isTrue);
      expect(NavPriority.normal.index < NavPriority.high.index, isTrue);
    });

    test('asserts on empty label', () {
      expect(
        () => NavAction(icon: const IconData(1), label: '', onPressed: noop),
        throwsAssertionError,
      );
    });

    test('equality and copyWith', () {
      const a = NavAction(icon: IconData(1), label: 'A', onPressed: noop);
      expect(
        a,
        const NavAction(icon: IconData(1), label: 'A', onPressed: noop),
      );
      final b = a.copyWith(label: 'B', priority: NavPriority.high);
      expect(b.label, 'B');
      expect(b.priority, NavPriority.high);
      expect(b, isNot(a));
      expect(a.copyWith(), a);
    });
  });

  group('NavDestination', () {
    test('asserts on empty label', () {
      expect(
        () => NavDestination(icon: const IconData(1), label: ''),
        throwsAssertionError,
      );
    });

    test('equality and copyWith', () {
      const d = NavDestination(icon: IconData(1), label: 'Home');
      expect(d, const NavDestination(icon: IconData(1), label: 'Home'));
      expect(d.copyWith(badgeCount: 3).badgeCount, 3);
      expect(d.copyWith(badgeCount: 3), isNot(d));
    });
  });

  group('NavActionGroup', () {
    test('equality compares contents', () {
      const a = NavAction(icon: IconData(1), label: 'A', onPressed: noop);
      expect(const NavActionGroup([a]), const NavActionGroup([a]));
      expect(const NavActionGroup([a]), isNot(const NavActionGroup([])));
    });
  });

  group('NavGeometry', () {
    test('equality and copyWith', () {
      final g = geometry();
      expect(g, geometry());
      expect(g.copyWith(foldClearance: 4).foldClearance, 4);
      expect(g.copyWith(foldClearance: 4), isNot(g));
      expect(g.homeIndicatorGap, 0);
      expect(g.skipRegion, isNull);
    });
  });

  group('NavLayout', () {
    NavLayout layout() => NavLayout(
      placement: const NavPlacement(NavEdge.left),
      geometry: geometry(),
    );

    test('defaults', () {
      final l = layout();
      expect(l.showBack, isFalse);
      expect(l.visibleActions, isEmpty);
      expect(l.overflowedActions, isEmpty);
      expect(l.headerActions, isEmpty);
      expect(l.destinations, isEmpty);
      expect(l.paneCount, 1);
      expect(l.posture, Posture.unknown);
      expect(l.tabsCompressed, isFalse);
    });

    test('equality and copyWith', () {
      expect(layout(), layout());
      expect(layout().hashCode, layout().hashCode);
      final next = layout().copyWith(paneCount: 2, posture: Posture.fullyOpen);
      expect(next.paneCount, 2);
      expect(next.posture, Posture.fullyOpen);
      expect(next, isNot(layout()));
      expect(layout().copyWith(), layout());
    });

    test('asserts paneCount is 1 or 2', () {
      expect(
        () => NavLayout(
          placement: const NavPlacement(NavEdge.bottom),
          geometry: geometry(),
          paneCount: 3,
        ),
        throwsAssertionError,
      );
    });
  });
}
