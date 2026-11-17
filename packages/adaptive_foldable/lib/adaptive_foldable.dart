/// A design-agnostic Flutter navigation scaffold with a fold kit.
library;

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
export 'package:adaptive_foldable/src/policy/apple_policy.dart';
export 'package:adaptive_foldable/src/policy/material_policy.dart';
export 'package:adaptive_foldable/src/policy/nav_placement_policy.dart';
export 'package:adaptive_foldable/src/signals/fake_fold_signals.dart';
export 'package:adaptive_foldable/src/signals/fold_signals.dart'
    show FoldSignals;
export 'package:adaptive_foldable/src/signals/fold_signals_scope.dart'
    show FoldSignalsScope;
export 'package:adaptive_foldable/src/signals/signal_types.dart';

/// The current version of the adaptive_foldable package.
const String adaptiveFoldableVersion = '0.0.1';
