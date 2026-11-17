import 'dart:io';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_scaffold_preset.dart';
import 'tolerant_golden_comparator.dart';

class _Row {
  const _Row(
    this.name,
    this.preset,
    this.bar,
    this.policy, [
    this.dir = TextDirection.ltr,
  ]);
  final String name;
  final FoldSignals preset;
  final NavBarBuilder bar;
  final NavPlacementPolicy policy;
  final TextDirection dir;
}

void main() {
  const apple = ApplePolicy();
  const material = MaterialPolicy();
  final rows = <_Row>[
    _Row(
      'duo_cover_portrait',
      FoldSignalsPresets.duoCoverPortrait,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_cover_landscape',
      FoldSignalsPresets.duoCoverLandscape,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_inner_portrait',
      FoldSignalsPresets.duoInnerPortrait,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_inner_landscape',
      FoldSignalsPresets.duoInnerLandscape,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_book_pose',
      FoldSignalsPresets.duoBookPose,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_split_view_left',
      FoldSignalsPresets.duoSplitViewLeft,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_split_view_right',
      FoldSignalsPresets.duoSplitViewRight,
      cupertinoBarBuilder,
      apple,
    ),
    _Row(
      'duo_cover_landscape_rtl',
      FoldSignalsPresets.duoCoverLandscape,
      cupertinoBarBuilder,
      apple,
      TextDirection.rtl,
    ),
    _Row(
      'android_compact',
      FoldSignalsPresets.androidCompact,
      materialBarBuilder,
      material,
    ),
    _Row(
      'android_medium',
      FoldSignalsPresets.androidMedium,
      materialBarBuilder,
      material,
    ),
    _Row(
      'android_expanded',
      FoldSignalsPresets.androidExpanded,
      materialBarBuilder,
      material,
    ),
    _Row(
      'android_book',
      FoldSignalsPresets.androidBook,
      materialBarBuilder,
      material,
    ),
    _Row(
      'android_tabletop',
      FoldSignalsPresets.androidTabletop,
      materialBarBuilder,
      material,
    ),
    _Row(
      'android_medium_rtl',
      FoldSignalsPresets.androidMedium,
      materialBarBuilder,
      material,
      TextDirection.rtl,
    ),
    _Row(
      'iphone',
      FoldSignalsPresets.regularIphone,
      cupertinoBarBuilder,
      apple,
    ),
    _Row('ipad', FoldSignalsPresets.ipad, cupertinoBarBuilder, apple),
  ];

  setUpAll(useTolerantGoldens);

  for (final r in rows) {
    testWidgets('golden: ${r.name}', skip: !Platform.isMacOS, (tester) async {
      await pumpScaffoldPreset(
        tester,
        r.preset,
        barBuilder: r.bar,
        policy: r.policy,
        direction: r.dir,
      );
      await expectLater(
        find.byType(AdaptiveNavScaffold),
        matchesGoldenFile('goldens/nav_bar_${r.name}.png'),
      );
    });
  }
}
