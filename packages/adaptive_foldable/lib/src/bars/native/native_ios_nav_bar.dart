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

/// `barBuilder` that draws [NativeIosNavBar]: native UIKit on iOS, the Cupertino-style Flutter bar elsewhere.
Widget nativeIosBarBuilder(BuildContext context, NavLayout layout) =>
    NativeIosNavBar.supports(layout)
    ? NativeIosNavBar(layout: layout)
    : cupertinoBarBuilder(context, layout);

/// Native iOS bar hosted as a platform view.
///
/// Bottom placement: a `UITabBar` for the tabs, with Back, actions and overflow
/// drawn by Flutter before it. Side placement (iPhone Duo): a Liquid Glass
/// column with Back, actions, overflow and an icon-only tab capsule, all native.
/// The native view is not cut around the fold. Compressed tabs use the Flutter
/// bar, see [supports].
class NativeIosNavBar extends StatefulWidget {
  /// Creates the bar for [layout]; use [supports] first, or [nativeIosBarBuilder].
  const NativeIosNavBar({super.key, required this.layout});

  /// The resolved layout.
  final NavLayout layout;

  /// Whether [layout] can use the native bar on this platform.
  static bool supports(NavLayout layout) =>
      defaultTargetPlatform == TargetPlatform.iOS &&
      !kIsWeb &&
      !layout.tabsCompressed &&
      layout.destinations.isNotEmpty;

  @override
  State<NativeIosNavBar> createState() => _NativeIosNavBarState();
}

class _NativeIosNavBarState extends State<NativeIosNavBar> {
  MethodChannel? _channel;
  NativeIconPngs _icons = const {};
  Object? _iconsKey;

  bool get _vertical => widget.layout.placement.isVertical;

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

  Map<String, Object?> get _params => _vertical
      ? buildNativeColumnParams(widget.layout, icons: _icons)
      : buildNativeBarParams(
          destinations: widget.layout.destinations,
          selectedIndex: widget.layout.selectedIndex,
          icons: _icons,
        );

  void _push() => unawaited(_channel?.invokeMethod<void>('update', _params));

  Future<void> _loadIcons() async {
    final needed = nativeIconsNeeded(widget.layout);
    final key = Object.hashAllUnordered(needed);
    if (key == _iconsKey) return;
    _iconsKey = key;
    final icons = <IconData, List<int>>{
      for (final icon in needed) icon: await renderIconPng(icon),
    };
    if (!mounted || key != _iconsKey) return;
    setState(() => _icons = icons);
    _push();
  }

  void _onCreated(int id) {
    _channel = MethodChannel('$kNativeBarViewType/$id')
      ..setMethodCallHandler((call) async {
        final layout = widget.layout;
        switch (call.method) {
          case 'onSelected':
            layout.onSelected?.call(call.arguments as int);
          case 'onTap':
            final args = call.arguments as Map<Object?, Object?>;
            final r = args['rect'];
            final rect = r is List && r.length == 4
                ? Rect.fromLTWH(
                    (r[0] as num).toDouble(),
                    (r[1] as num).toDouble(),
                    (r[2] as num).toDouble(),
                    (r[3] as num).toDouble(),
                  )
                : Rect.zero;
            resolveNativeTap(
              args['id']! as String,
              layout,
              overflowRect: rect,
            )?.call();
        }
      });
    _push();
  }

  @override
  Widget build(BuildContext context) {
    final colors = CupertinoStyleNavBar.defaultColors(context);
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
    if (_vertical) {
      return ColoredBox(
        color: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? const Color(0xFF000000)
            : const Color(0xFFFFFFFF),
        child: native,
      );
    }
    final leading = buildNavBarItems(
      widget.layout.copyWith(destinations: const []),
      colors,
      tabsExpand: false,
    );
    return navBarTraversalGroup(
      child: ColoredBox(
        color: colors.background,
        child: Row(
          children: [
            ...leading,
            Expanded(child: native),
          ],
        ),
      ),
    );
  }
}
