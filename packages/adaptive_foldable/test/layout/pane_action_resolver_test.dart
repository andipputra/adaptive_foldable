// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dummyAction1 = NavAction(
    icon: Icons.search,
    label: 'Search',
    onPressed: () {},
  );
  final dummyAction2 = NavAction(
    icon: Icons.delete,
    label: 'Delete',
    onPressed: () {},
  );

  group('resolveColumnOwnerPaneId', () {
    test('single pane returns the sole pane', () {
      final owner = resolveColumnOwnerPaneId(
        activePaneIds: ['main'],
        barEdge: NavEdge.leading,
        textDirection: TextDirection.ltr,
      );
      expect(owner, equals('main'));
    });

    test('trailing bar in LTR touches end pane', () {
      final owner = resolveColumnOwnerPaneId(
        activePaneIds: ['start', 'end'],
        barEdge: NavEdge.trailing,
        textDirection: TextDirection.ltr,
      );
      expect(owner, equals('end'));
    });

    test('trailing bar in RTL touches end pane', () {
      final owner = resolveColumnOwnerPaneId(
        activePaneIds: ['start', 'end'],
        barEdge: NavEdge.trailing,
        textDirection: TextDirection.rtl,
      );
      expect(owner, equals('end'));
    });

    test('leading bar in LTR touches start pane', () {
      final owner = resolveColumnOwnerPaneId(
        activePaneIds: ['start', 'end'],
        barEdge: NavEdge.leading,
        textDirection: TextDirection.ltr,
      );
      expect(owner, equals('start'));
    });

    test('leading bar in RTL touches start pane', () {
      final owner = resolveColumnOwnerPaneId(
        activePaneIds: ['start', 'end'],
        barEdge: NavEdge.leading,
        textDirection: TextDirection.rtl,
      );
      expect(owner, equals('start'));
    });

    test(
      'physical right bar in LTR touches end pane, in RTL touches start pane',
      () {
        final ownerLtr = resolveColumnOwnerPaneId(
          activePaneIds: ['start', 'end'],
          barEdge: NavEdge.right,
          textDirection: TextDirection.ltr,
        );
        expect(ownerLtr, equals('end'));

        final ownerRtl = resolveColumnOwnerPaneId(
          activePaneIds: ['start', 'end'],
          barEdge: NavEdge.right,
          textDirection: TextDirection.rtl,
        );
        expect(ownerRtl, equals('start'));
      },
    );
  });

  group('resolvePaneActions', () {
    test(
      'trailing column assigns end pane to column and start pane to header',
      () {
        final assignment = resolvePaneActions(
          activePaneIds: ['start', 'end'],
          barEdge: NavEdge.trailing,
          publishedActions: {
            'start': PageActions(
              groups: [
                NavActionGroup([dummyAction1]),
              ],
            ),
            'end': PageActions(
              groups: [
                NavActionGroup([dummyAction2]),
              ],
            ),
          },
          textDirection: TextDirection.ltr,
        );

        expect(assignment.columnPaneId, equals('end'));
        expect(
          assignment.columnActions.groups.first.actions.first.label,
          equals('Delete'),
        );
        expect(assignment.headerPaneActions.containsKey('start'), isTrue);
        expect(
          assignment
              .headerPaneActions['start']!
              .groups
              .first
              .actions
              .first
              .label,
          equals('Search'),
        );
        expect(assignment.headerPaneActions.containsKey('end'), isFalse);
      },
    );

    test(
      'placement: column forces actions into column even from secondary pane',
      () {
        final assignment = resolvePaneActions(
          activePaneIds: ['start', 'end'],
          barEdge: NavEdge.trailing, // 'end' owns column
          publishedActions: {
            'start': PageActions(
              placement: NavActionPlacement.column,
              groups: [
                NavActionGroup([dummyAction1]),
              ],
            ),
            'end': PageActions(
              groups: [
                NavActionGroup([dummyAction2]),
              ],
            ),
          },
          textDirection: TextDirection.ltr,
        );

        expect(assignment.columnPaneId, equals('end'));
        // Both action groups merged into columnActions
        final allColumnActionIds = assignment.columnActions.groups
            .expand((g) => g.actions)
            .map((a) => a.label)
            .toList();
        expect(allColumnActionIds, containsAll(['Search', 'Delete']));
        expect(assignment.headerPaneActions.containsKey('start'), isFalse);
      },
    );

    test(
      'placement: paneHeader forces actions into header even for column owner',
      () {
        final assignment = resolvePaneActions(
          activePaneIds: ['start', 'end'],
          barEdge: NavEdge.trailing, // 'end' owns column
          publishedActions: {
            'start': PageActions(
              groups: [
                NavActionGroup([dummyAction1]),
              ],
            ),
            'end': PageActions(
              placement: NavActionPlacement.paneHeader,
              groups: [
                NavActionGroup([dummyAction2]),
              ],
            ),
          },
          textDirection: TextDirection.ltr,
        );

        expect(assignment.columnPaneId, equals('end'));
        expect(assignment.columnActions.isEmpty, isTrue);
        expect(
          assignment.headerPaneActions['end']!.groups.first.actions.first.label,
          equals('Delete'),
        );
        expect(
          assignment
              .headerPaneActions['start']!
              .groups
              .first
              .actions
              .first
              .label,
          equals('Search'),
        );
      },
    );
  });
}
