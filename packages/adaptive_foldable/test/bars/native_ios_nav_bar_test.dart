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
        _icon: [1],
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

  test('supports only iOS with uncompressed tabs', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(NativeIosNavBar.supports(_layout()), isTrue);
    expect(
      NativeIosNavBar.supports(
        _layout(placement: const NavPlacement(NavEdge.right)),
      ),
      isTrue,
    );
    expect(
      NativeIosNavBar.supports(
        _layout(placement: const NavPlacement(NavEdge.right)),
      ),
      isTrue,
    );
    expect(NativeIosNavBar.supports(_layout(compressed: true)), isFalse);
    expect(NativeIosNavBar.supports(_layout(destinations: const [])), isFalse);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(NativeIosNavBar.supports(_layout()), isFalse);
  });

  group('native column', () {
    var taps = <String>[];
    NavLayout column() => NavLayout(
      placement: const NavPlacement(NavEdge.right),
      geometry: NavGeometry(barRect: Rect.zero, itemAxis: NavAxis.vertical),
      showBack: true,
      onBack: () => taps.add('back'),
      prominentAction: NavAction(
        icon: _icon,
        label: 'Reply',
        onPressed: () => taps.add('reply'),
      ),
      visibleActions: [
        NavActionGroup([
          NavAction(
            icon: _icon,
            label: 'Share',
            sfSymbol: 'square.and.arrow.up',
            onPressed: () => taps.add('share'),
          ),
        ]),
      ],
      onOverflow: (rect) => taps.add('overflow ${rect.width}'),
      destinations: const [
        NavDestination(icon: _icon, label: 'A', sfSymbol: 'house'),
        NavDestination(icon: _icon, label: 'B', sfSymbol: 'tray'),
      ],
      selectedIndex: 1,
      onSelected: (i) => taps.add('tab $i'),
    );

    setUp(() => taps = []);

    test('groups follow Back, prominent, groups, overflow, tabs', () {
      final groups = buildNativeColumnParams(column())['groups']! as List;
      final ids = [
        for (final g in groups)
          for (final i in (g as Map)['items'] as List) (i as Map)['id'],
      ];
      expect(ids, ['back', 'prominent', 'a:0:0', 'overflow', 'tab:0', 'tab:1']);
      expect((groups.last as Map)['role'], 'tabs');
      final tabs = (groups.last as Map)['items'] as List;
      expect((tabs[1] as Map)['selected'], isTrue);
    });

    test('taps resolve to the matching callbacks', () {
      final layout = column();
      for (final id in ['back', 'prominent', 'a:0:0', 'tab:0']) {
        resolveNativeTap(id, layout)!();
      }
      resolveNativeTap(
        'overflow',
        layout,
        overflowRect: const Rect.fromLTWH(0, 0, 9, 9),
      )!();
      expect(taps, ['back', 'reply', 'share', 'tab 0', 'overflow 9.0']);
    });

    test('unknown or out-of-range ids resolve to null', () {
      final layout = column();
      for (final id in ['x', 'tab:9', 'tab:x', 'a:3:0', 'a:0:4', 'a:0']) {
        expect(resolveNativeTap(id, layout), isNull, reason: id);
      }
    });

    test('only icons without an SF Symbol need PNGs', () {
      expect(nativeIconsNeeded(column()), {_icon});
    });
  });
}
