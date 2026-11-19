# adaptive_foldable

A design-agnostic Flutter navigation scaffold with a fold kit. It places your navigation bar at the bottom or on a side edge to match the device (iPhone Duo, Android foldables, iPad, phones), keeps page state across fold, unfold and rotation, and leaves the drawing to you.

> Status: `0.1.0-dev.1` pre-release. Verified on the iPhone Duo simulator (Xcode 27.1+) and the Android foldable emulator only; no physical devices have been tested.

## What you get

- `AdaptiveNavScaffold`: resolves a placement from device signals, keeps the body at a fixed position in a stable `Stack`, and hands a resolved `NavLayout` to your `barBuilder`.
- `AdaptiveNavActions`: a page publishes its actions upward. Back, overflow and route-synchronised fades come with it.
- Default Material-style and Cupertino-style bars, built only on `barBuilder` as reference implementations.
- `FoldSignals`, `FakeFoldSignals` and device presets for tests, and a debug overlay.

Runtime dependencies: `flutter` only.

## Install

```yaml
dependencies:
  adaptive_foldable: ^0.1.0-dev.1
```

## Setup

Start the signal bridge once, above the navigator, then use the scaffold at the shell of your app.

```dart
MaterialApp.router(
  routerConfig: router,
  builder: (context, child) => FoldSignalsScope(child: child!),
);

// In a GoRouter StatefulShellRoute builder:
AdaptiveNavScaffold(
  destinations: const [
    NavDestination(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 7),
    NavDestination(icon: Icons.person_outline, label: 'Profile'),
  ],
  selectedIndex: shell.currentIndex,
  onSelected: shell.goBranch,
  body: shell,
)
```

Any router works: pages register actions through the widget tree, not a `NavigatorObserver`. Plain `Navigator`, nested navigators and GoRouter are covered by tests.

## Page actions

```dart
AdaptiveNavActions(
  prominentAction: NavAction(icon: Icons.reply, label: 'Reply', onPressed: reply),
  groups: [
    NavActionGroup([
      NavAction(icon: Icons.share, label: 'Share', priority: NavPriority.high, onPressed: share),
      NavAction(icon: Icons.delete_outline, label: 'Delete', isDestructive: true, onPressed: delete),
    ]),
  ],
  overflowItems: [NavAction(icon: Icons.flag_outlined, label: 'Report', onPressed: report)],
  compression: NavCompression.navigation, // .task minimises the tab bar first
  child: const DetailPage(),
)
```

- Every `NavAction` and `NavDestination` needs an `icon` and a non-empty `label`; the label is the tooltip, overflow entry and screen reader text.
- Actions that do not fit move into an overflow menu, lowest priority and bottom group first. Badged actions rank higher. The menu is `NavOverflowMenu`; pass `overflowBuilder` to replace it, or reuse `NavOverflowMenu` inside your own.
- A page without `AdaptiveNavActions` shows no actions; the tabs stay.
- Back appears when the page's own navigator can pop, and pops that navigator with `maybePop`, so `PopScope` is respected.
- A dialog or sheet leaves the bar in place, dimmed and not tappable.
- On Material placements (Android), the bar holds the tabs and the prominent action; the other actions arrive, already fitted to the screen width with the rest in the overflow menu, in `NavLayout.headerActions`. Draw them in your top app bar with `MaterialNavBar.headerStrip`, which fades with route transitions. The scaffold does not place that strip for you.
- `NavPaneScope` is exported for the coming two-pane fold kit; until then only the main pane is drawn.

## Bring your own bar

The builder receives a resolved layout and only draws it.

```dart
AdaptiveNavScaffold(
  barBuilder: (context, NavLayout layout) => layout.placement.isVertical
      ? MySideColumn(layout)
      : MyBottomBar(layout),
  // ...
)
```

`NavLayout` carries `placement`, `geometry` (bar rectangle, camera region to skip, item axis, home-indicator gap, fold clearance), `showBack`/`onBack`, `prominentAction`, `visibleActions`, `overflowedActions`, `headerActions`, `tabsCompressed`, `destinations`, `selectedIndex`/`onSelected`, `paneCount`, `posture`, `actionsOpacity` and `onOverflow`.

Notes for custom bars:

- Draw items in the order Back, prominent action, groups, overflow, tabs, and give semantics and focus the same order (`OrdinalSortKey`, `FocusTraversalOrder`).
- Keep tap targets at least 44 x 44 logical pixels.
- Multiply the action opacity by `layout.actionsOpacity` while a route transition runs.
- Call `layout.onOverflow` with the global rectangle of your overflow button; the scaffold shows the menu (or your `overflowBuilder`).
- Never hard-code insets: use `layout.geometry`.

## Testing

```dart
final signals = FakeFoldSignals.from(FoldSignalsPresets.duoCoverLandscape);
await tester.pumpWidget(
  MaterialApp(
    builder: (c, child) => FoldSignalsScope(override: signals, child: child!),
    home: AdaptiveNavScaffold(/* ... */),
  ),
);
```

No platform channel is touched. Presets cover the iPhone Duo cover and inner displays, book pose, Split View, Android compact, medium, expanded, book and tabletop, iPhone and iPad.

## Requirements

| Requirement | Minimum |
| --- | --- |
| Flutter | 3.47 |
| Dart | 3.13 |
| iOS deployment target | 15.0 |
| Xcode | any; Duo features need 27.1+ |
| Android | Flutter's default `minSdk`; no Android native code |
| iOS build systems | Swift Package Manager and CocoaPods |

## Xcode 27.1 toolchain workarounds

Two build problems are unrelated to this package:

1. Flutter pods that still declare iOS 13.0. Raise them in your `ios/Podfile`:

   ```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       flutter_additional_ios_build_settings(target)
       target.build_configurations.each do |config|
         config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
       end
     end
   end
   ```

2. `lipo` failing on dual-architecture simulator builds with older Flutter. Build the simulator for arm64 only: set `ARCHS = arm64` (and exclude `x86_64`) in the Runner target's build settings.

## Hardware feedback checklist

Simulators cannot prove real timing of reserved-region updates, touch accuracy near the crease, real hinge transitions or performance. If you have a device, please report with a screenshot of the debug overlay (`debugOverlay: true`):

- [ ] Column starts below the camera on the cover display.
- [ ] Bar never overlaps the fold in book pose.
- [ ] One `onLayoutChanged` event per fold or unfold.
- [ ] No flicker of the bar while the hinge moves.
- [ ] Taps near the crease land on the intended item.
