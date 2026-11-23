import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable/src/bars/native/native_bar_params.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const _icon = IconData(0xe000, fontFamily: 'MaterialIcons');

NavLayout _layout({
  NavPlacement placement = const NavPlacement(NavEdge.bottom),
  bool compressed = false,
  List<NavDestination> destinations = const [
    NavDestination(icon: _icon, label: 'Home', sfSymbol: 'house'),
  ],
}) => NavLayout(
  placement: placement,
  geometry: NavGeometry(barRect: Rect.zero, itemAxis: NavAxis.horizontal),
  tabsCompressed: compressed,
  destinations: destinations,
);

void main() {
  test('params carry labels, symbols, badges and selection', () {
    final params = buildNativeBarParams(
      destinations: const [
        NavDestination(icon: _icon, label: 'A', sfSymbol: 'house'),
        NavDestination(icon: _icon, label: 'B', badgeCount: 3),
      ],
      selectedIndex: 1,
      icons: {
        1: (icon: [1], selectedIcon: null),
      },
    );
    final items = params['items']! as List;
    expect(params['selectedIndex'], 1);
    expect((items[0] as Map)['sfSymbol'], 'house');
    expect((items[1] as Map)['badge'], 3);
    expect((items[1] as Map)['icon'], [1]);
  });

  test('sfSymbol takes part in equality', () {
    const a = NavDestination(icon: _icon, label: 'A', sfSymbol: 'house');
    expect(a, const NavDestination(icon: _icon, label: 'A', sfSymbol: 'house'));
    expect(a == const NavDestination(icon: _icon, label: 'A'), isFalse);
    expect(a.copyWith(clearSfSymbol: true).sfSymbol, isNull);
  });

  test('supports only iOS bottom bars with uncompressed tabs', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(NativeIosNavBar.supports(_layout()), isTrue);
    expect(
      NativeIosNavBar.supports(
        _layout(placement: const NavPlacement(NavEdge.right)),
      ),
      isFalse,
    );
    expect(
      NativeIosNavBar.supports(
        _layout(placement: const NavPlacement(NavEdge.right)),
      ),
      isFalse,
    );
    expect(NativeIosNavBar.supports(_layout(compressed: true)), isFalse);
    expect(NativeIosNavBar.supports(_layout(destinations: const [])), isFalse);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(NativeIosNavBar.supports(_layout()), isFalse);
  });
}
