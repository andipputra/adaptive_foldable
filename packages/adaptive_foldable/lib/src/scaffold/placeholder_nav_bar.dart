import 'package:adaptive_foldable/src/model/nav_layout.dart';
import 'package:flutter/widgets.dart';

/// Minimal bar used until the default Material and Cupertino bars land (ANS-M1-006, ANS-M1-007).
class PlaceholderNavBar extends StatelessWidget {
  /// Creates a placeholder bar drawing [layout].
  const PlaceholderNavBar({super.key, required this.layout});

  /// The layout to draw.
  final NavLayout layout;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < layout.destinations.length; i++)
        Expanded(
          child: Semantics(
            button: true,
            selected: i == layout.selectedIndex,
            label: layout.destinations[i].label,
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => layout.onSelected?.call(i),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Center(
                  child: Text(
                    layout.destinations[i].label,
                    style: TextStyle(
                      fontWeight: i == layout.selectedIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
    ];
    return ColoredBox(
      color: const Color(0xFFEEEEEE),
      child: layout.placement.isVertical
          ? Column(children: items)
          : Row(children: items),
    );
  }
}
