---
name: Bug Report
about: Report a bug or incorrect navigation layout behavior
title: '[BUG] '
labels: bug
assignees: ''
---

## Description
A clear and concise description of what the bug is.

## Device & Environment Information
- **Hardware / Simulator**: [e.g. Physical iPhone Duo, iPhone Duo Simulator (Xcode 27.1+), Samsung Galaxy Z Fold 6, Android Foldable Emulator]
- **OS Version**: [e.g. iOS 27.1, Android 15]
- **Device Posture**: [e.g. closed, partiallyOpen / book, fullyOpen, tabletop]
- **Flutter Version**: [output of `flutter --version`]
- **adaptive_foldable Version**: 1.0.0

## Diagnostic Overlay Output (Required)

For layout, fold, or bar placement issues, diagnostic evidence is required:

### 1. Overlay Screenshot
Enable the debug HUD by setting `debugOverlay: true` on your scaffold:
```dart
AdaptiveNavScaffold(
  debugOverlay: true,
  // ...
)
```
Attach a screenshot or camera photo clearly showing the cyan fold lines, amber occlusion highlights, and HUD text:

<!-- Attach screenshot here -->

### 2. Signals Diagnostic Report
Or copy-paste the text report using `formatSignalsReport`:
```dart
final signals = FoldSignals.maybeOf(context);
if (signals != null) {
  print(formatSignalsReport(signals));
}
```

```text
<!-- Paste formatSignalsReport output here -->
```

## Steps to Reproduce
1. Configure `AdaptiveNavScaffold` with '...'
2. Change posture/fold/orientation to '...'
3. Observe incorrect behavior

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
What actually happened (e.g. bar placed inside fold, incorrect bar edge, camera overlap).

## Minimal Reproduction Code
```dart
// Minimal, self-contained Flutter snippet reproducing the issue
```
