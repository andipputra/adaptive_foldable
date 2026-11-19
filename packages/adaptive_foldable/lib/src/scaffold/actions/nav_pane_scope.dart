import 'package:flutter/widgets.dart';

/// Names the pane whose navigation column the pages below publish actions to.
///
/// Without one, pages publish to [mainPane]. In two-pane layouts (M3), panes
/// are typically identified as [startPane] and [endPane].
class NavPaneScope extends InheritedWidget {
  /// Creates a scope for [paneId].
  const NavPaneScope({
    super.key,
    required this.paneId,
    this.isPrimary = false,
    required super.child,
  });

  /// Default pane identifier used when no scope is present or in single-pane mode.
  static const String mainPane = 'main';

  /// Standard pane identifier for the leading / start / list pane in a two-pane layout.
  static const String startPane = 'start';

  /// Standard pane identifier for the trailing / end / detail pane in a two-pane layout.
  static const String endPane = 'end';

  /// Identifier of the pane below this scope.
  final String paneId;

  /// Whether this pane is considered the primary pane (e.g. Master/List in Master-Detail).
  final bool isPrimary;

  /// Returns the pane id for [context], or [mainPane].
  static String idOf(BuildContext context) =>
      maybeOf(context)?.paneId ?? mainPane;

  /// Returns the nearest [NavPaneScope] above [context], or null if none exists.
  static NavPaneScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavPaneScope>();

  @override
  bool updateShouldNotify(NavPaneScope oldWidget) =>
      oldWidget.paneId != paneId || oldWidget.isPrimary != isPrimary;
}
