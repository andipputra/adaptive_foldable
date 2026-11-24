import 'dart:async';

import 'package:flutter/widgets.dart';

/// Gives descendants of a two-pane layout access to each pane's [Overlay].
///
/// Modals inserted into a pane overlay are clipped to that pane, so their
/// barrier and content never cover the other pane.
class FoldPaneOverlays extends InheritedWidget {
  /// Creates the lookup for the [start] and [end] pane overlays.
  const FoldPaneOverlays({
    super.key,
    required this.start,
    required this.end,
    required super.child,
  });

  /// Key of the start pane [Overlay].
  final GlobalKey<OverlayState> start;

  /// Key of the end pane [Overlay].
  final GlobalKey<OverlayState> end;

  /// Returns the nearest [FoldPaneOverlays] above [context] without subscribing.
  static FoldPaneOverlays? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<FoldPaneOverlays>();

  /// Returns the mounted overlay of the start or end pane, or null.
  OverlayState? overlayFor({required bool isStart}) =>
      (isStart ? start : end).currentState;

  @override
  bool updateShouldNotify(FoldPaneOverlays oldWidget) =>
      oldWidget.start != start || oldWidget.end != end;
}

/// Hosts a pane's content in its own [Overlay] so modals can be scoped to it.
class FoldPaneOverlayHost extends StatefulWidget {
  /// Creates a host that shows [child] as the base layer of [overlayKey].
  const FoldPaneOverlayHost({
    super.key,
    required this.overlayKey,
    required this.child,
  });

  /// Key exposing the pane [OverlayState].
  final GlobalKey<OverlayState> overlayKey;

  /// Pane content.
  final Widget child;

  @override
  State<FoldPaneOverlayHost> createState() => _FoldPaneOverlayHostState();
}

class _FoldPaneOverlayHostState extends State<FoldPaneOverlayHost> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (_) => widget.child,
    canSizeOverlay: true,
  );

  @override
  void didUpdateWidget(FoldPaneOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) =>
      Overlay(key: widget.overlayKey, initialEntries: [_entry]);
}

/// Closes the fold-aware dialog or bottom sheet that contains [context].
///
/// Works for pane-scoped modals; otherwise pops the enclosing route.
void closeFoldAwareModal<T>(BuildContext context, [T? result]) {
  final scope = context.getInheritedWidgetOfExactType<_PaneModalScope>();
  if (scope != null) {
    scope.close(result);
  } else {
    Navigator.of(context).pop(result);
  }
}

class _PaneModalScope extends InheritedWidget {
  const _PaneModalScope({required this.close, required super.child});

  final void Function(Object? result) close;

  @override
  bool updateShouldNotify(_PaneModalScope oldWidget) => false;
}

/// Shows [builder] above the base content of [overlay], limited to its bounds.
///
/// Completes with the value passed to [closeFoldAwareModal], or null when the
/// barrier is tapped, Back is pressed, or the pane is removed.
Future<T?> showPaneModal<T>({
  required OverlayState overlay,
  required WidgetBuilder builder,
  required bool isSheet,
  required bool dismissible,
  required Color barrierColor,
  String? barrierLabel,
}) {
  final completer = Completer<T?>();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _PaneModal(
      isSheet: isSheet,
      dismissible: dismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      builder: builder,
      onClosed: (result) {
        if (entry.mounted) entry.remove();
        entry.dispose();
        if (!completer.isCompleted) completer.complete(result as T?);
      },
    ),
  );
  overlay.insert(entry);
  return completer.future;
}

class _PaneModal extends StatefulWidget {
  const _PaneModal({
    required this.isSheet,
    required this.dismissible,
    required this.barrierColor,
    required this.barrierLabel,
    required this.builder,
    required this.onClosed,
  });

  final bool isSheet;
  final bool dismissible;
  final Color barrierColor;
  final String? barrierLabel;
  final WidgetBuilder builder;
  final void Function(Object? result) onClosed;

  @override
  State<_PaneModal> createState() => _PaneModalState();
}

class _PaneModalState extends State<_PaneModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  bool _closing = false;
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  void _close(Object? result) {
    if (_closing) return;
    _closing = true;
    final instant = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (instant) {
      _report(result);
      return;
    }
    _controller.reverse().whenComplete(() => _report(result));
  }

  void _report(Object? result) {
    if (_reported) return;
    _reported = true;
    widget.onClosed(result);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _PaneModalScope(
      close: _close,
      child: Builder(builder: widget.builder),
    );
    content = widget.isSheet
        ? SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_curve),
            child: content,
          )
        : FadeTransition(
            opacity: _curve,
            child: SafeArea(child: Center(child: content)),
          );

    final barrier = FadeTransition(
      opacity: _curve,
      child: ColoredBox(color: widget.barrierColor),
    );

    Widget stack = Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.dismissible ? () => _close(null) : null,
          child: Semantics(
            label: widget.dismissible ? widget.barrierLabel : null,
            button: widget.dismissible,
            child: barrier,
          ),
        ),
        if (widget.isSheet)
          Align(alignment: Alignment.bottomCenter, child: content)
        else
          content,
      ],
    );

    if (widget.dismissible && Router.maybeOf(context) != null) {
      stack = BackButtonListener(
        onBackButtonPressed: () async {
          _close(null);
          return true;
        },
        child: stack,
      );
    }
    return FocusScope(autofocus: true, child: stack);
  }
}
