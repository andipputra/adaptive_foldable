import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const icon = IconData(0xe156, fontFamily: 'MaterialIcons');

  group('NavOverflowMenu', () {
    testWidgets('dismisses when Escape key is pressed', (tester) async {
      bool dismissed = false;
      final action = NavAction(icon: icon, label: 'Settings', onPressed: () {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: NavOverflowMenu(
              items: [action],
              anchor: const Rect.fromLTWH(100, 100, 48, 48),
              dismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('scales row height with textScaler', (tester) async {
      final action = NavAction(icon: icon, label: 'Settings', onPressed: () {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 600),
              textScaler: TextScaler.linear(2.0),
            ),
            child: NavOverflowMenu(
              items: [action],
              anchor: const Rect.fromLTWH(100, 100, 48, 48),
              dismiss: () {},
            ),
          ),
        ),
      );

      final rowFinder = find.ancestor(
        of: find.text('Settings'),
        matching: find.byType(SizedBox),
      );
      final sizes = tester
          .widgetList<SizedBox>(rowFinder)
          .map((s) => s.height)
          .whereType<double>();
      expect(sizes.any((h) => h >= 96.0), isTrue);
    });

    testWidgets('contains FocusTraversalGroup for keyboard navigation', (
      tester,
    ) async {
      final action = NavAction(icon: icon, label: 'Settings', onPressed: () {});

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: NavOverflowMenu(
              items: [action],
              anchor: const Rect.fromLTWH(100, 100, 48, 48),
              dismiss: () {},
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(NavOverflowMenu),
          matching: find.byType(FocusTraversalGroup),
        ),
        findsWidgets,
      );
    });
  });
}
