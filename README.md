# adaptive_foldable

A design-agnostic Flutter navigation scaffold with a fold kit. It places your navigation bar at the bottom or on a side edge to match the device (iPhone Duo, Android foldables, iPad, phones), keeps page state across fold, unfold and rotation, and leaves the drawing to you.

> **Status: 1.0.0 (simulator-verified)**
> Verified on the iPhone Duo simulator (Xcode 27.1+) and Android foldable emulator. No physical devices were used during initial verification. See [Hardware Feedback Checklist](docs/hardware_feedback_checklist.md) if running on physical hardware.

---

## Workspace Structure

- `packages/adaptive_foldable/`: The core Flutter plugin package (`flutter` runtime dependency only).
- `packages/adaptive_foldable/example/`: Example demonstration application showing standard, two-pane, and custom layouts.

---

## Architectural Positioning

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

---

## Toolchain Notes

### iOS Deployment Target
iOS deployment target is 15.0 or higher. In your iOS `Podfile`, ensure the platform is set accordingly:
```ruby
platform :ios, '15.0'
```

### Xcode 27.1+ and Simulator Builds
- Compiling against iPhone Duo APIs requires Xcode 27.1 or later.
- If dual-architecture simulator builds encounter `lipo` issues on older Flutter toolchains, restrict simulator architectures in Podfile or Xcode build settings:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ARCHS[sdk=iphonesimulator*]'] = 'arm64'
    end
  end
end
```

---

## Hardware Feedback

Simulators cannot verify hardware timing or crease touch accuracy. If you have physical foldable hardware, please consult the [Hardware Feedback Checklist](docs/hardware_feedback_checklist.md).
