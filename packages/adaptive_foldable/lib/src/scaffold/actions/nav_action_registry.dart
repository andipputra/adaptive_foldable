import 'package:adaptive_foldable/src/layout/actions_fade.dart';
import 'package:adaptive_foldable/src/model/page_actions.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// One mounted `AdaptiveNavActions` and what the registry needs to rank it.
class NavActionEntry {
  /// Creates an entry for [owner].
  NavActionEntry(this.owner);

  /// The state object that owns this entry; used as identity.
  final Object owner;

  /// The pane the page publishes to.
  String paneId = 'main';

  /// The actions currently published.
  PageActions actions = PageActions.empty;

  /// The page's route, or null outside a route.
  ModalRoute<dynamic>? route;

  /// Context inside the page, used to find its navigator for Back.
  BuildContext? context;

  /// False while the page is offstage (inactive tab, covered route).
  bool enabled = true;

  /// Whether the page's route is the top route of its navigator.
  bool isCurrent = true;

  /// Whether a dialog or sheet covers the page: the route is active but not
  /// current, and no page transition is moving it (a page pushed on top would
  /// run the route's secondary animation).
  bool get isCoveredByOverlay {
    final r = route;
    if (r == null || !r.isActive || isCurrent) return false;
    return r.secondaryAnimation?.status == AnimationStatus.dismissed;
  }

  /// Registration order; later pages stack above earlier ones.
  int order = 0;

  /// The page route's animation value: 1 at rest.
  double get progress => route?.animation?.value ?? 1;
}

/// What the bar should draw for one pane right now.
class NavActionsView {
  /// Creates a view.
  const NavActionsView({
    this.entry,
    this.opacity = 1,
    this.animations = const [],
  });

  /// The page whose actions to draw, or null for none.
  final NavActionEntry? entry;

  /// Opacity for the actions while a route transition runs.
  final double opacity;

  /// Animations whose ticks change [opacity].
  final List<Animation<double>> animations;
}

/// Collects the actions published by pages in the widget tree.
///
/// Registration happens in the tree, so it works with `Navigator`, go_router
/// and nested navigators alike. Changes notify listeners in a post-frame
/// callback, never during build.
class NavActionRegistry extends ChangeNotifier {
  final List<NavActionEntry> _entries = [];
  int _nextOrder = 0;
  bool _scheduled = false;
  bool _contentChanged = false;
  bool _disposed = false;

  /// Whether the notification being delivered follows a change in what the pages publish,
  /// as opposed to a callback-only refresh.
  bool get contentChanged => _contentChanged;

  /// Adds [entry] above all earlier entries.
  void register(NavActionEntry entry) {
    if (_entries.contains(entry)) return;
    entry.order = _nextOrder++;
    _entries.add(entry);
    markChanged();
  }

  /// Removes [entry].
  void unregister(NavActionEntry entry) {
    if (_entries.remove(entry)) markChanged();
  }

  /// The most recent entry of [paneId] on stage, or the most recent one at all.
  ///
  /// Used to find the pane's navigator for Back even when the page on top
  /// publishes nothing.
  NavActionEntry? anchorFor(String paneId) {
    final onStage = candidates(paneId);
    if (onStage.isNotEmpty) return onStage.last;
    final all = _entries.where((e) => e.paneId == paneId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return all.isEmpty ? null : all.last;
  }

  /// Entries of [paneId] that are on stage, lowest page first.
  List<NavActionEntry> candidates(String paneId) =>
      _entries.where((e) => e.paneId == paneId && e.enabled).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  /// Resolves what to draw for [paneId].
  ///
  /// While the top page's route animates, the lower page's actions fade out and
  /// the top page's fade in (see `actionsFade`).
  NavActionsView viewFor(String paneId, {bool reduceMotion = false}) {
    final c = candidates(paneId);
    if (c.isEmpty) return const NavActionsView();
    final top = c.last;
    final t = top.progress;
    final animation = top.route?.animation;
    final animations = [?animation];
    if (t >= 1) return NavActionsView(entry: top, animations: animations);
    if (c.length < 2) {
      return NavActionsView(
        entry: top,
        opacity: reduceMotion ? 1 : t.clamp(0.0, 1.0),
        animations: animations,
      );
    }
    final fade = actionsFade(t, reduceMotion: reduceMotion);
    return NavActionsView(
      entry: fade.showIncoming ? top : c[c.length - 2],
      opacity: fade.opacity,
      animations: animations,
    );
  }

  /// Asks the scaffold to rebuild with the entries' latest callbacks, without any fade or menu reset.
  void markCallbacksChanged() => markChanged(contentChanged: false);

  /// Notifies listeners after the current frame; repeated calls in one frame coalesce.
  void markChanged({bool contentChanged = true}) {
    if (contentChanged) _contentChanged = true;
    if (_scheduled || _disposed) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!_disposed) notifyListeners();
      _contentChanged = false;
    });
    SchedulerBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Gives pages below it access to the scaffold's [NavActionRegistry].
class NavActionScope extends InheritedWidget {
  /// Creates a scope exposing [registry].
  const NavActionScope({
    super.key,
    required this.registry,
    required super.child,
  });

  /// The registry pages publish to.
  final NavActionRegistry registry;

  /// Returns the nearest registry, or null when no scaffold is above [context].
  static NavActionRegistry? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<NavActionScope>()?.registry;

  @override
  bool updateShouldNotify(NavActionScope oldWidget) =>
      oldWidget.registry != registry;
}
