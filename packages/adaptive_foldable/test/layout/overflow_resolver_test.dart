import 'dart:math' as math;

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/layout/overflow_resolver.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void noop() {}

NavAction a(String l, {NavPriority p = NavPriority.normal, int? badge}) =>
    NavAction(
      icon: const IconData(1),
      label: l,
      onPressed: noop,
      priority: p,
      badgeCount: badge,
    );

List<String> labels(Iterable<NavAction> x) => [for (final e in x) e.label];
List<String> visible(OverflowResult r) => [
  for (final g in r.visibleGroups) ...labels(g.actions),
];

OverflowResult run(
  PageActions actions, {
  double extent = 1000,
  double textScale = 1,
  NavCompression mode = NavCompression.navigation,
  int tabs = 3,
  bool back = false,
}) => resolveOverflow(
  actions: actions,
  extent: extent,
  itemExtent: 56,
  textScale: textScale,
  mode: mode,
  tabCount: tabs,
  hasBack: back,
);

void main() {
  final five = PageActions(
    groups: [
      NavActionGroup([a('A1'), a('A2')]),
      NavActionGroup([a('B1'), a('B2'), a('B3')]),
    ],
  );

  test('everything fits: nothing overflows', () {
    final r = run(five);
    expect(visible(r), ['A1', 'A2', 'B1', 'B2', 'B3']);
    expect(r.overflowed, isEmpty);
    expect(r.tabsCompressed, isFalse);
  });

  test('overflows bottom-up and reserves a slot for the ellipsis', () {
    // slots = 5; tabs 3 -> 2 left; one for ellipsis -> 1 action visible.
    final r = run(five, extent: 56 * 5);
    expect(visible(r), ['A1']);
    expect(labels(r.overflowed), ['A2', 'B1', 'B2', 'B3']);
  });

  test('priority reorders by group, then by item', () {
    final actions = PageActions(
      groups: [
        NavActionGroup([a('A1'), a('A2')]),
        NavActionGroup([a('B1', p: NavPriority.high), a('B2')]),
      ],
    );
    // 3 tabs + ellipsis + 2 visible = 6 slots: the group holding the high item stays.
    final r = run(actions, extent: 56 * 6);
    expect(visible(r), ['B1', 'B2']);
    expect(labels(r.overflowed), ['A1', 'A2']);
    // One slot fewer: inside the surviving group the high item outlasts the normal one.
    final tighter = run(actions, extent: 56 * 5);
    expect(visible(tighter), ['B1']);
    expect(labels(tighter.overflowed), ['A1', 'A2', 'B2']);
  });

  test('badged items rank higher than unbadged ones', () {
    final actions = PageActions(
      groups: [
        NavActionGroup([a('X'), a('Y', badge: 3), a('Z')]),
      ],
    );
    final r = run(actions, extent: 56 * 5); // 1 visible
    expect(visible(r), ['Y']);
    expect(labels(r.overflowed), ['X', 'Z']);
  });

  test('page overflowItems alone reserve the ellipsis slot', () {
    final actions = PageActions(
      groups: [
        NavActionGroup([a('A'), a('B')]),
      ],
      overflowItems: [a('Report')],
    );
    final r = run(actions, extent: 56 * 5); // 3 tabs + ellipsis + 1
    expect(visible(r), ['A']);
    expect(labels(r.overflowed), ['B', 'Report']);
  });

  test('task mode compresses tabs before overflowing actions', () {
    final tight = 56.0 * 6; // tabs 3 + 3 actions need 6, plus ellipsis no
    final actions = PageActions(
      groups: [
        NavActionGroup([a('A'), a('B'), a('C')]),
      ],
    );
    final nav = run(actions, extent: tight - 56);
    expect(nav.overflowed, isNotEmpty);
    final task = run(actions, extent: tight - 56, mode: NavCompression.task);
    expect(task.tabsCompressed, isTrue);
    expect(task.overflowed, isEmpty);
  });

  test('navigation mode never compresses tabs', () {
    final r = run(five, extent: 56 * 2);
    expect(r.tabsCompressed, isFalse);
  });

  test('prominent action and Back count first and never overflow', () {
    final actions = PageActions(
      prominentAction: a('Done'),
      groups: [
        NavActionGroup([a('A'), a('B')]),
      ],
    );
    final r = run(actions, extent: 56 * 5, back: true);
    // Back + Done + 3 tabs = 5: no room for any group action.
    expect(visible(r), isEmpty);
    expect(labels(r.overflowed), ['A', 'B']);
  });

  test('zero, negative and infinite extent are handled', () {
    expect(run(five, extent: 0).overflowed, hasLength(5));
    expect(run(five, extent: -10).overflowed, hasLength(5));
    expect(run(five, extent: double.infinity).overflowed, isEmpty);
    expect(run(PageActions.empty, extent: 0).overflowed, isEmpty);
  });

  test('single action', () {
    final one = PageActions(
      groups: [
        NavActionGroup([a('Only')]),
      ],
    );
    expect(visible(run(one, extent: 56 * 4)), ['Only']);
    expect(run(one, extent: 56 * 3).overflowed, hasLength(1));
  });

  test('text scale grows the slot from 1.0 to 3.0', () {
    var previous = 99;
    for (final s in [1.0, 1.5, 2.0, 3.0]) {
      final n = visible(run(five, extent: 56 * 8, textScale: s)).length;
      expect(n, lessThanOrEqualTo(previous));
      previous = n;
    }
    expect(
      visible(run(five, extent: 56 * 8, textScale: 3)).length,
      lessThan(5),
    );
  });

  test('slot never drops below 44', () {
    final r = resolveOverflow(
      actions: five,
      extent: 44 * 5,
      itemExtent: 10,
      textScale: 1,
      mode: NavCompression.navigation,
      tabCount: 3,
    );
    expect(visible(r), ['A1']);
  });

  test('equal actions are tracked by identity, not equality', () {
    final dup = a('Same');
    final actions = PageActions(
      groups: [
        NavActionGroup([a('Keep'), dup, a('Same')]),
      ],
    );
    final r = run(actions, extent: 56 * 5);
    expect(visible(r).length + r.overflowed.length, 3);
  });

  test('property: visible + overflowed equals input, order stable', () {
    final rnd = math.Random(7);
    for (var i = 0; i < 500; i++) {
      final groups = [
        for (var g = 0; g < rnd.nextInt(4); g++)
          NavActionGroup([
            for (var k = 0; k < rnd.nextInt(5); k++)
              a(
                'g$g.$k',
                p: NavPriority.values[rnd.nextInt(3)],
                badge: rnd.nextBool() ? rnd.nextInt(5) : null,
              ),
          ]),
      ];
      final page = PageActions(
        prominentAction: rnd.nextBool() ? a('P') : null,
        groups: groups,
        overflowItems: [for (var k = 0; k < rnd.nextInt(3); k++) a('o$k')],
      );
      final r = run(
        page,
        extent: rnd.nextDouble() * 800,
        textScale: 1 + rnd.nextDouble() * 2,
        mode: NavCompression.values[rnd.nextInt(2)],
        tabs: 1 + rnd.nextInt(5),
        back: rnd.nextBool(),
      );
      final input = [
        for (final g in groups) ...labels(g.actions),
        ...labels(page.overflowItems),
      ];
      final out = [...visible(r), ...labels(r.overflowed)];
      expect(out.toSet(), input.toSet());
      expect(out.length, input.length);
      final inputOrder = [for (final g in groups) ...labels(g.actions)];
      expect(
        visible(r),
        inputOrder.where(visible(r).contains).toList(),
        reason: 'visible order stable',
      );
    }
  });
}
