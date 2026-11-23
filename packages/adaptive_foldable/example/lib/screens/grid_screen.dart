// ignore_for_file: deprecated_member_use -- cupertino.dart is deprecated from Flutter 3.50 but still required for the 3.47 floor.
import 'package:adaptive_foldable/adaptive_foldable.dart';
import 'package:adaptive_foldable_example/widgets/example_page.dart';
import 'package:flutter/cupertino.dart';

const _tints = [
  CupertinoColors.systemBlue,
  CupertinoColors.systemIndigo,
  CupertinoColors.systemTeal,
  CupertinoColors.systemOrange,
  CupertinoColors.systemPink,
  CupertinoColors.systemGreen,
];

/// A screen demonstrating [FoldAlignedGrid] with crease avoidance.
class GridScreen extends StatelessWidget {
  /// Creates an instance of [GridScreen].
  const GridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleFixedPage(
      title: 'Fold-Aligned Grid',
      child: FoldAlignedGrid(
        itemCount: 20,
        crossAxisCountPerPane: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemBuilder: (context, index) {
          final tint = _tints[index % _tints.length].resolveFrom(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.square_grid_2x2_fill, color: tint),
                  const SizedBox(height: 8),
                  Text(
                    'Item ${index + 1}',
                    style: CupertinoTheme.of(context).textTheme.textStyle
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
