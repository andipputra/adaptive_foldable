// ignore_for_file: deprecated_member_use -- material.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/src/bars/nav_bar_item.dart'
    show platformMinTapTarget;
import 'package:adaptive_foldable/src/model/nav_action.dart';
import 'package:adaptive_foldable/src/model/page_actions.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_action_registry.dart';
import 'package:adaptive_foldable/src/scaffold/actions/nav_pane_scope.dart';
import 'package:flutter/material.dart';

/// A horizontal header bar that displays title, leading control, and published
/// actions for a specific pane in a multi-pane layout.
class NavPaneHeaderBar extends StatelessWidget {
  /// Creates a pane header bar.
  const NavPaneHeaderBar({
    super.key,
    this.paneId,
    this.leading,
    this.title,
    this.height = 44.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0),
    this.actionsOverride,
  });

  /// The pane id whose actions to display. Defaults to [NavPaneScope.idOf(context)].
  final String? paneId;

  /// Optional leading widget (e.g. Back button).
  final Widget? leading;

  /// Optional title widget.
  final Widget? title;

  /// Height of the header bar.
  final double height;

  /// Padding around the header bar content.
  final EdgeInsetsGeometry padding;

  /// Explicit actions override; if provided, used instead of reading from registry.
  final PageActions? actionsOverride;

  @override
  Widget build(BuildContext context) {
    final effectivePaneId = paneId ?? NavPaneScope.idOf(context);
    final registry = NavActionScope.maybeOf(context);

    return ListenableBuilder(
      listenable: registry ?? ChangeNotifier(),
      builder: (context, _) {
        final PageActions actions;
        if (actionsOverride != null) {
          actions = actionsOverride!;
        } else if (registry != null) {
          final view = registry.viewFor(effectivePaneId);
          actions = view.entry?.actions ?? PageActions.empty;
        } else {
          actions = PageActions.empty;
        }

        final visibleActions = <NavAction>[];
        if (actions.prominentAction != null) {
          visibleActions.add(actions.prominentAction!);
        }
        for (final group in actions.groups) {
          visibleActions.addAll(group.actions);
        }

        return Container(
          height: height,
          padding: padding,
          child: Row(
            children: [
              ?leading,
              if (title != null) ...[
                if (leading != null) const SizedBox(width: 8),
                Expanded(
                  child: DefaultTextStyle(
                    style:
                        Theme.of(context).textTheme.titleMedium ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                    child: title!,
                  ),
                ),
              ] else
                const Spacer(),
              for (final action in visibleActions)
                _NavPaneActionButton(action: action),
              if (actions.overflowItems.isNotEmpty)
                _NavPaneOverflowButton(items: actions.overflowItems),
            ],
          ),
        );
      },
    );
  }
}

class _NavPaneActionButton extends StatelessWidget {
  const _NavPaneActionButton({required this.action});

  final NavAction action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: platformMinTapTarget,
        minHeight: platformMinTapTarget,
      ),
      child: IconButton(
        icon: Icon(action.icon),
        tooltip: action.label,
        onPressed: action.enabled ? action.onPressed : null,
      ),
    );
  }
}

class _NavPaneOverflowButton extends StatelessWidget {
  const _NavPaneOverflowButton({required this.items});

  final List<NavAction> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NavAction>(
      tooltip: 'More actions',
      icon: const Icon(Icons.more_vert),
      onSelected: (action) => action.onPressed(),
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem<NavAction>(
            value: item,
            enabled: item.enabled,
            child: Row(
              children: [
                Icon(item.icon, size: 20),
                const SizedBox(width: 12),
                Text(item.label),
              ],
            ),
          ),
      ],
    );
  }
}
