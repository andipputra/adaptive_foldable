import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NavPaneScope', () {
    testWidgets('defaults to mainPane when unscoped', (tester) async {
      String? resolvedPaneId;
      NavPaneScope? resolvedScope;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            resolvedPaneId = NavPaneScope.idOf(context);
            resolvedScope = NavPaneScope.maybeOf(context);
            return const SizedBox();
          },
        ),
      );

      expect(resolvedPaneId, equals(NavPaneScope.mainPane));
      expect(resolvedScope, isNull);
    });

    testWidgets('resolves scoped paneId and isPrimary', (tester) async {
      String? resolvedPaneId;
      NavPaneScope? resolvedScope;

      await tester.pumpWidget(
        NavPaneScope(
          paneId: NavPaneScope.startPane,
          isPrimary: true,
          child: Builder(
            builder: (context) {
              resolvedPaneId = NavPaneScope.idOf(context);
              resolvedScope = NavPaneScope.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedPaneId, equals(NavPaneScope.startPane));
      expect(resolvedScope, isNotNull);
      expect(resolvedScope!.paneId, equals(NavPaneScope.startPane));
      expect(resolvedScope!.isPrimary, isTrue);
    });

    testWidgets('nested scopes resolve the innermost scope', (tester) async {
      String? outerPaneId;
      String? innerPaneId;

      await tester.pumpWidget(
        NavPaneScope(
          paneId: NavPaneScope.startPane,
          child: Builder(
            builder: (context) {
              outerPaneId = NavPaneScope.idOf(context);
              return NavPaneScope(
                paneId: NavPaneScope.endPane,
                child: Builder(
                  builder: (innerContext) {
                    innerPaneId = NavPaneScope.idOf(innerContext);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(outerPaneId, equals(NavPaneScope.startPane));
      expect(innerPaneId, equals(NavPaneScope.endPane));
    });

    testWidgets('updateShouldNotify fires on paneId or isPrimary change', (
      tester,
    ) async {
      int buildCount = 0;
      String currentPane = NavPaneScope.startPane;
      bool currentPrimary = false;

      late StateSetter setState;

      final subscriber = Builder(
        builder: (childContext) {
          NavPaneScope.idOf(childContext);
          NavPaneScope.maybeOf(childContext);
          buildCount++;
          return const SizedBox();
        },
      );

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return NavPaneScope(
              paneId: currentPane,
              isPrimary: currentPrimary,
              child: subscriber,
            );
          },
        ),
      );

      expect(buildCount, equals(1));

      // Rebuild with same values -> InheritedWidget does not notify dependants
      setState(() {});
      await tester.pump();
      expect(buildCount, equals(1));

      // Change paneId -> rebuilds dependent
      setState(() {
        currentPane = NavPaneScope.endPane;
      });
      await tester.pump();
      expect(buildCount, equals(2));

      // Change isPrimary -> rebuilds dependent
      setState(() {
        currentPrimary = true;
      });
      await tester.pump();
      expect(buildCount, equals(3));
    });
  });

  group('NavPaneRegistry', () {
    test('registers panes and maintains order', () {
      final registry = NavPaneRegistry();
      int notifyCount = 0;
      registry.addListener(() => notifyCount++);

      expect(registry.panes, isEmpty);
      expect(registry.activePaneIds, isEmpty);

      registry.registerPane(NavPaneScope.endPane, order: 1);
      expect(notifyCount, equals(1));
      expect(registry.activePaneIds, equals([NavPaneScope.endPane]));

      registry.registerPane(NavPaneScope.startPane, isPrimary: true, order: 0);
      expect(notifyCount, equals(2));

      // startPane has order 0, endPane has order 1 -> startPane is first
      expect(
        registry.activePaneIds,
        equals([NavPaneScope.startPane, NavPaneScope.endPane]),
      );
      expect(registry.primaryPaneId, equals(NavPaneScope.startPane));
      expect(registry.isPrimary(NavPaneScope.startPane), isTrue);
      expect(registry.isPrimary(NavPaneScope.endPane), isFalse);
      expect(registry.hasPane(NavPaneScope.startPane), isTrue);
      expect(registry.hasPane('nonexistent'), isFalse);
    });

    test('re-registering identical entry does not notify', () {
      final registry = NavPaneRegistry();
      registry.registerPane(NavPaneScope.startPane, order: 0);

      int notifyCount = 0;
      registry.addListener(() => notifyCount++);

      registry.registerPane(NavPaneScope.startPane, order: 0);
      expect(notifyCount, equals(0));

      // Updating property does notify
      registry.registerPane(NavPaneScope.startPane, isPrimary: true, order: 0);
      expect(notifyCount, equals(1));
      expect(registry.isPrimary(NavPaneScope.startPane), isTrue);
    });

    test('unregister and clear remove panes and notify', () {
      final registry = NavPaneRegistry();
      registry.registerPane(NavPaneScope.startPane, order: 0);
      registry.registerPane(NavPaneScope.endPane, order: 1);

      int notifyCount = 0;
      registry.addListener(() => notifyCount++);

      registry.unregister(NavPaneScope.startPane);
      expect(notifyCount, equals(1));
      expect(registry.activePaneIds, equals([NavPaneScope.endPane]));

      // Unregistering nonexistent pane does not notify
      registry.unregister('unknown');
      expect(notifyCount, equals(1));

      registry.clear();
      expect(notifyCount, equals(2));
      expect(registry.activePaneIds, isEmpty);
    });
  });
}
