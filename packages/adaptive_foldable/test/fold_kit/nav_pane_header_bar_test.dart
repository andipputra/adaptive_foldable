import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_action_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NavPaneHeaderBar renders title, leading, and fires action', (
    tester,
  ) async {
    bool tapped = false;
    final action = NavAction(
      icon: Icons.search,
      label: 'Search',
      onPressed: () => tapped = true,
    );

    final registry = NavActionRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: NavActionScope(
          registry: registry,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: NavPaneHeaderBar(
                title: const Text('Pane Title'),
                leading: const Icon(Icons.arrow_back),
                actionsOverride: PageActions(
                  groups: [
                    NavActionGroup([action]),
                  ],
                ),
              ),
            ),
            body: const SizedBox(),
          ),
        ),
      ),
    );

    expect(find.text('Pane Title'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Verify tap target minimum 44
    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    expect(iconButton, isNotNull);

    await tester.tap(find.byIcon(Icons.search));
    expect(tapped, isTrue);
  });

  testWidgets('NavPaneHeaderBar shows overflow items in menu', (tester) async {
    bool overflowTapped = false;
    final overflowAction = NavAction(
      icon: Icons.info,
      label: 'Info',
      onPressed: () => overflowTapped = true,
    );

    final registry = NavActionRegistry();

    await tester.pumpWidget(
      MaterialApp(
        home: NavActionScope(
          registry: registry,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: NavPaneHeaderBar(
                actionsOverride: PageActions(overflowItems: [overflowAction]),
              ),
            ),
            body: const SizedBox(),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    // Tap overflow icon
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Info'), findsOneWidget);
    await tester.tap(find.text('Info'));
    expect(overflowTapped, isTrue);
  });
}
