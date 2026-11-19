// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'dart:io';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_scaffold_preset.dart';
import 'tolerant_golden_comparator.dart';

NavAction _a(String l, IconData i) =>
    NavAction(icon: i, label: l, onPressed: () {});

Widget _detail() {
  return Navigator(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      builder: (_) => AdaptiveNavActions(
        prominentAction: _a('Reply', Icons.reply),
        groups: [
          NavActionGroup([_a('Share', Icons.share), _a('Label', Icons.label)]),
          NavActionGroup([
            _a('Mute', Icons.volume_off),
            _a('Snooze', Icons.snooze),
            _a('Pin', Icons.push_pin),
          ]),
        ],
        overflowItems: [_a('Report', Icons.flag)],
        child: const Material(
          color: Color(0xFFF3F3F3),
          child: Center(child: Text('Detail')),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(useTolerantGoldens);

  final rows = <(String, FoldSignals, NavBarBuilder, NavPlacementPolicy)>[
    (
      'duo_cover_landscape',
      FoldSignalsPresets.duoCoverLandscape,
      cupertinoBarBuilder,
      const ApplePolicy(),
    ),
    (
      'duo_cover_portrait',
      FoldSignalsPresets.duoCoverPortrait,
      cupertinoBarBuilder,
      const ApplePolicy(),
    ),
    (
      'iphone',
      FoldSignalsPresets.regularIphone,
      cupertinoBarBuilder,
      const ApplePolicy(),
    ),
    (
      'android_compact',
      FoldSignalsPresets.androidCompact,
      materialBarBuilder,
      const MaterialPolicy(),
    ),
    (
      'android_medium',
      FoldSignalsPresets.androidMedium,
      materialBarBuilder,
      const MaterialPolicy(),
    ),
  ];

  for (final (name, preset, bar, policy) in rows) {
    testWidgets('golden with actions: $name', skip: !Platform.isMacOS, (
      tester,
    ) async {
      await pumpScaffoldPreset(
        tester,
        preset,
        barBuilder: bar,
        policy: policy,
        body: _detail(),
      );
      await tester.pump();
      await tester.pump();
      await expectLater(
        find.byType(AdaptiveNavScaffold),
        matchesGoldenFile('goldens/nav_bar_actions_$name.png'),
      );
    });
  }

  testWidgets(
    'golden with overflow menu open: duo_cover_landscape',
    skip: !Platform.isMacOS,
    (tester) async {
      await pumpScaffoldPreset(
        tester,
        FoldSignalsPresets.duoCoverLandscape,
        barBuilder: cupertinoBarBuilder,
        policy: const ApplePolicy(),
        body: _detail(),
      );
      await tester.pump();
      await tester.pump();
      await tester.tap(find.text('More'));
      await tester.pump();
      await expectLater(
        find.byType(AdaptiveNavScaffold),
        matchesGoldenFile('goldens/nav_bar_actions_overflow_menu.png'),
      );
    },
  );
}
