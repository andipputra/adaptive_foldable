## 1.0.0

First stable release. Labelled **simulator-verified** (verified on the iPhone Duo simulator in Xcode 27.1+ and Android foldable emulator). Physical hardware testing checklist published in `docs/hardware_feedback_checklist.md`.

* **Signals & Native Bridge**:
  * Native iOS bridge detecting `verticalBarEdge`, reserved regions (cameras, fold crease), and size classes on iOS 27.1+.
  * Android display feature bridge reading hinge geometry and folding posture.
  * `FoldSignals`, `FakeFoldSignals` with presets (iPhone Duo cover/inner, book posture, Android foldables, iPad, Split View), and `FoldSignalsScope`.
* **Design-Agnostic Scaffold**:
  * `AdaptiveNavScaffold` with stable non-reparenting `Stack` tree keeping widget state, scroll offsets, and text inputs intact across fold and resize.
  * Pure `barBuilder` enabling custom brand navigation bars.
* **Placement Policies & Resolvers**:
  * `ApplePolicy` placing trailing side columns on iPhone Duo and bottom bars on standard phones.
  * `MaterialPolicy` placing bottom bars on compact widths and leading navigation rails on expanded widths.
  * Pure `resolveGeometry` calculating bar coordinates, camera clearance, home indicator padding, and fold cut clearance.
* **Page Actions & Overflow**:
  * `AdaptiveNavActions` allowing child pages to publish prominent actions, action groups, and overflow items upward.
  * Automatic `canPop()` Back button insertion with `maybePop()`.
  * Dynamic Type aware overflow calculation prioritizing high-priority and badged actions.
  * Action fades synchronized with route transitions.
* **Fold Kit**:
  * `FoldAwareTwoPane` with non-reparenting state preservation across layout switches.
  * `FoldAlignedGrid` aligning columns around active vertical folds with zero crease intersection.
  * `showFoldAwareDialog` and `showFoldAwareModalBottomSheet` anchoring to specific panes (`auto`, `start`, `end`).
  * `NavPaneScope`, `NavPaneRegistry`, and `NavPaneHeaderBar` for multi-pane title and action management.
  * `resolvePaneActions` and `resolveColumnOwnerPaneId` following Apple split view placement rules.
* **Reference Navigation Bars**:
  * `materialBarBuilder` and `MaterialNavBar` (Material 3).
  * `cupertinoBarBuilder` and `CupertinoStyleNavBar` (Cupertino).
* **Diagnostics & Tooling**:
  * `FoldDebugOverlay` visualising hardware folds, occlusions, and real-time HUD metrics in debug builds.
  * `formatSignalsReport` for structured hardware bug filing.

## 0.2.0-dev.1

Pre-release (Milestone M3). Verified on simulator and emulator only.

* Fold kit: `FoldAwareTwoPane` with non-reparenting state preservation across layout switches and folding/unfolding.
* Fold kit: `FoldAlignedGrid` mirroring columns around active vertical folds with zero fold crease intersection.
* Fold kit: `showFoldAwareDialog` and `showFoldAwareModalBottomSheet` with target pane anchoring (`auto`, `start`, `end`).
* Pane scoping & registry: `NavPaneScope` with standard IDs (`main`, `start`, `end`) and `NavPaneRegistry`.
* Two-pane action routing: `resolvePaneActions` and `resolveColumnOwnerPaneId` implementing Apple split view rules with `placement` overrides.
* Pane header: `NavPaneHeaderBar` for rendering pane-level title, leading control, and published actions.
* Golden tests covering book pose, Split View, RTL, tabletop, and fold-anchored dialogs.
* Example app updated with Two-Pane, Grid, and Modals demonstration screens.

## 0.1.0-dev.1

Pre-release. Verified on simulator and emulator only.

* `AdaptiveNavScaffold`: stable `Stack` layout, `barBuilder`, `policy`, `overflowBuilder`, `transitions`, `onLayoutChanged`, `extendBodyBehindBar`, `debugOverlay`.
* `ApplePolicy` and `MaterialPolicy` placement rules with stable rule ids; geometry that avoids active folds, cameras and the home indicator.
* `AdaptiveNavActions`: page actions published through the widget tree; Back from the page's navigator `canPop()`; fades synchronised with route animations; per-page compression.
* Overflow resolver: Apple fit order, priority and badge ranking, Dynamic Type aware; default Flutter-drawn overflow menu.
* Default Material-style and Cupertino-style bars built on `widgets.dart` only, with ordered semantics and focus and 44 x 44 targets.
* Models: `NavDestination`, `NavAction`, `NavActionGroup`, `NavLayout`, `NavGeometry`, `NavPlacement`, `PageActions`.
* `navDestinationFromIcons` migration helper.
* Signals from 0.0.1: `FoldSignals`, iOS bridge, Android display features, `FakeFoldSignals` with presets, fallback heuristic.

Not yet included: two-pane fold kit (M3), native overflow menu, minimise-on-scroll, state restoration.
