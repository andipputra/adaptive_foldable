import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FoldAlignedGrid', () {
    testWidgets('flat mode renders standard grid with all items', (
      tester,
    ) async {
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: FoldAlignedGrid(
                itemCount: 8,
                crossAxisCountPerPane: 2,
                itemBuilder: (context, index) => Text('Item $index'),
              ),
            ),
          ),
        ),
      );

      for (int i = 0; i < 8; i++) {
        expect(find.text('Item $i'), findsOneWidget);
      }
    });

    testWidgets('book pose ensures ZERO item overlap with fold rectangle', (
      tester,
    ) async {
      // Screen width 800, fold at [380, 420]
      final foldRect = const Rect.fromLTWH(380, 0, 40, 600);
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: [foldRect],
        posture: Posture.partiallyOpen,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: FoldAlignedGrid(
                itemCount: 12,
                crossAxisCountPerPane: 2,
                itemBuilder: (context, index) => Container(
                  key: ValueKey('tile_$index'),
                  color: Colors.blue,
                  child: Text('Tile $index'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify visible tiles do not intersect foldRect
      for (int i = 0; i < 8; i++) {
        final tileFinder = find.byKey(ValueKey('tile_$i'));
        expect(tileFinder, findsOneWidget);

        final tileRect = tester.getRect(tileFinder);
        final intersects = tileRect.overlaps(foldRect);
        expect(
          intersects,
          isFalse,
          reason: 'Tile $i ($tileRect) overlaps fold ($foldRect)',
        );

        // Tile must either be completely on the left or completely on the right
        final onLeft = tileRect.right <= foldRect.left;
        final onRight = tileRect.left >= foldRect.right;
        expect(
          onLeft || onRight,
          isTrue,
          reason: 'Tile $i must be strictly left or right of fold',
        );
      }
    });

    testWidgets('scroll controller scrolls items smoothly', (tester) async {
      final foldRect = const Rect.fromLTWH(380, 0, 40, 600);
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: [foldRect],
        posture: Posture.partiallyOpen,
      );

      final controller = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: FoldSignalsScope(
            override: signals,
            child: Scaffold(
              body: FoldAlignedGrid(
                controller: controller,
                itemCount: 40,
                crossAxisCountPerPane: 2,
                itemBuilder: (context, index) =>
                    SizedBox(height: 100, child: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Item 0'), findsOneWidget);
      expect(controller.offset, equals(0.0));

      await tester.drag(find.text('Item 0'), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(0.0));
    });

    testWidgets('mirrors items under RTL text direction', (tester) async {
      final foldRect = const Rect.fromLTWH(380, 0, 40, 600);
      final signals = FakeFoldSignals(
        viewSize: const Size(800, 600),
        activeFolds: [foldRect],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: FoldSignalsScope(
              override: signals,
              child: Scaffold(
                body: FoldAlignedGrid(
                  itemCount: 4,
                  crossAxisCountPerPane: 1,
                  itemBuilder: (context, index) => Text('RTL Item $index'),
                ),
              ),
            ),
          ),
        ),
      );

      final item0Pos = tester.getTopLeft(find.text('RTL Item 0'));
      final item1Pos = tester.getTopLeft(find.text('RTL Item 1'));

      // In RTL, Item 0 starts on the leading (right) side
      expect(item0Pos.dx, greaterThan(item1Pos.dx));
    });
  });
}
