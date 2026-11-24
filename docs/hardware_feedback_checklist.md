# Hardware Feedback Checklist

Simulators provide baseline layout checks, but physical foldable hardware introduces unique physics that cannot be simulated:
1. **Reserved-region timing latency**: Delay between physical hinge movement and OS window manager updates.
2. **Crease touch accuracy**: Digitizer distortion or touch dead zones near physical screen bends.
3. **Continuous posture transitions**: Visual smoothness as the hinge moves through intermediate angles.
4. **Rendering performance**: Jank, stutter, or dropped frames during layout recalculations.

If you have physical foldable hardware (such as an iPhone Duo, Samsung Galaxy Z Fold/Flip, Google Pixel Fold, or Microsoft Surface Duo), please use this checklist to test your application and report findings.

---

## 1. Enable the Diagnostic Overlay

In debug mode, enable the built-in HUD overlay by setting `debugOverlay: true` on `AdaptiveNavScaffold`:

```dart
AdaptiveNavScaffold(
  debugOverlay: true,
  destinations: destinations,
  selectedIndex: selectedIndex,
  onSelected: onSelected,
  body: body,
)
```

The overlay renders:
- Hardware folds outlined in cyan.
- Camera and sensor occlusions outlined in amber.
- Real-time diagnostic HUD showing device posture, size classes, `verticalBarEdge`, and active policy rule.

To programmatically generate a text report for bug filings:
```dart
final signals = FoldSignals.maybeOf(context);
if (signals != null) {
  final report = formatSignalsReport(signals);
  print(report);
}
```

---

## 2. Testing Procedures & Checklist

### Check 1: Reserved-Region Timing Latency
- **Action**: Unfold the device from cover display to inner display, then fold it back.
- **Observations**:
  - Does the navigation column or bottom bar jump into place immediately, or is there a noticeable visual lag (>150ms)?
  - Does the bar temporarily overlap the fold or camera while the window resizes?
  - Does `onLayoutChanged` fire exactly once per settled transition?

### Check 2: Crease Touch Detection & Accuracy
- **Action**: Place interactive elements (buttons, navigation tabs, list tiles) adjacent to the hinge line.
- **Observations**:
  - Tap targets within 16-24 dp of the crease: Do taps register accurately on the intended item?
  - Does horizontal dragging or scrolling across the fold line drop pointer events?
  - In `FoldAlignedGrid`, do grid columns cleanly flank the crease without any card bisected by the fold?

### Check 3: Continuous Posture Transitions
- **Action**: Slowly bend the device into book posture (held like a book), tabletop posture (rested like a laptop), and fully open (flat).
- **Observations**:
  - Does `FoldAwareTwoPane` engage smoothly when the hinge passes into book pose?
  - Is there any rapid flickering, layout oscillation, or re-render storm at intermediate hinge angles (e.g. 85° to 95°)?
  - Does the vertical side column stay anchored to the outer hardware edge?

### Check 4: Camera & Sensor Occlusion Clearance
- **Action**: Rotate the device into all supported orientations on both cover and inner screens.
- **Observations**:
  - Does the side column top start strictly below the camera cut-out or Dynamic Island?
  - On the iPhone Duo, does the column respect the outer camera's permanent reservation?
  - Are actions or icons obscured by hardware sensors in any orientation?

### Check 5: Frame Stability & Memory
- **Action**: Rapidly fold, unfold, and rotate the device through multiple cycles with high-frequency inputs.
- **Observations**:
  - Are any visual frame drops or jank spikes visible in Flutter DevTools Performance overlay?
  - Is widget state (scroll offset, form inputs, selected tab) strictly preserved across every transition?

### Check 6: Android Foldables
- **Action**: On a physical Android foldable, set book posture, tabletop posture, split-screen and rotate.
- **Observations**:
  - Does the bottom bar stay on one pane in book posture and never cross the hinge?
  - Is the bar below the hinge in tabletop posture, with content above?
  - Are touch targets at least 48 dp and are Tab, Enter and Esc usable with an external keyboard?
  - Do picture-in-picture, camera and multi-window behave in the host app?

---

## 3. Reporting Findings

When reporting hardware findings on GitHub:
1. Open an issue using the [Hardware Bug Report Template](https://github.com/andipputra/adaptive_foldable/issues/new?template=bug_report.md).
2. Attach a physical photo or on-device screenshot showing `FoldDebugOverlay` active.
3. Paste the diagnostic output from `formatSignalsReport(signals)`.
4. Specify:
   - Device manufacturer, model, and OS version.
   - Flutter SDK version (`flutter --version`).
