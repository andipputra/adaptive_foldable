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
