// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const goldenDestinations = [
  NavDestination(
    icon: Icons.home_outlined,
    label: 'Home',
    selectedIcon: Icons.home,
  ),
  NavDestination(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 7),
  NavDestination(icon: Icons.person_outline, label: 'Me'),
];

/// Pumps an [AdaptiveNavScaffold] on [preset] at its own view size with the given bar and policy.
Future<void> pumpScaffoldPreset(
  WidgetTester tester,
  FoldSignals preset, {
  required NavBarBuilder barBuilder,
  required NavPlacementPolicy policy,
  TextDirection direction = TextDirection.ltr,
  Widget? body,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = preset.viewSize;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      builder: (context, child) => Directionality(
        textDirection: direction,
        child: FoldSignalsScope(
          override: FakeFoldSignals.from(preset),
          child: child!,
        ),
      ),
      home: AdaptiveNavScaffold(
        destinations: goldenDestinations,
        selectedIndex: 1,
        onSelected: (_) {},
        policy: policy,
        barBuilder: barBuilder,
        debugOverlay: false,
        body:
            body ??
            const Material(
              color: Color(0xFFF3F3F3),
              child: Center(child: Text('Body')),
            ),
      ),
    ),
  );
  await tester.pump();
}
