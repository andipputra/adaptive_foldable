import 'package:adaptive_foldable/src/signals/android_fold_signals.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:adaptive_foldable/src/signals/fold_sources_merger.dart';
import 'package:adaptive_foldable/src/signals/ios_fold_signals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Scoped provider for [FoldSignals] in the widget tree.
class FoldSignalsScope extends StatefulWidget {
  /// Creates a [FoldSignalsScope].
  const FoldSignalsScope({
    super.key,
    FoldSignals? override,
    required this.child,
  }) : overrideSignals = override;

  /// Optional [FoldSignals] override, typically used in unit and widget tests.
  final FoldSignals? overrideSignals;

  /// The child widget.
  final Widget child;

  /// Returns the nearest [FoldSignals] in [context].
  ///
  /// Throws an [AssertionError] if no [FoldSignalsScope] is found in the widget tree.
  static FoldSignals of(BuildContext context) {
    final signals = maybeOf(context);
    assert(
      signals != null,
      'No FoldSignalsScope found in the widget tree. '
      'Wrap your app or test widget with FoldSignalsScope.',
    );
    return signals!;
  }

  /// Returns the nearest [FoldSignals] in [context], or null if none exists.
  static FoldSignals? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_InheritedFoldSignals>();
    return inherited?.signals;
  }

  @override
  State<FoldSignalsScope> createState() => _FoldSignalsScopeState();
}

class _FoldSignalsScopeState extends State<FoldSignalsScope> {
  FoldSignals? _activeSignals;

  @override
  void initState() {
    super.initState();
    FoldSignals.signalsOfHook = (context) =>
        FoldSignalsScope.of(context as BuildContext);
    FoldSignals.signalsMaybeOfHook = (context) =>
        FoldSignalsScope.maybeOf(context as BuildContext);

    _attachSignals();
  }

  @override
  void didUpdateWidget(FoldSignalsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.overrideSignals != oldWidget.overrideSignals) {
      _detachSignals();
      _attachSignals();
    }
  }

  void _attachSignals() {
    if (widget.overrideSignals != null) {
      _activeSignals = widget.overrideSignals;
      _activeSignals!.addListener(_handleSignalsChanged);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _activeSignals = IosFoldSignals.instance;
      _activeSignals!.addListener(_handleSignalsChanged);
    }
  }

  void _detachSignals() {
    _activeSignals?.removeListener(_handleSignalsChanged);
    _activeSignals = null;
  }

  void _handleSignalsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _detachSignals();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final viewSize = mediaQuery?.size ?? Size.zero;
    final displayFeatures = mediaQuery?.displayFeatures ?? const [];

    final FoldSignals resolvedSignals;
    final FoldSignalsSnapshot resolvedSnapshot;

    if (widget.overrideSignals != null) {
      resolvedSignals = widget.overrideSignals!;
      resolvedSnapshot = FoldSignalsSnapshot.from(widget.overrideSignals!);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = IosFoldSignals.instance;
      resolvedSnapshot = mergeFoldSources(
        bridge: ios.snapshot,
        displayFeatures: displayFeatures,
        viewSize: viewSize,
      );
      resolvedSignals = resolvedSnapshot;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      resolvedSnapshot = AndroidFoldSignals.resolve(
        viewSize: viewSize,
        displayFeatures: displayFeatures,
      );
      resolvedSignals = resolvedSnapshot;
    } else {
      resolvedSnapshot = DefaultFoldSignals.resolve(
        viewSize: viewSize,
        displayFeatures: displayFeatures,
      );
      resolvedSignals = resolvedSnapshot;
    }

    return _InheritedFoldSignals(
      signals: resolvedSignals,
      snapshot: resolvedSnapshot,
      child: widget.child,
    );
  }
}

class _InheritedFoldSignals extends InheritedWidget {
  const _InheritedFoldSignals({
    required this.signals,
    required this.snapshot,
    required super.child,
  });

  final FoldSignals signals;
  final FoldSignalsSnapshot snapshot;

  @override
  bool updateShouldNotify(_InheritedFoldSignals oldWidget) {
    return oldWidget.snapshot != snapshot;
  }
}
