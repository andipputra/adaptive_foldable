import 'package:adaptive_foldable/src/scaffold/actions/nav_action_registry.dart';
import 'package:flutter/widgets.dart';

/// Reads Back state from the navigator that holds a pane's current page.
///
/// The navigator is found from the page's own context, so nested navigators
/// and go_router shell branches resolve to the right one. Back pops with
/// `maybePop`, which respects `PopScope`.
class NavBackController {
  const NavBackController._();

  /// Returns the navigator of [entry]'s page, or null when it is gone.
  static NavigatorState? navigatorOf(NavActionEntry? entry) {
    final context = entry?.context;
    if (context == null || !context.mounted) return null;
    return Navigator.maybeOf(context);
  }

  /// Whether the pane's navigator has a route to go back to, or a custom back callback is provided.
  static bool canGoBack(NavActionEntry? entry, {bool hasCustomBack = false}) =>
      hasCustomBack || (navigatorOf(entry)?.canPop() ?? false);

  /// Pops the pane's navigator, or invokes [onBack] if provided before fallback [Navigator.maybePop].
  static Future<void> goBack(
    NavActionEntry? entry, {
    VoidCallback? onBack,
  }) async {
    if (onBack != null) {
      onBack();
      return;
    }
    await navigatorOf(entry)?.maybePop();
  }
}
