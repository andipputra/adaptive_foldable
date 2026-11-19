// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/src/fold_kit/fold_aware_dialog.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
import 'package:adaptive_foldable/src/signals/fold_signals.dart';
import 'package:flutter/material.dart';

/// Displays a modal bottom sheet anchored to one side of an active vertical fold.
///
/// When an active vertical fold exists (e.g. book pose), anchors the bottom sheet
/// strictly to the [target] pane half, avoiding the crease entirely.
/// When flat or without an active fold, behaves as a standard modal bottom sheet.
Future<T?> showFoldAwareModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  FoldPaneTarget target = FoldPaneTarget.auto,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
}) {
  final callerPaneId = NavPaneScope.idOf(context);
  final signals = FoldSignals.of(context);

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent, // Outer background transparent so inner sheet anchors cleanly
    elevation: 0,
    shape: const RoundedRectangleBorder(),
    clipBehavior: Clip.none,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    constraints: const BoxConstraints(
      minWidth: double.infinity,
      maxWidth: double.infinity,
    ),
    builder: (sheetContext) {
      return _FoldAwareBottomSheetContainer(
        target: target,
        callerPaneId: callerPaneId,
        signals: signals,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        constraints: constraints,
        child: builder(sheetContext),
      );
    },
  );
}

class _FoldAwareBottomSheetContainer extends StatelessWidget {
  const _FoldAwareBottomSheetContainer({
    required this.target,
    required this.callerPaneId,
    required this.signals,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    required this.child,
  });

  final FoldPaneTarget target;
  final String callerPaneId;
  final FoldSignals signals;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeFolds = signals.activeFolds
        .where((Rect r) => r.height > r.width)
        .toList();

    final theme = Theme.of(context);
    final sheetTheme = theme.bottomSheetTheme;

    final effectiveColor =
        backgroundColor ??
        sheetTheme.backgroundColor ??
        theme.colorScheme.surface;
    final effectiveElevation = elevation ?? sheetTheme.elevation ?? 1.0;
    final effectiveShape =
        shape ??
        sheetTheme.shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        );
    final effectiveClip = clipBehavior ?? sheetTheme.clipBehavior ?? Clip.none;

    final sheetSurface = Material(
      color: effectiveColor,
      elevation: effectiveElevation,
      shape: effectiveShape,
      clipBehavior: effectiveClip,
      child: child,
    );

    if (activeFolds.isEmpty) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints(),
          child: sheetSurface,
        ),
      );
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

    return Stack(
      children: [
        Positioned(
          left: paneLeft,
          width: paneWidth,
          bottom: 0,
          child: ConstrainedBox(
            constraints: (constraints ?? const BoxConstraints()).copyWith(
              maxWidth: paneWidth,
            ),
            child: sheetSurface,
          ),
        ),
      ],
    );
  }
}
