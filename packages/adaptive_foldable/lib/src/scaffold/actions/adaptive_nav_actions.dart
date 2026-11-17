import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/nav_action_group.dart';
import 'package:adaptive_foldable/src/model/nav_action_placement.dart';
import 'package:adaptive_foldable/src/model/nav_compression.dart';
import 'package:adaptive_foldable/src/model/page_actions.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_action_registry.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
import 'package:flutter/widgets.dart';

/// Publishes a page's actions to the nearest `AdaptiveNavScaffold`.
///
/// Put it inside a page. The scaffold draws the actions of the page on top and
/// fades them with the route animation. A page without it shows no actions and
/// the tabs remain. Router-agnostic: registration happens in the widget tree.
class AdaptiveNavActions extends StatefulWidget {
  /// Creates a page-actions publisher around [child].
  const AdaptiveNavActions({
    super.key,
    this.prominentAction,
    this.groups = const [],
    this.overflowItems = const [],
    this.compression = NavCompression.navigation,
    this.placement = NavActionPlacement.auto,
    required this.child,
  });

  /// The pinned action, if any.
  final NavAction? prominentAction;

  /// Action groups in display order.
  final List<NavActionGroup> groups;

  /// Actions that always live in the overflow menu.
  final List<NavAction> overflowItems;

  /// Which part of the bar gives way first when space runs out.
  final NavCompression compression;

  /// Where the actions are shown when there are several panes.
  final NavActionPlacement placement;

  /// The page content.
  final Widget child;

  @override
  State<AdaptiveNavActions> createState() => _AdaptiveNavActionsState();
}

class _AdaptiveNavActionsState extends State<AdaptiveNavActions> {
  late final NavActionEntry _entry = NavActionEntry(this);
  NavActionRegistry? _registry;
  Animation<double>? _animation;
  Animation<double>? _secondary;

  PageActions get _actions => PageActions(
    prominentAction: widget.prominentAction,
    groups: widget.groups,
    overflowItems: widget.overflowItems,
    compression: widget.compression,
    placement: widget.placement,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = NavActionScope.maybeOf(context);
    if (registry != _registry) {
      _registry?.unregister(_entry);
      _registry = registry;
    }
    final route = ModalRoute.of(context);
    _entry
      ..paneId = NavPaneScope.idOf(context)
      ..route = route
      ..context = context
      ..isCurrent = ModalRoute.isCurrentOf(context) ?? true
      ..enabled = TickerMode.valuesOf(context).enabled
      ..actions = _actions;
    _listenTo(route?.animation, route?.secondaryAnimation);
    _registry?.register(_entry);
    _registry?.markChanged();
  }

  @override
  void didUpdateWidget(AdaptiveNavActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _actions;
    final changed = !next.sameContentAs(_entry.actions);
    // Always keep the latest callbacks; only a visible change needs a repaint.
    _entry.actions = next;
    if (changed) _registry?.markChanged();
  }

  void _listenTo(Animation<double>? animation, Animation<double>? secondary) {
    if (animation != _animation) {
      _animation?.removeStatusListener(_onStatus);
      _animation = animation?..addStatusListener(_onStatus);
    }
    if (secondary != _secondary) {
      _secondary?.removeStatusListener(_onStatus);
      _secondary = secondary?..addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus status) => _registry?.markChanged();

  @override
  void dispose() {
    _animation?.removeStatusListener(_onStatus);
    _secondary?.removeStatusListener(_onStatus);
    _registry?.unregister(_entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
