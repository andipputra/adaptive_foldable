# adaptive_foldable_example

Demonstration application for `adaptive_foldable`. Showcases how navigation bars, actions, two-pane layouts, and dialogs dynamically adapt across standard phones, tablets, iPhone Duo (Xcode 27.1+), and Android foldable devices.

---

## Showcase Screens

The example app is built using `go_router` and `AdaptiveNavScaffold`, containing 5 tabs:

1. **Inbox & Message Detail (`/inbox`)**
   - Demonstrates `AdaptiveNavActions` where individual pages publish actions upward.
   - Message detail page publishes prominent Reply action, groups (Share, Archive, Label, Delete, Mute, Snooze), and overflow Report action.
   - Shows automatic `canPop()` Back button insertion with `maybePop()`.

2. **Two-Pane Master/Detail (`/two-pane`)**
   - Demonstrates `FoldAwareTwoPane` splitting document list and detail views across the hinge in book posture or landscape.
   - Demonstrates `NavPaneHeaderBar` for secondary header strips.

3. **Fold-Aligned Grid (`/grid`)**
   - Demonstrates `FoldAlignedGrid` splitting columns cleanly around the hinge line so grid items never span the physical fold.

4. **Modals & Anchoring (`/modals`)**
   - Demonstrates `showFoldAwareDialog` and `showFoldAwareModalBottomSheet`.
   - Toggles dialog and bottom-sheet anchoring to the primary (`start`), secondary (`end`), or automatically chosen pane.

5. **Profile & Hardware Diagnostics (`/profile`)**
   - Displays live readings from `FoldSignals.of(context)`: posture, size classes, and resolved bar edge.

---

## Running the Example

### iPhone Duo Simulator (Xcode 27.1+)
```bash
flutter run -d "iPhone Duo"
```
Use the simulator menu (**Hardware -> Hinge / Display**) to toggle between:
- Cover display (compact portrait: vertical side column).
- Inner display landscape (trailing column).
- Book posture (two-pane split across fold line).

### Android Foldable Emulator
```bash
flutter run -d <emulator-id>
```
Use the emulator side panel (**Virtual Sensors -> Fold**) to test closed, half-folded, and unfolded postures.

### Desktop / Chrome Window Resizing
```bash
flutter run -d macos
# or
flutter run -d chrome
```
Drag the window width to observe instant, state-preserving transitions between bottom navigation bar and side navigation column.
