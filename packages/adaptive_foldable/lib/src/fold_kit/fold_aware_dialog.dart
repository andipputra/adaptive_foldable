// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/src/fold_kit/fold_pane_modal.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/material.dart';

/// Target pane to anchor a fold-aware dialog or modal bottom sheet.
enum FoldPaneTarget {
  /// Automatically anchors to the pane of the caller's [BuildContext].
  auto,

  /// Anchors to the start / leading pane.
  start,

  /// Anchors to the end / trailing pane.
  end,
}

/// Displays a Material dialog anchored to one side of an active vertical fold.
///
/// When an active vertical fold exists, the dialog is positioned strictly within
/// the bounds of the chosen [target] pane, avoiding the fold crease entirely.
/// Inside a [FoldAwareTwoPane] the dialog and its barrier are limited to the
/// [target] pane, so the other pane stays visible and interactive; close it
/// with [closeFoldAwareModal]. Otherwise it is a standard route dialog, which
/// also closes with [closeFoldAwareModal] or `Navigator.pop`.
Future<T?> showFoldAwareDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  FoldPaneTarget target = FoldPaneTarget.auto,
  bool barrierDismissible = true,
  Color? barrierColor = Colors.black54,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  final callerPaneId = NavPaneScope.idOf(context);
  final signals = FoldSignals.of(context);

  final paneOverlay = paneOverlayFor(context, target);
  if (paneOverlay != null) {
    return showPaneModal<T>(
      overlay: paneOverlay,
      builder: builder,
      isSheet: false,
      dismissible: barrierDismissible,
      barrierColor: barrierColor ?? const Color(0x00000000),
      barrierLabel: barrierLabel,
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: false, // Fold-aware container handles safe area
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (dialogContext) {
      return _FoldAwareDialogContainer(
        target: target,
        callerPaneId: callerPaneId,
        signals: signals,
        useSafeArea: useSafeArea,
        child: builder(dialogContext),
      );
    },
  );
}

/// Returns the pane overlay that should host a modal for [target], or null
/// when [context] is not inside a visible two-pane layout.
OverlayState? paneOverlayFor(BuildContext context, FoldPaneTarget target) {
  final overlays = FoldPaneOverlays.maybeOf(context);
  if (overlays == null) return null;
  final isStart = switch (target) {
    FoldPaneTarget.start => true,
    FoldPaneTarget.end => false,
    FoldPaneTarget.auto => NavPaneScope.idOf(context) == NavPaneScope.startPane,
  };
  final overlay = overlays.overlayFor(isStart: isStart);
  if (overlay == null || !TickerMode.of(overlay.context)) return null;
  return overlay;
}

class _FoldAwareDialogContainer extends StatelessWidget {
  const _FoldAwareDialogContainer({
    required this.target,
    required this.callerPaneId,
    required this.signals,
    required this.useSafeArea,
    required this.child,
  });

  final FoldPaneTarget target;
  final String callerPaneId;
  final FoldSignals signals;
  final bool useSafeArea;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeFolds = signals.activeFolds
        .where((Rect r) => r.height > r.width)
        .toList();

    if (activeFolds.isEmpty) {
      return useSafeArea ? SafeArea(child: child) : child;
    }

    final fold = activeFolds.first;
    final viewSize = MediaQuery.sizeOf(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final bool isStart = switch (target) {
      FoldPaneTarget.start => true,
      FoldPaneTarget.end => false,
      FoldPaneTarget.auto => callerPaneId == NavPaneScope.startPane,
    };

    final double paneLeft;
    final double paneWidth;

    if (isRtl) {
      if (isStart) {
        paneLeft = fold.right;
        paneWidth = (viewSize.width - fold.right).clamp(0.0, viewSize.width);
      } else {
        paneLeft = 0.0;
        paneWidth = fold.left.clamp(0.0, viewSize.width);
      }
    } else {
      if (isStart) {
        paneLeft = 0.0;
        paneWidth = fold.left.clamp(0.0, viewSize.width);
      } else {
        paneLeft = fold.right;
        paneWidth = (viewSize.width - fold.right).clamp(0.0, viewSize.width);
      }
    }

    Widget content = child;
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: paneLeft,
          top: 0,
          width: paneWidth,
          bottom: 0,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: paneWidth),
              child: content,
            ),
          ),
        ),
      ],
    );
  }
}
