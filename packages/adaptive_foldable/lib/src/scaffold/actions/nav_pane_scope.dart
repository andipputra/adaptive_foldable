import 'package:flutter/widgets.dart';

/// Names the pane whose navigation column the pages below publish actions to.
///
/// Without one, pages publish to [mainPane]. Two-pane layouts (M3) wrap each pane in its own scope.
class NavPaneScope extends InheritedWidget {
  /// Creates a scope for [paneId].
  const NavPaneScope({super.key, required this.paneId, required super.child});

  /// Pane id used when no scope is present.
  static const String mainPane = 'main';

  /// Identifier of the pane below this scope.
  final String paneId;

  /// Returns the pane id for [context], or [mainPane].
  static String idOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NavPaneScope>()?.paneId ??
      mainPane;

  @override
  bool updateShouldNotify(NavPaneScope oldWidget) => oldWidget.paneId != paneId;
}
