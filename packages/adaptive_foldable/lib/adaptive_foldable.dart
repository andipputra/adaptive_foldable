/// A design-agnostic Flutter navigation scaffold with a fold kit.
library;

export 'package:adaptive_foldable/src/bars/cupertino/cupertino_style_nav_bar.dart'
    show CupertinoStyleNavBar, cupertinoBarBuilder;
export 'package:adaptive_foldable/src/bars/material/material_nav_bar.dart'
    show MaterialNavBar, materialBarBuilder;
export 'package:adaptive_foldable/src/debug/debug_report.dart'
    show formatSignalsReport;
export 'package:adaptive_foldable/src/debug/fold_debug_overlay.dart'
    show FoldDebugOverlay;
export 'package:adaptive_foldable/src/layout/geometry_resolver.dart';
export 'package:adaptive_foldable/src/model/nav_action.dart';
export 'package:adaptive_foldable/src/model/nav_action_group.dart';
export 'package:adaptive_foldable/src/model/nav_action_placement.dart';
export 'package:adaptive_foldable/src/model/nav_axis.dart';
export 'package:adaptive_foldable/src/model/nav_compression.dart';
export 'package:adaptive_foldable/src/model/nav_destination.dart';
export 'package:adaptive_foldable/src/model/nav_geometry.dart';
export 'package:adaptive_foldable/src/model/nav_insets.dart';
export 'package:adaptive_foldable/src/model/nav_layout.dart';
export 'package:adaptive_foldable/src/model/nav_placement.dart';
export 'package:adaptive_foldable/src/model/nav_priority.dart';
export 'package:adaptive_foldable/src/model/page_actions.dart' show PageActions;
export 'package:adaptive_foldable/src/policy/apple_policy.dart';
export 'package:adaptive_foldable/src/policy/material_policy.dart';
export 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
export 'package:adaptive_foldable/src/scaffold/actions/adaptive_nav_actions.dart';
export 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
export 'package:adaptive_foldable/src/scaffold/adaptive_nav_scaffold.dart';
export 'package:adaptive_foldable/src/scaffold/nav_adapters.dart'
    show navDestinationFromIcons;
export 'package:adaptive_foldable/src/scaffold/nav_transitions.dart';
export 'package:adaptive_foldable/src/signals/fake_fold_signals.dart';
export 'package:adaptive_foldable/src/signals/fold_signals.dart'
    show FoldSignals;
export 'package:adaptive_foldable/src/signals/fold_signals_scope.dart'
    show FoldSignalsScope;
export 'package:adaptive_foldable/src/signals/signal_types.dart';

/// The current version of the adaptive_foldable package.
const String adaptiveFoldableVersion = '0.1.0-dev.1';
