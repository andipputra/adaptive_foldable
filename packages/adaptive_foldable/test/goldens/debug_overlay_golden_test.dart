// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'dart:io';

import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('debug overlay golden on duoBookPose', skip: !Platform.isMacOS, (
    tester,
  ) async {
    tester.view.physicalSize = const Size(951, 669);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final fake = FakeFoldSignals.from(FoldSignalsPresets.duoBookPose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: FoldSignalsScope(
          override: fake,
          child: const FoldDebugOverlay(
            isDebugMode: true,
            enabled: true,
            ruleLabel: 'DuoBookPoseRule',
            child: ColoredBox(
              color: Color(0xFF1E1E1E),
              child: SizedBox.expand(
                child: Center(
                  child: Text(
                    'Duo Book Pose Screen Content',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(FoldDebugOverlay),
      matchesGoldenFile('goldens/debug_overlay_duo_book_pose.png'),
    );
  });
}
