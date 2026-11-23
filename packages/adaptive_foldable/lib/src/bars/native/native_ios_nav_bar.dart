import 'dart:async';

import 'package:adaptive_foldable/src/bars/cupertino/cupertino_style_nav_bar.dart';
import 'package:adaptive_foldable/src/bars/native/icon_png.dart';
import 'package:adaptive_foldable/src/bars/native/native_bar_params.dart';
import 'package:adaptive_foldable/src/bars/nav_bar_content.dart';
import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' show PlatformViewHitTestBehavior;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// `barBuilder` that draws [NativeIosNavBar]: a real `UITabBar` on iOS, the Cupertino-style Flutter bar elsewhere.
Widget nativeIosBarBuilder(BuildContext context, NavLayout layout) =>
    NativeIosNavBar.supports(layout)
    ? NativeIosNavBar(layout: layout)
    : cupertinoBarBuilder(context, layout);

/// Bottom bar whose tabs are a native iOS `UITabBar` hosted as a platform view.
///
/// Back, the prominent action, action groups and the overflow button stay
/// Flutter items drawn before the tabs. The native view is not cut around the
/// fold. Side columns (a `UITabBar` is horizontal) and compressed tabs use the Flutter bar, see [supports].
class NativeIosNavBar extends StatefulWidget {
  /// Creates the bar for [layout]; use [supports] first, or [nativeIosBarBuilder].
  const NativeIosNavBar({super.key, required this.layout});

  /// The resolved layout.
  final NavLayout layout;

  /// Whether [layout] can use the native bar on this platform.
  static bool supports(NavLayout layout) =>
      defaultTargetPlatform == TargetPlatform.iOS &&
      !kIsWeb &&
      !layout.placement.isVertical &&
      !layout.tabsCompressed &&
      layout.destinations.isNotEmpty;

  @override
  State<NativeIosNavBar> createState() => _NativeIosNavBarState();
}

class _NativeIosNavBarState extends State<NativeIosNavBar> {
  MethodChannel? _channel;
  Map<int, ({List<int>? icon, List<int>? selectedIcon})> _icons = const {};
  Object? _iconsKey;

  @override
  void initState() {
    super.initState();
    unawaited(_loadIcons());
  }

  @override
  void didUpdateWidget(NativeIosNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_loadIcons());
    _push();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  Map<String, Object?> get _params => buildNativeBarParams(
    destinations: widget.layout.destinations,
    selectedIndex: widget.layout.selectedIndex,
    icons: _icons,
  );

  void _push() => unawaited(_channel?.invokeMethod<void>('update', _params));

  Future<void> _loadIcons() async {
    final dests = widget.layout.destinations;
    final key = Object.hashAll([
      for (final d in dests) ...[d.icon, d.selectedIcon, d.sfSymbol],
    ]);
    if (key == _iconsKey) return;
    _iconsKey = key;
    final icons = <int, ({List<int>? icon, List<int>? selectedIcon})>{};
    for (var i = 0; i < dests.length; i++) {
      final d = dests[i];
      if (d.sfSymbol != null) continue;
      icons[i] = (
        icon: await renderIconPng(d.icon),
        selectedIcon: d.selectedIcon == null
            ? null
            : await renderIconPng(d.selectedIcon!),
      );
    }
    if (!mounted || key != _iconsKey) return;
    setState(() => _icons = icons);
    _push();
  }

  void _onCreated(int id) {
    _channel = MethodChannel('$kNativeBarViewType/$id')
      ..setMethodCallHandler((call) async {
        if (call.method == 'onSelected') {
          widget.layout.onSelected?.call(call.arguments as int);
        }
      });
    _push();
  }

  @override
  Widget build(BuildContext context) {
    final leading = buildNavBarItems(
      widget.layout.copyWith(destinations: const []),
      defaultColors(context),
      tabsExpand: false,
    );
    final native = Semantics(
      container: true,
      child: UiKitView(
        viewType: kNativeBarViewType,
        creationParams: _params,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onCreated,
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      ),
    );
    return navBarTraversalGroup(
      child: Row(
        children: [
          ...leading,
          Expanded(child: native),
        ],
      ),
    );
  }

  /// iOS system colours, shared with the Flutter bar so leading items match.
  static NavBarColors defaultColors(BuildContext context) =>
      CupertinoStyleNavBar.defaultColors(context);
}
