# adaptive_foldable

A design-agnostic Flutter navigation scaffold with a fold kit. It places your navigation bar at the bottom or on a side edge to match the device (iPhone Duo, Android foldables, iPad, phones), keeps page state across fold, unfold and rotation, and leaves the drawing to you.

> **Status: 1.0.0 (simulator-verified)**
> Verified on the iPhone Duo simulator (Xcode 27.1+) and Android foldable emulator. No physical devices were used during initial verification. See [Hardware Feedback Checklist](https://github.com/andipputra/adaptive_foldable/blob/main/docs/hardware_feedback_checklist.md) if running on physical hardware.

---

## Architectural Positioning

Most adaptive navigation packages force either Material or Cupertino widgets onto your view hierarchy, or lack foldable hardware awareness entirely. `adaptive_foldable` separates device signal resolution from UI rendering:

| Capability | `adaptive_foldable` | `adaptive_platform_ui` | `foldable` | `iphone_duo_ui_pro` |
|---|---|---|---|---|
| **Design-agnostic (`barBuilder`)** | **Yes** (bring your own bar) | No (fixed platform widgets) | N/A (no nav scaffold) | No |
| **iPhone Duo native column bridge** | **Yes** (native `verticalBarEdge` + reserved regions) | No | No | Partial (opinionated view) |
| **Android fold / hinge awareness** | **Yes** (`DisplayFeature` safe areas) | No | Yes | No |
| **Stable Stack (zero state loss)** | **Yes** (body never reparented) | No | N/A | No |
| **Per-page actions & overflow** | **Yes** (`AdaptiveNavActions` + priority sorting) | No | No | No |
| **Fold kit (panes, grid, dialogs)** | **Yes** (two-pane, aligned grid, pane targeting) | No | Partial | No |
| **Runtime dependencies** | **`flutter` only** | Multiple external dependencies | External dependencies | Platform views |

---

## Quick Start

### 1. Wrap your app in `FoldSignalsScope`

Place `FoldSignalsScope` above your navigator or router to listen to platform bridge and display signals once:

```dart
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => FoldSignalsScope(child: child!),
      home: const MainShell(),
    );
  }
}
```

### 2. Add `AdaptiveNavScaffold`

```dart
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _destinations = [
    NavDestination(icon: Icons.inbox_outlined, label: 'Inbox', badgeCount: 3),
    NavDestination(icon: Icons.search, label: 'Search'),
    NavDestination(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AdaptiveNavScaffold(
      destinations: _destinations,
      selectedIndex: _currentIndex,
      onSelected: (index) => setState(() => _currentIndex = index),
      body: Center(child: Text('Selected index: $_currentIndex')),
    );
  }
}
```

By default, the scaffold uses platform-adaptive reference bars:
- iOS / macOS: `cupertinoBarBuilder` (Cupertino-styled bottom bar or vertical side column).
- Android / other: `materialBarBuilder` (Material 3 NavigationBar or NavigationRail).

---

## Bring Your Own Bar (`barBuilder`)

Pass a custom `barBuilder` callback to render custom branding or components. The builder receives a pure, pre-calculated `NavLayout`:

```dart
AdaptiveNavScaffold(
  destinations: _destinations,
  selectedIndex: _currentIndex,
  onSelected: (index) => setState(() => _currentIndex = index),
  barBuilder: (context, NavLayout layout) {
    if (layout.placement.isVertical) {
      return MyCustomRail(layout: layout);
    }
    return MyCustomBottomBar(layout: layout);
  },
  body: const MyContent(),
)
```

### Writing Custom Bars

`NavLayout` supplies all layout coordinates and resolved action collections:
- `layout.geometry`: exact bar frame (`barRect`), camera clearance (`skipRegion`), home indicator padding (`homeIndicatorGap`), and fold cut distance (`foldClearance`). Never hardcode screen insets.
- `layout.placement.isVertical`: whether the bar is positioned as a leading/trailing column or a bottom bar.
- `layout.visibleActions` / `layout.overflowedActions`: actions resolved for the current screen width.
- `layout.onOverflow`: trigger function to open the overflow menu relative to an anchor rectangle.
- Focus and semantics: keep accessibility traversal in order: Back button, prominent action, action groups, overflow button, destinations.

---

## Per-Page Actions

Inner views publish action items to the shell navigation scaffold without coupling to router state:

```dart
AdaptiveNavActions(
  prominentAction: NavAction(
    icon: Icons.add,
    label: 'Compose',
    onPressed: () => openComposer(),
  ),
  groups: [
    NavActionGroup([
      NavAction(
        icon: Icons.archive_outlined,
        label: 'Archive',
        priority: NavPriority.high,
        onPressed: () => archiveItem(),
      ),
      NavAction(
        icon: Icons.delete_outline,
        label: 'Delete',
        isDestructive: true,
        onPressed: () => deleteItem(),
      ),
    ]),
  ],
  compression: NavCompression.navigation, // Collapse tabs first when space is tight
  child: const MessageList(),
)
```

- **Back Button**: Appears automatically whenever the current page navigator can pop (`canPop()`), triggering `maybePop()` to honour `PopScope`.
- **Overflow**: When actions exceed available width, lower-priority and later groups automatically move into the overflow menu.

---

## Placement Policies

Control how placement resolves on different screen sizes and postures:

```dart
// Enforce Material 3 size classes across all platforms
AdaptiveNavScaffold(
  policy: const MaterialPolicy(),
  // ...
)
```

- `ApplePolicy` (default on iOS/macOS): Prefers hardware-aligned trailing columns on iPhone Duo and bottom bars on standard phones.
- `MaterialPolicy` (default on Android/Linux/Windows): Uses bottom bars on compact widths and leading navigation rails on expanded widths.

### Custom Policies

Implement `NavPlacementPolicy` for bespoke adaptive rules:

```dart
class DesktopFirstPolicy implements NavPlacementPolicy {
  const DesktopFirstPolicy();

  @override
  NavPlacement resolvePlacement({
    required FoldSignals signals,
    required bool hasProminentAction,
    required int actionCount,
    required int destinationCount,
  }) {
    if (signals.horizontalSizeClass == SizeClass.expanded) {
      return const NavPlacement.leadingColumn();
    }
    return const NavPlacement.bottomBar();
  }
}
```

---

## Fold Kit

`adaptive_foldable` includes pure Flutter layout primitives designed for foldables:

### 1. `FoldAwareTwoPane`

Splits primary and secondary content across the hinge in book posture or landscape:

```dart
FoldAwareTwoPane(
  primaryPane: const ListPane(),
  secondaryPane: const DetailPane(),
  panePriority: TwoPanePriority.both,
)
```

### 2. `FoldAlignedGrid`

A grid that splits columns around the fold line so cards never get cut in half:

```dart
FoldAlignedGrid(
  itemCount: items.length,
  maxCrossAxisExtent: 220,
  itemBuilder: (context, index) => ItemCard(item: items[index]),
)
```

### 3. Fold-Aware Dialogs and Bottom Sheets

Anchor dialogs and sheets to a specific pane when the device is unfolded:

```dart
// Opens the dialog centered inside the secondary pane
showFoldAwareDialog(
  context: context,
  target: FoldPaneTarget.secondary,
  builder: (context) => const AlertDialog(title: Text('Details')),
);

// Opens modal bottom sheet inside the primary pane
showFoldAwareModalBottomSheet(
  context: context,
  target: FoldPaneTarget.primary,
  builder: (context) => const FilterOptionsSheet(),
);
```

---

## Hardware Feedback Checklist

Simulators cannot test physical hinge latency, crease touch distortion, or thermal performance. If testing on physical foldable hardware, refer to the [Hardware Feedback Checklist](https://github.com/andipputra/adaptive_foldable/blob/main/docs/hardware_feedback_checklist.md).

Enable the diagnostic overlay in debug builds:
```dart
AdaptiveNavScaffold(
  debugOverlay: true,
  // ...
)
```

---

## Requirements

- Flutter: `>=3.47.0`
- Dart: `^3.13.0`
- iOS deployment target: `15.0+`
- Xcode: `27.1+` for iPhone Duo simulator and native bridge headers
