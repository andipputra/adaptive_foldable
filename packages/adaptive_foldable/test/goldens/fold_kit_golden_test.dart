// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'dart:io';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'tolerant_golden_comparator.dart';

void main() {
  setUpAll(useTolerantGoldens);

  group('fold kit goldens', skip: !Platform.isMacOS, () {
    testWidgets('FoldAwareTwoPane book pose', (tester) async {
      tester.view.physicalSize = const Size(951, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: FoldSignalsScope(
            override: fake,
            child: Scaffold(
              body: FoldAwareTwoPane(
                start: Container(
                  color: const Color(0xFFE8EAF6),
                  child: const Center(
                    child: Text(
                      'Primary / List Pane',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                end: Container(
                  color: const Color(0xFFEDE7F6),
                  child: const Center(
                    child: Text(
                      'Secondary / Detail Pane',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FoldAwareTwoPane),
        matchesGoldenFile('goldens/fold_two_pane_book_pose.png'),
      );
    });

    testWidgets('FoldAwareTwoPane book pose RTL', (tester) async {
      tester.view.physicalSize = const Size(951, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: FoldSignalsScope(
              override: fake,
              child: Scaffold(
                body: FoldAwareTwoPane(
                  start: Container(
                    color: const Color(0xFFE8EAF6),
                    child: const Center(
                      child: Text(
                        'Start RTL Pane',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  end: Container(
                    color: const Color(0xFFEDE7F6),
                    child: const Center(
                      child: Text(
                        'End RTL Pane',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FoldAwareTwoPane),
        matchesGoldenFile('goldens/fold_two_pane_book_pose_rtl.png'),
      );
    });

    testWidgets('FoldAwareTwoPane Split View left', (tester) async {
      tester.view.physicalSize = const Size(455.5, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoSplitViewLeft);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: FoldSignalsScope(
            override: fake,
            child: Scaffold(
              body: FoldAwareTwoPane(
                priority: TwoPanePriority.start,
                start: Container(
                  color: const Color(0xFFE8EAF6),
                  child: const Center(child: Text('Split View Left Pane')),
                ),
                end: Container(
                  color: const Color(0xFFEDE7F6),
                  child: const Center(child: Text('Hidden Detail')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FoldAwareTwoPane),
        matchesGoldenFile('goldens/fold_two_pane_split_view_left.png'),
      );
    });

    testWidgets('FoldAwareTwoPane Split View right', (tester) async {
      tester.view.physicalSize = const Size(455.5, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoSplitViewRight);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: FoldSignalsScope(
            override: fake,
            child: Scaffold(
              body: FoldAwareTwoPane(
                priority: TwoPanePriority.end,
                start: Container(
                  color: const Color(0xFFE8EAF6),
                  child: const Center(child: Text('Hidden List')),
                ),
                end: Container(
                  color: const Color(0xFFEDE7F6),
                  child: const Center(child: Text('Split View Right Pane')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FoldAwareTwoPane),
        matchesGoldenFile('goldens/fold_two_pane_split_view_right.png'),
      );
    });

    testWidgets('FoldAlignedGrid book pose', (tester) async {
      tester.view.physicalSize = const Size(951, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
          home: FoldSignalsScope(
            override: fake,
            child: Scaffold(
              body: FoldAlignedGrid(
                itemCount: 8,
                crossAxisCountPerPane: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (context, index) => Card(
                  color: Colors.teal.shade100,
                  child: Center(
                    child: Text(
                      'Tile $index',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await expectLater(
        find.byType(FoldAlignedGrid),
        matchesGoldenFile('goldens/fold_aligned_grid_book_pose.png'),
      );
    });

    testWidgets('FoldAwareDialog anchored start and end', (tester) async {
      tester.view.physicalSize = const Size(951, 669);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.purple),
          home: FoldSignalsScope(
            override: fake,
            child: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    showFoldAwareDialog(
                      context: context,
                      target: FoldPaneTarget.end,
                      builder: (ctx) => const AlertDialog(
                        title: Text('Anchored Dialog'),
                        content: Text('Anchored strictly to end pane.'),
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/fold_dialog_anchored_end.png'),
      );
    });
  });
}
